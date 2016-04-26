//
//  ChartController.h
//  SOEStatus
//
//  Created by Paul Lynch on 24/06/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartController : UIViewController

@property (nonatomic, strong) NSURL *historyURL;
@property (nonatomic, copy) NSString *gameCode;
@property (nonatomic, copy) NSString *server;

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;

@end
