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

@interface RootViewController : PullRefreshTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *statuses;
@property (nonatomic, retain) NSMutableArray *rows;

- (IBAction)actions;
- (IBAction)openInSafari;
- (IBAction)like;
- (IBAction)review;
- (IBAction)shareByTwitter;
- (IBAction)shareByEmail;
- (IBAction)feedback;

- (NSDictionary *)rowForKey:(NSString *)key;

@end
