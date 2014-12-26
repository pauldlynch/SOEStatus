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
        NSString *path = [[NSBundle mainBundle] pathForResource:@"statusMessages.plist" ofType:nil];
        statusMessages = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!statusMessages) statusMessages = [NSDictionary dictionary];
    }
}

+ (NSString *)messageForStatus:(NSInteger)status {
    NSString *statusString = [NSString stringWithFormat:@"%ld", (long)status];
    return [statusMessages objectForKey:statusString];
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

+ (void)put:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    PLRestful *api = [[self alloc] init];
    [api put:requestPath content:content completionBlock:completion];
}

+ (void)delete:(NSString *)requestPath completionBlock:(PLRestfulAPICompletionBlock)completion {
    PLRestful *api = [[self alloc] init];
    [api delete:requestPath completionBlock:completion];
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
    self.restQueue.name = @"SOE REST Queue";
    [NSURLConnection sendAsynchronousRequest:request queue:self.restQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
            [self callCompletionBlockWithObject:nil status:httpResponse.statusCode error:error];
        } else {
            if ([data length] == 0) {
                NSLog(@"no data");
                [self callCompletionBlockWithObject:nil status:httpResponse.statusCode error:[NSError errorWithDomain:@"com.plsys.SOEStatus" code:1001 userInfo:nil]];
            } else {
                NSError *error;
                id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if (object) {
                    [self callCompletionBlockWithObject:object status:httpResponse.statusCode error:nil];
                } else {
                    NSLog(@"received bad json: (%lu) '%@'", (unsigned long)[data length], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    [self callCompletionBlockWithObject:nil status:httpResponse.statusCode error:[NSError errorWithDomain:@"com.plsys.SOEStatus" code:1002 userInfo:nil]];
                    
                }
            }
        }
    }];
}

// read
- (void)get:(NSString *)requestString parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion {
    NSURL *requestURL = [[NSURL URLWithString:endpoint] urlByAddingPath:requestString parameters:parameters];
    NSLog(@"get: '%@'", [requestURL absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"GET"];
    
    [self handleRequest:request completion:(PLRestfulAPICompletionBlock)completion];
}

// update
- (void)post:(NSString *)requestString content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    NSURL *requestURL = [[NSURL URLWithString:endpoint] urlByAddingPath:requestString parameters:nil];
    NSLog(@"post: '%@'", [requestURL absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:content options:0 error:&error];
    if (error) {
        NSLog(@"json generation failed: %@", error);
        [self callCompletionBlockWithObject:nil status:0 error:[NSError errorWithDomain:@"com.plsys.SOEStatus" code:1003 userInfo:nil]];
        return;
    }
    [self handleRequest:request completion:completion];
}

// create
- (void)put:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion {
    NSURL *requestURL = [[NSURL URLWithString:endpoint] urlByAddingPath:requestPath parameters:nil];
    NSLog(@"put: '%@'", [requestURL absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"PUT"];
    
    NSError *error = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:content options:0 error:&error];
    if (error) {
        NSLog(@"json generation failed: %@", error);
        [self callCompletionBlockWithObject:nil status:0 error:[NSError errorWithDomain:@"com.plsys.SOEStatus" code:1003 userInfo:nil]];
        return;
    }
    [self handleRequest:request completion:completion];
}

// delete
- (void)delete:(NSString *)requestPath completionBlock:(PLRestfulAPICompletionBlock)completion {
    NSURL *requestURL = [[NSURL URLWithString:endpoint] urlByAddingPath:requestPath parameters:nil];
    NSLog(@"delete: '%@'", [requestURL absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"DELETE"];
    
    [self handleRequest:request completion:(PLRestfulAPICompletionBlock)completion];
}

@end
