//
//  PLRestful.h
//  SOEStatus
//
//  Created by Paul Lynch on 15/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLRestful;

typedef void (^PLRestfulAPICompletionBlock)(PLRestful *api, id object, NSInteger status, NSError *error);

@interface PLRestful : NSObject

@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, copy) PLRestfulAPICompletionBlock completionBlock;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL useBasicAuthentication;

+ (NSString *)messageForStatus:(NSInteger)status;
+ (BOOL)checkReachability:(NSURL *)url;
+ (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion;
+ (void)post:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion;
+ (void)put:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion;
+ (void)delete:(NSString *)requestPath completionBlock:(PLRestfulAPICompletionBlock)completion;

- (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(PLRestfulAPICompletionBlock)completion;
- (void)post:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion;
- (void)put:(NSString *)requestPath content:(NSDictionary *)content completionBlock:(PLRestfulAPICompletionBlock)completion;
- (void)delete:(NSString *)requestPath completionBlock:(PLRestfulAPICompletionBlock)completion;

@end
