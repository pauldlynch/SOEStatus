//
//  SOEGame.m
//  SOEStatus
//
//  Created by Paul Lynch on 25/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import "SOEGame.h"
#import "MoveArray.h"
#import "SOEServer.h"

// games.plist
NSMutableArray *_gameInfo;
NSMutableArray *_games;
// rows.plist - array of game keys (current) or edited array of game dictionaries (obsolete)
NSMutableArray *_gameKeys;

@implementation SOEGame

+ (NSArray *)games {
    if (!_games) {
        _games = [NSMutableArray array];
    }
    return _games;
}

+ (NSArray *)gameInfo {
    // ordered and edited array of games
    if (!_gameInfo) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
        _gameKeys = (NSMutableArray *)[NSArray arrayWithContentsOfFile:filePath];
        if ([[_gameKeys lastObject] isKindOfClass:[NSDictionary class]]) {
            // old format, must convert
            _gameKeys = [_gameKeys valueForKey:@"key"];
        }
        
        filePath = [[NSBundle mainBundle] pathForResource:@"games.plist" ofType:nil];
        NSArray *gameDictionaries = [NSMutableArray arrayWithContentsOfFile:filePath];
        
        // now order _gameInfo according to _gameKeys
        NSMutableArray *newGames = [NSMutableArray array];
        for (NSString *key in _gameKeys) {
            for (NSDictionary *gameDictionary in gameDictionaries) {
                if ([key isEqualToString:[gameDictionary objectForKey:@"key"]]) {
                    [newGames addObject:gameDictionary];
                }
            }
        }
        
        // add back in any not ordered
        for (NSDictionary *gameDictionary in gameDictionaries) {
            NSString *key = [gameDictionary objectForKey:@"key"];
            if (![_gameKeys containsObject:key]) {
                [newGames addObject:gameDictionary];
            }
        }
        
        _gameInfo = newGames;
    }
    return _gameInfo;
}

+ (NSDictionary *)gameInfoForKey:(NSString *)key {
    for (NSDictionary *game in [SOEGame gameInfo]) {
        if ([key isEqualToString:[game valueForKey:@"key"]]) {
            return game;
        }
    }
    return nil;
}

+ (SOEGame *)gameForKey:(NSString *)key {
    for (SOEGame *game in [SOEGame games]) {
        if ([key isEqualToString:game.key]) {
            return game;
        }
    }
    return nil;
}

+ (void)updateWithStatuses:(NSDictionary *)statuses {
    NSMutableArray *newGames;
    if (_games) {
        newGames = [_games mutableCopy];
    } else {
        newGames = [NSMutableArray array];
    }
    for (NSString *key in [statuses allKeys]) {
        SOEGame *game = [SOEGame gameForKey:key];
        SOEGame *newGame = [[SOEGame alloc] initWithKey:key values:[statuses objectForKey:key]];
        if (game) {
            NSInteger i = [[SOEGame games] indexOfObject:game];
            [newGames replaceObjectAtIndex:i withObject:newGame];
        } else {
            [newGames addObject:newGame];
        }
    }
    _games = newGames;
    
    [SOEGame save];
}

+ (void)removeGame:(SOEGame *)aGame {
    //TODO: doesn't cater for permanently removing games (or restoring them once removed)
    [_games removeObject:aGame];
    [SOEGame save];
}

+ (void)moveGameFromIndex:(NSInteger)from to:(NSInteger)to {
    [_games moveObjectFromIndex:from toIndex:to];
    [SOEGame save];
}

+ (void)save {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
    _gameKeys = [[SOEGame games] valueForKey:@"key"];
    [_gameKeys writeToFile:filePath atomically:YES];
}

- (id)initWithKey:(NSString *)key values:(NSDictionary *)values {
    self = [super init];
    
    // comes from inbuilt games.plist
    self.key = key;
    NSDictionary *gameInfo = [SOEGame gameInfoForKey:key];
    self.name = [gameInfo objectForKey:@"name"];
    self.search = [gameInfo objectForKey:@"search"];
    
    NSDictionary *regions = [values valueForKey:key];
    regions = values;
    NSMutableArray *regionServers = [NSMutableArray array];
    for (NSString *regionName in [regions allKeys]) {
        NSDictionary *region = [regions valueForKey:regionName];
        for (NSString *serverName in [region allKeys]) {
            SOEServer *server = [[SOEServer alloc] initWithValues:[region objectForKey:serverName]];
            server.name = serverName;
            server.region = regionName;
            server.game = self.key;
            [regionServers addObject:server];
            
            if (!self.name) self.name = [[region objectForKey:serverName] valueForKey:@"title"];
            if (!self.search) self.search = [[region objectForKey:serverName] valueForKey:@"title"];
        }
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sortKey" ascending:YES];
    [regionServers sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];

    self.servers = regionServers;
    
    if (!self.name) self.name = key;
    if (!self.search) self.search = key;
    
    // update games list
    NSUInteger indexOfGame = [_games indexOfObject:self.key];
    if (indexOfGame != NSNotFound) {
        [_games replaceObjectAtIndex:indexOfGame withObject:self];
    } else {
        //NSLog(@"Game key %@ not found in %@", self.key, _games);
        [_games addObject:self];
        _gameKeys = [_games valueForKey:@"key"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@/%@ (%lu)", [super description], self.key, self.name, (unsigned long)self.servers.count];
}

@end
