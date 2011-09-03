//
//  RootViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@interface RootViewController : PullRefreshTableViewController

@property (nonatomic, retain) NSDictionary *statuses;
@property (nonatomic, retain) NSMutableArray *rows;

- (NSDictionary *)rowForKey:(NSString *)key;

@end
