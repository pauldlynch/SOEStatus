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

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *statusButton;
@property (nonatomic, retain) IBOutlet FlickrKenBurnsView *backgroundView;
@property (nonatomic, retain) UIPopoverController *statusPopover;

@end
