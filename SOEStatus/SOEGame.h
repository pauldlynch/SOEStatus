//
//  SOEGame.h
//  SOEStatus
//
//  Created by Paul Lynch on 25/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOEGame : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *search;
@property (nonatomic, copy) NSArray *servers;

+ (NSArray *)games;
+ (SOEGame *)gameForKey:(NSString *)key;
+ (void)updateWithStatuses:(NSDictionary *)statuses;
+ (void)removeGame:(SOEGame *)aGame;
+ (void)moveGameFromIndex:(NSInteger)from to:(NSInteger)to;
+ (void)save;

- (id)initWithKey:(NSString *)key values:(NSDictionary *)dictionary;

@end
