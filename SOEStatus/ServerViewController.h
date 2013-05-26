//
//  ServerViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerViewController : UITableViewController

@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, strong) NSDictionary *game;
@property (nonatomic, strong) NSArray *servers;
@property (nonatomic, strong) UINib *serverCellNib;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)loadGame;

@end
