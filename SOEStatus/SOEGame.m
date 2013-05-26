//
//  SOEGame.m
//  SOEStatus
//
//  Created by Paul Lynch on 25/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import "SOEGame.h"
#import "MoveArray.h"

// games.plist
NSMutableArray *_games;
// rows.plist - array of game keys (current) or edited array of game dictionaries (obsolete)
NSMutableArray *_gameKeys;

@implementation SOEGame

+ (NSArray *)games {
    // ordered and edited array of games
    if (!_games) {        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
        _gameKeys = [[NSArray arrayWithContentsOfFile:filePath] retain];
        if ([[_gameKeys lastObject] isKindOfClass:[NSDictionary class]]) {
            // old format, must convert
            _gameKeys = [_gameKeys valueForKey:@"key"];
            [SOEGame save];
        }
        
        filePath = [[NSBundle mainBundle] pathForResource:@"games.plist" ofType:nil];
        NSArray *gameDictionaries = [[NSMutableArray arrayWithContentsOfFile:filePath] retain];
        
        // now order _games according to _gameKeys
        NSMutableArray *newGames = [NSMutableArray array];
        for (NSString *key in _gameKeys) {
            for (NSDictionary *gameDictionary in gameDictionaries) {
            if ([key isEqualToString:[gameDictionary objectForKey:@"key"]]) {
                SOEGame *game = [[SOEGame alloc] initWithDictionary:gameDictionary];
                [newGames addObject:game];
                [game release];
            }
            }
        }
        
        // add back in any not ordered
        for (NSDictionary *gameDictionary in gameDictionaries) {
            if (![_gameKeys containsObject:[gameDictionary objectForKey:@"key"]]) {
                SOEGame *game = [[SOEGame alloc] initWithDictionary:gameDictionary];
                [newGames addObject:game];
                [game release];
            }
        }
        
        _games = [newGames retain];
    }
    return _games;
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
    // remove dropped games
    NSMutableArray *newGames = [NSMutableArray array];
    for (SOEGame *game in [SOEGame games]) {
        if ([statuses objectForKey:game.key])
            [newGames addObject:game];
    }
    // add missing games
    for (NSString *key in [statuses allKeys]) {
        SOEGame *game = [SOEGame gameForKey:key];
        if (!game) {
            SOEGame *newGame = [[SOEGame alloc] initWithDictionary:[NSDictionary dictionaryWithObject:key forKey:@"key"]];
            [newGames addObject:newGame];
            [game release];
        }
    }
    _games = [newGames retain];
    
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

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    self.key = [dictionary objectForKey:@"key"];
    self.name = [dictionary objectForKey:@"name"];
    self.search = [dictionary objectForKey:@"search"];
    
    return self;
}

@end
