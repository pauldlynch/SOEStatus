//
//  PLFeedback.m
//  SOEStatus
//
//  Created by Paul Lynch on 012/07/2013.
//  Copyright 2013 P & L Systems. All rights reserved.
//

#import "PLFeedback.h"
#import "PLActionSheet.h"
#import "PRPAlertView.h"
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

@interface PLFeedback () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *settings;

@end

static NSString *LAUNCHCOUNT_PREFERENCE = @"launchCount";
static NSString *REVIEWURL_KEY = @"reviewURL";
static NSString *DOWNLOADURL_KEY = @"downloadURL";
static NSString *SUPPORTEMAIL_KEY = @"supportEmail";
static NSString *TRIGGERCOUNT_KEY = @"triggerCount";

@implementation PLFeedback

+ (void)initialize {
    if (self == [PLFeedback class]) {
        // monitor launch count - therefore must [[PLFeedback alloc] init] in AppDelegate at launch to load class!
        //[PLFeedback launched:nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launched:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launched:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

+ (void)launched:(NSNotification *)notification {
    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger launchCount = [prefs integerForKey:LAUNCHCOUNT_PREFERENCE];
    launchCount++;
    [prefs setInteger:launchCount forKey:LAUNCHCOUNT_PREFERENCE];
    [prefs synchronize];
    NSLog(@"PLFeedback updating launch count: %ld, from: %@", (long)launchCount, [notification name]);
    [[[PLFeedback alloc] init] checkForRating];
    //});
}

- (id)init {
    self = [super init];
    
    NSError *error;
    self.settings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PLFeedback_settings.json" ofType:nil]] options:0 error:&error];
    if (!self.settings) {
        NSLog(@"PLFeedback_settings.json is either missing or corrupted: %@", error);
        self.settings = @{};
    }
    
    return self;
}

- (id)initWithViewController:(UIViewController *)viewController {
    self = [self init];
    
    self.parentViewController = viewController;
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// IBActions

- (IBAction)actions:(id)sender {
    self.viewToPresentSheet = sender;
    NSArray *buttons = [NSArray arrayWithObjects:@"Do you like this app?", @"Feedback", nil];
    [PLActionSheet actionSheetWithTitle:nil destructiveButtonTitle:nil buttons:buttons showFrom:self.viewToPresentSheet onDismiss:^(NSInteger buttonIndex){
        if (buttonIndex == [buttons indexOfObject:@"Do you like this app?"]) {
            [self like];
        } else if (buttonIndex == [buttons indexOfObject:@"Feedback"]) {
            [self feedback];
        }
    } onCancel:nil finally:nil];
}

- (IBAction)like {
    NSArray *buttons = [NSArray arrayWithObjects:@"Review in App Store", @"Share by Twitter", @"Share by Facebook", @"Share by Email", nil];
    [PLActionSheet actionSheetWithTitle:nil destructiveButtonTitle:nil buttons:buttons showFrom:self.viewToPresentSheet onDismiss:^(NSInteger buttonIndex){
        if (buttonIndex == 0) {
            [self review];
        } else if (buttonIndex == 1) {
            [self shareByTwitter];
        } else if (buttonIndex == 2) {
            [self shareByFacebook];
        } else if (buttonIndex == 3) {
            [self shareByEmail];
        }
    } onCancel:nil finally:nil];
}

- (IBAction)review {
    if ([[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:self.settings[REVIEWURL_KEY]]]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:-1 forKey:LAUNCHCOUNT_PREFERENCE]; // no more begging for reviews
    } else {
        // open AppStore failed, probably running in simulator
        [PRPAlertView showWithTitle:@"App Store unavailable" message:@"Unable to open the App Store for review, please try again later." buttonTitle:@"Continue"];
    }
}

- (IBAction)shareByTwitter {
    if (NSClassFromString(@"SLComposeViewController")) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetVC =
            [SLComposeViewController composeViewControllerForServiceType:
             SLServiceTypeTwitter];
            [tweetVC setInitialText:@"I like this application and I think you should try it too."];
            [tweetVC addURL:[NSURL URLWithString:self.settings[DOWNLOADURL_KEY]]];
            [self.parentViewController presentViewController:tweetVC animated:YES completion:NULL];
        } else {
            [PRPAlertView showWithTitle:@"Twitter" message:@"Unable to send tweet: do you have an account set up?" cancelTitle:@"Continue" cancelBlock:nil otherTitle:nil otherBlock:nil];
        }
    } else {
        // TWTweetComposeViewController was deprecated in iOS 6.0
    }
}

