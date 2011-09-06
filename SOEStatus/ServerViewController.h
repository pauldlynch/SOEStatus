//
//  ServerViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@interface ServerViewController : PullRefreshTableViewController

@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, retain) NSDictionary *game;
@property (nonatomic, retain) NSArray *servers;
@property (nonatomic, retain) UINib *serverCellNib;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

- (void)loadGame;

@end
