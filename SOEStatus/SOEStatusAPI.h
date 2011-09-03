//
//  SOEStatusAPI.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOEStatusAPI;

typedef void (^SOEStatusAPICompletionBlock)(SOEStatusAPI *api, id object, NSError *error);

@interface SOEStatusAPI : NSObject

@property (nonatomic, retain) NSURL *baseURL;
@property (nonatomic, copy) NSString *endpoint;
@property (nonatomic, copy) SOEStatusAPICompletionBlock completionBlock;

+ (NSArray *)games;

+ (void)setEndpoint:(NSString *)value;
+ (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(SOEStatusAPICompletionBlock)completion;
- (void)get:(NSString *)requestPath parameters:(NSDictionary *)parameters completionBlock:(SOEStatusAPICompletionBlock)completion;

- (BOOL)checkReachability:(NSURL *)url;

@end
