//
//  ServerViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SOEGame;

@interface ServerViewController : UITableViewController

@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, strong) SOEGame *game;
@property (nonatomic, strong) NSArray *servers;
@property (nonatomic, strong) UINib *serverCellNib;

- (void)loadGame;

@end
