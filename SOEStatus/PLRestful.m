//
//  PLRestful.m
//  SOEStatus
//
//  Created by Paul Lynch on 15/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "PLRestful.h"
#import "AFNetworking.h"
#import "PRPAlertView.h"
#import "UIApplication+PRPNetworkActivity.h"
#import "SOEHTTPClient.h"

@interface NSString (Encoding)
@end
@implementation NSString (Encoding)

- (NSString *)pl_stringByAddingPercentEscapesUsingEncoding:(CFStringBuiltInEncodings)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               encoding));
}

@end

@implementation PLRestful

static NSDictionary *statusMessages;

@synthesize completionBlock, endpoint, username, password;

//TODO: should move to a plist in app wrapper
+(void)initialize {
    if (self == [PLRestful class]) {
        statusMessages = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Ok", [NSNumber numberWithInt:200], 
                          @"Created", [NSNumber numberWithInt:201], // responds to a POST that creates a resource
                          @"Accepted", [NSNumber numberWithInt:202], // long running task
                          @"Non-authoritative information", [NSNumber numberWithInt:203], 
                          @"No content", [NSNumber numberWithInt:204], 
                          @"Reset content", [NSNumber numberWithInt:205], 
                          @"Partial content", [NSNumber numberWithInt:206], 
                          @"Multiple choices", [NSNumber numberWithInt:300], 
                          @"Moved permanently", [NSNumber numberWithInt:301], // new URI in Location header
                          @"Found", [NSNumber numberWithInt:302], // temp URI in Location header
                          @"See other", [NSNumber numberWithInt:303], // see Location header
                          @"Not modified", [NSNumber numberWithInt:304], 
                          @"Use proxy", [NSNumber numberWithInt:305], 
                          @"Bad request", [NSNumber numberWithInt:400], 
                          @"Unauthorized", [NSNumber numberWithInt:401], // WWW-Authenticate header has challenge
                          @"Forbidden", [NSNumber numberWithInt:403], 
                          @"Not found", [NSNumber numberWithInt:404], 
                          @"Not allowed", [NSNumber numberWithInt:405], // Allow header has list of valid methods
                          @"Not acceptable", [NSNumber numberWithInt:406], 
                          @"Authentication required", [NSNumber numberWithInt:407], 
                          @"Request timeout", [NSNumber numberWithInt:408], 
                          @"Conflict", [NSNumber numberWithInt:409], 
                          @"Gone", [NSNumber numberWithInt:410], 
                          @"Length required", [NSNumber numberWithInt:411], 
                          @"Precondition failed", [NSNumber numberWithInt:412], 
                          @"Request entity too large", [NSNumber numberWithInt:413], 
                          @"Request URI too long", [NSNumber numberWithInt:414], 
                          @"Unspported media type", [NSNumber numberWithInt:415], 
                          @"Requested range not satisfiable", [NSNumber numberWithInt:416], 
                          @"Expectation failed", [NSNumber numberWithInt:417], 
                          @"Internal server error", [NSNumber numberWithInt:500], 
                          @"Not implemented", [NSNumber numberWithInt:501], 
                          @"Bad gateway", [NSNumber numberWithInt:502], 
                          @"Service unavailable", [NSNumber numberWithInt:503], // temporary 
                          @"Gateway timeout", [NSNumber numberWithInt:504], 
                          nil];
    }
}

+ (NSString *)messageForStatus:(int)status {
    return [statusMessages objectForKey:[NSNumber numberWithInt:status]];
}

/*+ (BOOL)checkReachability:(NSURL *)url {
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
}*/

+ (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion {
    PLRestful *api = [[self alloc] init];
    [api get:requestPath parameters:parameters completionBlock:completion];
}

/*+ (void)post:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    PLRestful *api = [[[self alloc] init] autorelease];
    [api post:requestPath content:content completionBlock:completion];
}*/



/*- (void)handleRequest:requestString completion:(PLRestfulAPICompletionBlock)completion {
    self.completionBlock = completion;
    [[UIApplication sharedApplication] prp_pushNetworkActivity];
    
    if (![[SOEHTTPClient sharedClient] networkReachabilityStatus]) {
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        return;
    }
    
    [[SOEHTTPClient sharedClient] setUsername:username andPassword:password];
    
    [[SOEHTTPClient sharedClient] getPath:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"IP Address: %@", [responseObject valueForKeyPath:@"origin"]);
        if (completion) completion(self, responseObject, operation.response.statusCode, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) completion(self, operation.responseString, operation.response.statusCode, error);
    }];
}*/

- (void)get:(NSString *)requestString parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion {
    if (parameters) {
        requestString = [requestString stringByAppendingString:@"?"];
        BOOL first = YES;
        for (NSString *key in [parameters allKeys]) {
            if (!first) {
                requestString = [requestString stringByAppendingString:@"&"];
            }
            requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [[[parameters objectForKey:key] description] pl_stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8]]];
            first = NO;
        }
    }
    
    [[UIApplication sharedApplication] prp_pushNetworkActivity];
    
    if (![[SOEHTTPClient sharedClient] networkReachabilityStatus]) {
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        return;
    }
    
    [[SOEHTTPClient sharedClient] setUsername:username andPassword:password];
    
    [[SOEHTTPClient sharedClient] getPath:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response = %@", responseObject);
        if (completion) completion(self, responseObject, operation.response.statusCode, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) completion(self, operation.responseString, operation.response.statusCode, error);
    }];
}

/*- (void)post:(NSString *)requestString content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    [request appendPostData:[NSJSONSerialization dataWithJSONObject:content options:0 error:nil]];
    [self handleRequest:requestString completion:completion];
}*/

@end
