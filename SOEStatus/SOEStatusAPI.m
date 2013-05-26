//
//  SOEStatusAPI.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "SOEStatusAPI.h"

@interface NSDate (Age)
+ (NSDate *)pl_dateFromAgeString:(NSString *)string;
@end

@implementation NSDate (Age)

+ (NSDate *)pl_dateFromAgeString:(NSString *)string {
    // convert age to actual time stamp
    NSScanner* timeScanner=[NSScanner scannerWithString:string];
    int hours, minutes, seconds;
    [timeScanner scanInt:&hours];
    [timeScanner scanString:@":" intoString:nil]; //jump over :
    [timeScanner scanInt:&minutes];
    [timeScanner scanString:@":" intoString:nil]; //jump over :
    [timeScanner scanInt:&seconds];
    seconds = (((hours * 60) + minutes) * 60) + seconds;
    return [NSDate dateWithTimeIntervalSinceNow:-seconds];
}

@end

@implementation SOEStatusAPI

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.endpoint = @"http://data.soe.com/json/status/"; // public API
    }
    
    return self;
}

+ (void)getStatuses:(PLRestfulAPICompletionBlock)completion {
    [SOEStatusAPI get:@"" parameters:nil completionBlock:^(PLRestful *api, id object, int status, NSError *error){
        completion(api, object, status, error);
    }];
}

+ (void)getGameStatus:(NSString *)gameId completion:(PLRestfulAPICompletionBlock)completion {
    [SOEStatusAPI get:gameId parameters:nil completionBlock:^(PLRestful *api, id object, int status, NSError *error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (!error) {
            NSDictionary *game = [object valueForKey:gameId];
            [userInfo setObject:game forKey:@"game"];
            
            NSMutableArray *regionServers = [NSMutableArray array];
            [userInfo setObject:regionServers forKey:@"regionServers"];
            for (NSString *regionName in [game allKeys]) {
                NSDictionary *region = [game valueForKey:regionName];
                for (NSString *serverName in [region allKeys]) {
                    NSMutableDictionary *server = [[region objectForKey:serverName] mutableCopy];
                    [server setObject:serverName forKey:@"name"];
                    NSString *sortKey = [NSString stringWithFormat:@"%@/%@", regionName, serverName];
                    [server setObject:sortKey forKey:@"sortKey"];
                    [server setObject:regionName forKey:@"region"];
                    NSString *age = [server valueForKey:@"age"];
                    [server setObject:[NSDate pl_dateFromAgeString:age] forKey:@"date"];
                    
                    [regionServers addObject:server];
                }
            }
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sortKey" ascending:YES];
            [regionServers sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        }
        completion(api, userInfo, status, error);
    }];
}

@end
