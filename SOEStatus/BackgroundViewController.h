//
//  BackgroundViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 25/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrKenBurnsView;

@interface BackgroundViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *statusButton;
@property (nonatomic, strong) IBOutlet FlickrKenBurnsView *backgroundView;
@property (nonatomic, strong) UIPopoverController *statusPopover;

@end
