//
//  SOEStatusAppDelegate.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "SOEStatusAppDelegate.h"
#import "PLFeedback.h"
#import "SOEStatusAPI.h"
#import "SOEGame.h"
#import "WatchServer.h"

@implementation SOEStatusAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

+ (void)initialize {
    if ([self class] == [SOEStatusAppDelegate class]) {
        //NSLog(@"%s", __PRETTY_FUNCTION__);
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NotificationPermissionRequested": [NSNumber numberWithBool:NO]}];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
#if TARGET_IPHONE_SIMULATOR
    // where are you?
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:600.0];
    NSLog(@"watching: %@", [[WatchServer sharedInstance] watches]);
    NSString *backgroundRefreshStatus = @"";
    UIBackgroundRefreshStatus status = [[UIApplication sharedApplication] backgroundRefreshStatus];
    if (status & UIBackgroundRefreshStatusAvailable) backgroundRefreshStatus = [backgroundRefreshStatus stringByAppendingString:@"Available "];
    if (status & UIBackgroundRefreshStatusDenied) backgroundRefreshStatus = [backgroundRefreshStatus stringByAppendingString:@"Denied "];
    // TODO: why does this line give a "code will never be executed warning"?
    //if (status & UIBackgroundRefreshStatusRestricted) backgroundRefreshStatus = [backgroundRefreshStatus stringByAppendingString:@"Restricted "];
    NSLog(@"backgroundRefreshStatus: %@", backgroundRefreshStatus);
    
    /* UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
    [application registerUserNotificationSettings:notificationSettings];*/
    
    // Remote notifications
    // [application registerForRemoteNotifications];

    if (self.splitViewController) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
        } else {
            self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
        }
        self.window.rootViewController = self.splitViewController;
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Add the navigation controller's view to the window and display.
        self.window.rootViewController = self.navigationController;
    } else {
        self.window.rootViewController = self.toolbarController;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)backgroundFetch {
    [self application:[UIApplication sharedApplication] performFetchWithCompletionHandler:^(UIBackgroundFetchResult result){
        NSLog(@"forced background fetch: %lu, time remaining: %f", (unsigned long)result, [[UIApplication sharedApplication] backgroundTimeRemaining]);
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self backgroundFetch];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"background fetch called!");
    NSLog(@"watching: %@", [[WatchServer sharedInstance] watches]);
    if (![[WatchServer sharedInstance] watching]) {
        NSLog(@"No Data Result.");
        completionHandler(UIBackgroundFetchResultNoData);
    }
    [SOEStatusAPI getStatuses:^(PLRestful *api, id object, NSInteger status, NSError *error){
        if (error) {
            NSLog(@"API Error: %@", error);
            completionHandler(UIBackgroundFetchResultFailed);
        } else {
            NSLog(@"New Data Result.");
            [[WatchServer sharedInstance] notify];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
}

#pragma mark handle notifications

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, notification.description);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Status Changed" message:notification.alertBody delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, deviceToken);
    // should pass token to remote push server
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, userInfo);
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Status Changed" message:[userInfo description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    handler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"%s Notification types: %@", __PRETTY_FUNCTION__, notificationSettings);
}

@end
