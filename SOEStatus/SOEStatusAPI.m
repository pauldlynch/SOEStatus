//
//  SOEStatusAPI.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "SOEStatusAPI.h"
#import "SOEServer.h"
#import "SOEGame.h"

#define DEBUG_NOTIFICATIONS (NO)

@implementation SOEStatusAPI

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.endpoint = @"https://census.daybreakgames.com/json/status/"; // public API
    }
    
    return self;
}

+(id)mockStatus {
    NSInteger random = arc4random() % 2;
    NSLog(@"random %ld", (long)random);
    if (random) {
        NSLog(@"low");
        return @{@"lm":
                       @{@"Beta":
                             @{@"Adventure":@{@"age":@"01:06:14", @"ageSeconds":@3974, @"status":@"low", @"title":@"Landmark"},
                               @"Confidence":@{@"age":@"00:53:16", @"ageSeconds":@3196, @"status":@"low", @"title":@"Landmark"},
                               @"Courage":@{@"age":@"00:53:06", @"ageSeconds":@3186, @"status":@"low", @"title":@"Landmark"},
                               @"Determination":@{@"age": @"00:55:38", @"ageSeconds":@3338, @"status":@"low", @"title":@"Landmark"},
                               @"Liberation":@{@"age":@"00:53:21", @"ageSeconds":@3201, @"status":@"low", @"title":@"Landmark"},
                               @"Rebellion":@{@"age":@"00:58:53", @"ageSeconds":@3533, @"status":@"low", @"title":@"Landmark"},
                               @"Satisfaction (EU)":@{@"age":@"92:03:17", @"ageSeconds":@331397, @"status":@"down", @"title":@"Landmark"},
                               @"Serenity":@{@"age":@"00:52:57", @"ageSeconds":@3177, @"status":@"low", @"title":@"Landmark"},
                               @"Understanding (EU)":@{@"age":@"92:03:35", @"ageSeconds":@331415, @"status":@"down", @"title":@"Landmark"}}}};
    }
    return @{@"lm":
                   @{@"Beta":
                         @{@"Adventure":@{@"age":@"01:06:14", @"ageSeconds":@3974, @"status":@"missing", @"title":@"Landmark"},
                           @"Confidence":@{@"age":@"00:53:16", @"ageSeconds":@3196, @"status":@"down", @"title":@"Landmark"},
                           @"Courage":@{@"age":@"00:53:06", @"ageSeconds":@3186, @"status":@"down", @"title":@"Landmark"},
                           @"Determination":@{@"age": @"00:55:38", @"ageSeconds":@3338, @"status":@"down", @"title":@"Landmark"},
                           @"Liberation":@{@"age":@"00:53:21", @"ageSeconds":@3201, @"status":@"down", @"title":@"Landmark"},
                           @"Rebellion":@{@"age":@"00:58:53", @"ageSeconds":@3533, @"status":@"down", @"title":@"Landmark"},
                           @"Satisfaction (EU)":@{@"age":@"92:03:17", @"ageSeconds":@331397, @"status":@"high", @"title":@"Landmark"},
                           @"Serenity":@{@"age":@"00:52:57", @"ageSeconds":@3177, @"status":@"down", @"title":@"Landmark"},
                           @"Understanding (EU)":@{@"age":@"92:03:35", @"ageSeconds":@331415, @"status":@"medium", @"title":@"Landmark"}}}};
}

+ (void)getStatuses:(PLRestfulAPICompletionBlock)completion {
    [SOEStatusAPI get:@"" parameters:nil completionBlock:^(PLRestful *api, id object, NSInteger status, NSError *error){
        // object is JSON; convert to array of SOEGames
        if (DEBUG_NOTIFICATIONS) object = [SOEStatusAPI mockStatus];
        [SOEGame updateWithStatuses:object];
        completion(api, object, status, error);
    }];
}

+ (void)getGameStatus:(NSString *)gameId completion:(PLRestfulAPICompletionBlock)completion {
    [SOEStatusAPI get:gameId parameters:nil completionBlock:^(PLRestful *api, id object, NSInteger status, NSError *error){
        if (DEBUG_NOTIFICATIONS) object = [SOEStatusAPI mockStatus];
        // object is JSON; convert to array of SOEGames
        [SOEGame updateWithStatuses:object];
        completion(api, object, status, error);
    }];
}

@end
