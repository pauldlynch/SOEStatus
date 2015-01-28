//
//  NotifyServers.m
//  SOEStatus
//
//  Created by Paul Lynch on 03/12/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import "WatchServer.h"
#import "SOEServer.h"
#import "SOEGame.h"

@interface WatchServer ()

@end

@implementation WatchServer

+ (instancetype)sharedInstance {
    @synchronized(self) {
        static WatchServer *_instance;
        if (!_instance) {
            _instance = [[WatchServer alloc] init];
        }
        return _instance;
    }
}

+ (NSString *)serverKeyForGame:(NSString *)game region:(NSString *)region server:(NSString *)server {
    return [NSString stringWithFormat:@"ServerWatch %@/%@/%@", game, region, server];
}

- (NSArray *)watches {
    NSDictionary *keys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSMutableArray *watches = [NSMutableArray array];
    for (NSString *key in keys) {
        if ([key isKindOfClass:[NSString class]] && [key hasPrefix:@"ServerWatch "]) {
            [watches addObject:[key stringByReplacingOccurrencesOfString:@"ServerWatch " withString:@""]];
        }
    }
    return watches;

}

- (BOOL)watching {
    return [[self watches] count] ? YES : NO;
}

- (id)watchingFor:(NSString *)game region:(NSString *)region server:(NSString *)server {
    NSString *key = [WatchServer serverKeyForGame:game region:region server:server];
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (id)watchingServer:(SOEServer *)server {
    return [self watchingFor:server.game region:server.region server:server.name];
}

- (void)removeWatch:(NSString *)game region:(NSString *)region server:(NSString *)server {
    NSString *key = [WatchServer serverKeyForGame:game region:region server:server];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)removeWatch:(SOEServer *)server {
    [self removeWatch:server.game region:server.region server:server.name];
}

- (void)watchFor:(NSString *)game region:(NSString *)region server:(NSString *)server status:(id)status {
    NSString *key = [WatchServer serverKeyForGame:game region:region server:server];
    [[NSUserDefaults standardUserDefaults] setValue:status forKey:key];
}

- (void)watchForServer:(SOEServer *)server {
    [self watchFor:server.game region:server.region server:server.name status:server.status];
}

- (void)notify {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // loop through servers; if watched, compare status and create notification if changed and update watch status
    for (SOEGame *game in [SOEGame games]) {
        for (SOEServer *server in game.servers) {
            NSString *status = [self watchingServer:server];
            if (status) { // only true if server is being watched
                NSLog(@"%@ status: %@", server.name, status);
                if (![status isEqualToString:server.status]) { // and has changed
                    if ([SOEServer isUpOrDown:status] != server.isUpOrDown) { // and has changed significantly
                        NSString *message = server.isUpOrDown ? @"%@ %@ server is up." : @"%@ %@ server is down.";
                        message  = [NSString stringWithFormat:message, game.name, server.name];
                        NSLog(@"%@; previous status: %@, current status %@", message, status, server.status);
                        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
                            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                            localNotification.alertBody = message;
                            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                        } else {
                            //UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server status changed" message:message preferredStyle:UIAlertControllerStyleAlert];
                            //[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                        }
                    }
                }
                [self watchForServer:server];
            }
        }
    }
}

- (void)reportWatching {
    NSDictionary *keys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in keys) {
        if ([key isKindOfClass:[NSString class]] && [key hasPrefix:@"ServerWatch "]) {
            NSLog(@"%@ %@", key, [keys objectForKey:key]);
        }
    }
    
}

- (void)reportSavedStatuses {
    NSDictionary *keys = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in keys) {
        if ([key isKindOfClass:[NSString class]] && [key hasPrefix:@"ServerWatch "]) {
            NSLog(@"%@ %@", key, [[NSUserDefaults standardUserDefaults] stringForKey:key]);
        }
    }
    
}

@end
