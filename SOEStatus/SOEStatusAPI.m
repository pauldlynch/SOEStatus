//
//  SOEStatusAPI.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "SOEStatusAPI.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import "JSON.h"
#import "UIApplication+PRPNetworkActivity.h"
#import "PRPAlertView.h"

@interface NSString (Encoding)
@end
@implementation NSString (Encoding)

- (NSString *)pl_stringByAddingPercentEscapesUsingEncoding:(CFStringBuiltInEncodings)encoding {
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               encoding);
}

@end

@implementation SOEStatusAPI

@synthesize baseURL, completionBlock;

static NSString *endpoint;
static NSArray *_games;

+ (void)initialize {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        // Perform initialization here
        [SOEStatusAPI setEndpoint:@"https://lp.soe.com/json/status/"]; // public API
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"games.plist" ofType:nil];
        _games = [[NSArray arrayWithContentsOfFile:filePath] retain];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    self.baseURL = nil;
    self.completionBlock = nil;
    [super dealloc];
}

+ (void)setEndpoint:(NSString *)value {
    if (value != endpoint) [endpoint release];
    endpoint = [value copy];
}
- (void)setEndpoint:(NSString *)value {
    [SOEStatusAPI setEndpoint:value];
}
- (NSString *)endpoint {
    return endpoint;
}

+ (NSArray *)games {
    return _games;
}

+ (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(SOEStatusAPICompletionBlock)completion {
    SOEStatusAPI *api = [[[self alloc] init] autorelease];
    [api get:requestPath parameters:parameters completionBlock:completion];
}

- (void)get:(NSString *)requestString parameters:(NSDictionary *)parameters completionBlock:(SOEStatusAPICompletionBlock)completion {
    NSString *fullRequestString = [self.endpoint stringByAppendingString:requestString];
    if (parameters) {
        fullRequestString = [fullRequestString stringByAppendingString:@"?"];
        BOOL first = YES;
        for (NSString *key in [parameters allKeys]) {
            if (!first) {
                fullRequestString = [fullRequestString stringByAppendingString:@"&"];
            }
            fullRequestString = [fullRequestString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", 
                                                                            key, 
                                                                            [[[parameters objectForKey:key] description] pl_stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8]]];
            first = NO;
        }
    }
    NSURL *requestURL = [NSURL URLWithString:fullRequestString];
    //NSLog(@"get: '%@'", [requestURL absoluteString]);
            
    self.completionBlock = completion;
    [[UIApplication sharedApplication] prp_pushNetworkActivity];
    
    if (![SOEStatusAPI checkReachability:requestURL]) {
        //self.completionBlock(self, nil, [NSError errorWithDomain:@"com.plsys.SOEStatusAPI" code:1003 userInfo:nil]);
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        return;
    }
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:requestURL];
    [request setCompletionBlock:^{
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        NSString *json = [request responseString];
        id object = [json JSONValue];
        if (object) {
            self.completionBlock(self, object, nil);
        } else {
            NSLog(@"received bad json: '%@'", json);
            self.completionBlock(self, object, [NSError errorWithDomain:@"com.plsys.SOEStatusAPI" code:1002 userInfo:nil]);
        }
    }];
    [request setFailedBlock:^{
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        NSError *error = [request error];
        self.completionBlock(self, nil, error);
    }];
    [request startAsynchronous];
}

+ (BOOL)checkReachability:(NSURL *)url {
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];	
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];	
	if (netStatus == NotReachable) {
        [PRPAlertView showWithTitle:@"Network" message:@"Not connected to the Internet" buttonTitle:@"Continue"];
        return NO;
    } else {
        hostReach = [Reachability reachabilityWithHostName:[url host]];
        NetworkStatus netStatus = [hostReach currentReachabilityStatus];	
        if (netStatus == NotReachable) {
            [PRPAlertView showWithTitle:@"Network" message:@"Can't reach server" buttonTitle:@"Continue"];
            return NO;
        }
    }
    return YES;
}

@end
