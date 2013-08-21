//
//  RootViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *SOEGameSelectedNotification;

@interface RootViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *statuses;

- (IBAction)actions;
- (IBAction)openInSafari;

@end
