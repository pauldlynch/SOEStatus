//
//  PLRestful.m
//  SOEStatus
//
//  Created by Paul Lynch on 15/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "PLRestful.h"
#import "PRPAlertView.h"
#import "Reachability.h"
#import "UIApplication+PRPNetworkActivity.h"
#import "PLCategories.h"

@interface PLRestful ()

@property (nonatomic, strong) NSOperationQueue *restQueue;

@end

@implementation PLRestful

static NSDictionary *statusMessages;

@synthesize completionBlock, endpoint, username, password;

//TODO: should move to a plist in app wrapper
+(void)initialize {
    if (self == [PLRestful class]) {
        statusMessages = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Ok", [NSNumber numberWithInteger:200],
                          @"Created", [NSNumber numberWithInteger:201], // responds to a POST that creates a resource
                          @"Accepted", [NSNumber numberWithInteger:202], // long running task
                          @"Non-authoritative information", [NSNumber numberWithInteger:203],
                          @"No content", [NSNumber numberWithInteger:204],
                          @"Reset content", [NSNumber numberWithInteger:205],
                          @"Partial content", [NSNumber numberWithInteger:206],
                          @"Multiple choices", [NSNumber numberWithInteger:300],
                          @"Moved permanently", [NSNumber numberWithInteger:301], // new URI in Location header
                          @"Found", [NSNumber numberWithInteger:302], // temp URI in Location header
                          @"See other", [NSNumber numberWithInteger:303], // see Location header
                          @"Not modified", [NSNumber numberWithInteger:304],
                          @"Use proxy", [NSNumber numberWithInteger:305],
                          @"Bad request", [NSNumber numberWithInteger:400],
                          @"Unauthorized", [NSNumber numberWithInteger:401], // WWW-Authenticate header has challenge
                          @"Forbidden", [NSNumber numberWithInteger:403],
                          @"Not found", [NSNumber numberWithInteger:404],
                          @"Not allowed", [NSNumber numberWithInteger:405], // Allow header has list of valid methods
                          @"Not acceptable", [NSNumber numberWithInteger:406],
                          @"Authentication required", [NSNumber numberWithInteger:407],
                          @"Request timeout", [NSNumber numberWithInteger:408],
                          @"Conflict", [NSNumber numberWithInteger:409],
                          @"Gone", [NSNumber numberWithInteger:410],
                          @"Length required", [NSNumber numberWithInteger:411],
                          @"Precondition failed", [NSNumber numberWithInteger:412],
                          @"Request entity too large", [NSNumber numberWithInteger:413],
                          @"Request URI too long", [NSNumber numberWithInteger:414],
                          @"Unspported media type", [NSNumber numberWithInteger:415],
                          @"Requested range not satisfiable", [NSNumber numberWithInteger:416],
                          @"Expectation failed", [NSNumber numberWithInteger:417],
                          @"Internal server error", [NSNumber numberWithInteger:500],
                          @"Not implemented", [NSNumber numberWithInteger:501],
                          @"Bad gateway", [NSNumber numberWithInteger:502],
                          @"Service unavailable", [NSNumber numberWithInteger:503], // temporary
                          @"Gateway timeout", [NSNumber numberWithInteger:504],
                          nil];
    }
}

+ (NSString *)messageForStatus:(int)status {
    return [statusMessages objectForKey:[NSNumber numberWithInteger:status]];
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

+ (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion {
    PLRestful *api = [[self alloc] init];
    [api get:requestPath parameters:parameters completionBlock:completion];
}

+ (void)post:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    PLRestful *api = [[self alloc] init];
    [api post:requestPath content:content completionBlock:completion];
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
    [self.restQueue cancelAllOperations];
    self.completionBlock = nil;
}

- (void)callCompletionBlockWithObject:(id)object status:(NSInteger)status error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        self.completionBlock(self, object, status, error);
    });
}

- (void)handleRequest:(NSMutableURLRequest *)request completion:(PLRestfulAPICompletionBlock)completion {
    
    if (self.username && self.password && self.useBasicAuthentication) {
        NSString *authString = [[NSString stringWithFormat:@"%@:%@", username, password] base64];
        NSString *authHeader = [NSString stringWithFormat:@"Basic %@", authString];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    }
    //[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    self.completionBlock = completion;
    [[UIApplication sharedApplication] prp_pushNetworkActivity];
    
    if (![PLRestful checkReachability:request.URL]) {
        [[UIApplication sharedApplication] prp_popNetworkActivity];
        return;
    }
    
    self.restQueue = [[NSOperationQueue alloc] init];
    self.restQueue.name = @"Comet REST Queue";
    [NSURLConnection sendAsynchronousRequest:request queue:self.restQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
            [self callCompletionBlockWithObject:nil status:httpResponse.statusCode error:error];
        } else {
            if ([data length] == 0) {
                NSLog(@"no data");
                [self callCompletionBlockWithObject:nil status:httpResponse.statusCode error:[NSError errorWithDomain:@"com.plsys.semaphore.CometAPI" code:1001 userInfo:nil]];
            } else {
                NSError *error;
                id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if (object) {
                    [self callCompletionBlockWithObject:object status:httpResponse.statusCode error:nil];
                } else {
                    NSLog(@"received bad json: (%d) '%@'", [data length], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    [self callCompletionBlockWithObject:nil status:httpResponse.statusCode error:[NSError errorWithDomain:@"com.plsys.semaphore.CometAPI" code:1002 userInfo:nil]];
                    
                }
            }
        }
    }];
}

- (void)get:(NSString *)requestString parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion {
    NSURL *requestURL = [[NSURL URLWithString:endpoint] urlByAddingPath:requestString parameters:parameters];
    NSLog(@"get: '%@'", [requestURL absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"GET"];
    
    [self handleRequest:request completion:(PLRestfulAPICompletionBlock)completion];
}

- (void)post:(NSString *)requestString content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    NSURL *requestURL = [[NSURL URLWithString:endpoint] urlByAddingPath:requestString parameters:nil];
    NSLog(@"post: '%@'", [requestURL absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:content options:0 error:&error];
    if (error) {
        NSLog(@"json generation failed: %@", error);
        [self callCompletionBlockWithObject:nil status:0 error:[NSError errorWithDomain:@"com.plsys.semaphore.CometAPI" code:1003 userInfo:nil]];
        return;
    }
    [self handleRequest:request completion:completion];
}

@end
