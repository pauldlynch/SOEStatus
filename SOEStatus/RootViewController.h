//
//  RootViewController.h
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PullRefreshTableViewController.h"

extern NSString *SOEGameSelectedNotification;

@interface RootViewController : PullRefreshTableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *statuses;

- (IBAction)actions;
- (IBAction)openInSafari;
- (IBAction)like;
- (IBAction)review;
- (IBAction)shareByTwitter;
- (IBAction)shareByEmail;
- (IBAction)feedback;

@end