- (IBAction)shareByFacebook {
    if (NSClassFromString(@"SLComposeViewController")) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *fbVC =
            [SLComposeViewController composeViewControllerForServiceType:
             SLServiceTypeFacebook];
            [fbVC setInitialText:@"I like this application and I think you should try it too."];
            [fbVC addURL:[NSURL URLWithString:self.settings[DOWNLOADURL_KEY]]];
            [self.parentViewController presentViewController:fbVC animated:YES completion:NULL];
        } else {
            [PRPAlertView showWithTitle:@"Facebook" message:@"Unable to post to Facebook: do you have an account set up?" cancelTitle:@"Continue" cancelBlock:nil otherTitle:nil otherBlock:nil];
        }
    } else {
        [PRPAlertView showWithTitle:@"Facebook" message:@"Posting to Facebook isn't available on this version of iOS" buttonTitle:@"Continue"];
    }
}

- (IBAction)shareByEmail {
    if (![MFMailComposeViewController canSendMail]) {
        [PRPAlertView showWithTitle:@"Mail error" message:@"This device is not configured to send email" buttonTitle:@"Continue"];
        return;
    }
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    mailer.mailComposeDelegate = self;
    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    NSString *appName = [bundleId pathExtension];
    //appName = [appName capitalizedString];
    
    [mailer setSubject:appName];
    
    [mailer setMessageBody:[NSString stringWithFormat:@"I like this application and I think you should try it too. %@", self.settings[DOWNLOADURL_KEY]] isHTML:NO];
    
    // Present the mail composition interface.
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.parentViewController presentViewController:mailer animated:YES completion:nil];
    
}

- (IBAction)feedback {
    if (![MFMailComposeViewController canSendMail]) {
        [PRPAlertView showWithTitle:@"Mail error" message:@"This device is not configured to send email" buttonTitle:@"Continue"];
        return;
    }
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    mailer.mailComposeDelegate = self;
    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    NSString *appName = [[bundleId lastPathComponent] pathExtension];
    //appName = [appName capitalizedString];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
    
    [mailer setSubject:[@"Feedback About " stringByAppendingString:appName]];
    [mailer setToRecipients:@[self.settings[SUPPORTEMAIL_KEY]]];
    
    NSString *body = [NSString stringWithFormat:@"AppID: %@\nVersion: %@\nLocale: %@\nDevice: %@\nOS: %@", bundleId, version, ((NSLocale *)[NSLocale currentLocale]).localeIdentifier, [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion];
    [mailer setMessageBody:body isHTML:NO];
    
    // Present the mail composition interface.
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.parentViewController presentViewController:mailer animated:YES completion:nil];
}

- (void)checkForRating {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger launchCount = [prefs integerForKey:LAUNCHCOUNT_PREFERENCE];
    NSInteger trigger = [self.settings[TRIGGERCOUNT_KEY] integerValue];
    NSLog(@"PLFeedback checking launch count: %ld of %ld", (long)launchCount, (long)trigger);
    if (launchCount >= trigger) {
        [prefs setInteger:-1 forKey:LAUNCHCOUNT_PREFERENCE];
        PRPAlertView *alert = [[PRPAlertView alloc] initWithTitle:@"Do you like this app?" message:@"Please rate it on the App Store!" cancelTitle:@"Never" cancelBlock:^(NSString *title){
            [prefs setInteger:(trigger+1) forKey:LAUNCHCOUNT_PREFERENCE];
        } otherTitle:@"Rate now" otherBlock:^(NSString *title){
            if ([title isEqualToString:@"Rate now"]) {
                [self review];
            } else if ([title isEqualToString:@"Later"]) {
                [prefs setInteger:0 forKey:LAUNCHCOUNT_PREFERENCE];
            }
        }];
        [alert addButtonWithTitle:@"Later"];
        [alert show];
    }
}

- (void)setup {} // hack to avoid dumb warnings

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error) NSLog(@"%s error sending email, result %ld: %@", __PRETTY_FUNCTION__, (long)result, [error localizedDescription]);
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
