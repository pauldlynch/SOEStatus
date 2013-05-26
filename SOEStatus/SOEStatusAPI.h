//
//  SOEStatusAPI.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLRestful.h"

@interface SOEStatusAPI : PLRestful

+ (void)getStatuses:(PLRestfulAPICompletionBlock)completion;
+ (void)getGameStatus:(NSString *)gameId completion:(PLRestfulAPICompletionBlock)completion;

@end
