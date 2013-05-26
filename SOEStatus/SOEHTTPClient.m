//
//  SOEHTTPClient.m
//  SOEStatus
//
//  Created by Paul Lynch on 26/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import "SOEHTTPClient.h"
#import "AFNetworking/AFJSONRequestOperation.h"
#import "AFNetworking/AFNetworkActivityIndicatorManager.h"

@implementation SOEHTTPClient

+ (SOEHTTPClient *)sharedClient {
    static dispatch_once_t pred;
    static SOEHTTPClient *_sharedManager = nil;
    
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://data.soe.com/json/status/"]]; }); // You should probably make this a constant somewhere
    return _sharedManager;
}
- (void)setUsername:(NSString *)username andPassword:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}
@end
