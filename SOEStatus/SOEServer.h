//
//  Server.h
//  SOEStatus
//
//  Created by Paul Lynch on 04/12/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOEServer : NSObject

@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSString *sortKey;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, retain) NSDate *date;

+ (BOOL)isUpOrDown:(NSString *)status;

- (instancetype)initWithValues:(NSDictionary *)values;

- (BOOL)isUpOrDown;

@end
