//
//  SOEHTTPClient.h
//  SOEStatus
//
//  Created by Paul Lynch on 26/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import "AFHTTPClient.h"

@interface SOEHTTPClient : AFHTTPClient

+ (SOEHTTPClient *)sharedClient;

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

@end
