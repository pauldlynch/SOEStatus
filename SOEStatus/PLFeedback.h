//
//  PLFeedback.h
//  SOEstatus
//
//  Created by Paul Lynch on 012/07/2013.
//  Copyright 2013 P & L Systems. All rights reserved.
//

// Requires:
// MessageUI, Social/Twitter

// Uses PLFeedback_settings.json - see code for keys

// Usage:
// call [[PLFeedback alloc] init] from AppDelegate at launch, to track launch count
//
// call PLFeedback *plFeedback =[[PLFeedback alloc] initWithViewController:] from view controllers,
// and send [plFeedback actions] to present base menu from a button.
// call [[[PLFeedback alloc] init] checkForRating] in viewDidLoad to check launch count.
// If you want to skip actions and call actions directly, please set viewToPresentSheet first.

#import <UIKit/UIKit.h>

@interface PLFeedback : NSObject

@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, strong) id viewToPresentSheet; // or bar button

- (id)initWithViewController:(UIViewController *)viewController;

- (IBAction)actions:(id)sender;
- (void)setup;

- (IBAction)like;
- (IBAction)review;
- (IBAction)shareByTwitter;
- (IBAction)shareByFacebook;
- (IBAction)shareByEmail;
- (IBAction)feedback;

- (void)checkForRating;

@end