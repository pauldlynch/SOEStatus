//
//  Server.m
//  SOEStatus
//
//  Created by Paul Lynch on 04/12/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import "SOEServer.h"

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

@implementation SOEServer

+ (BOOL)isUpOrDown:(NSString *)status {
    if ([status isEqualToString:@"low"]
        || [status isEqualToString:@"medium"]
        || [status isEqualToString:@"high"]) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithValues:(NSDictionary *)values {
    self = [self init];
    
    _name = [values valueForKey:@"name"];
    _region = [values valueForKey:@"region"];
    _game = [values valueForKey:@"game"];
    _title = [values valueForKey:@"title"];
    _status = [values valueForKey:@"status"];
    
    _age = [values valueForKey:@"age"];
    _date = [NSDate pl_dateFromAgeString:_age];
    
    return self;
}

- (BOOL)isUpOrDown {
    return [SOEServer isUpOrDown:self.status];
}

- (NSString *)sortKey {
    return [NSString stringWithFormat:@"%@/%@/%@", _game, _region, _name];
}

- (BOOL)isEqual:(id)anObject {
    if (![self.name isEqualToString:[anObject valueForKey:@"name"]]) return NO;
    if (![self.region isEqualToString:[anObject valueForKey:@"region"]]) return NO;
    if (![self.game isEqualToString:[anObject valueForKey:@"game"]]) return NO;
    return YES;
}

@end
