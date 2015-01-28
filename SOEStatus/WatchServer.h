//
//  NotifyServers.h
//  SOEStatus
//
//  Created by Paul Lynch on 03/12/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOEServer;

@interface WatchServer : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, retain) NSArray *notifyServers;

- (NSArray *)watches;
- (BOOL)watching;
- (id)watchingFor:(NSString *)game region:(NSString *)region server:(NSString *)server;
- (id)watchingServer:(SOEServer *)server;
- (void)removeWatch:(NSString *)game region:(NSString *)region server:(NSString *)server;
- (void)removeWatch:(SOEServer *)server;
- (void)watchFor:(NSString *)game region:(NSString *)region server:(NSString *)server status:(id)status;
- (void)watchForServer:(SOEServer *)server;

- (void)notify;

- (void)reportWatching;
- (void)reportSavedStatuses;

@end
