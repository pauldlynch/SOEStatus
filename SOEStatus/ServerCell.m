//
//  ServerCell.m
//  SOEStatus
//
//  Created by Paul Lynch on 06/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "ServerCell.h"
#import "WatchServer.h"
#import "SOEServer.h"

@implementation ServerCell

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}

- (void)setServer:(SOEServer *)server {
    _server = server;
    
    self.serverName.text = server.name;
    self.region.text = server.region;
    self.age.text = [self.dateFormatter stringFromDate:server.date];
    
    if ([[WatchServer sharedInstance] watchingServer:server]) {
        self.watchStatus.image = [UIImage imageNamed:@"tick.png"];
    } else {
        self.watchStatus.image = nil;
        
    }
    
    self.status.text = server.status;
    if ([server.status isEqualToString:@"low"]) {
        [self.statusImage setImage:[UIImage imageNamed:@"low_icon"] forState:UIControlStateNormal];
    } else if ([server.status isEqualToString:@"medium"]) {
        [self.statusImage setImage:[UIImage imageNamed:@"medium_icon"] forState:UIControlStateNormal];
    } else if ([server.status isEqualToString:@"high"]) {
        [self.statusImage setImage:[UIImage imageNamed:@"high_icon"] forState:UIControlStateNormal];
    } else if ([server.status isEqualToString:@"locked"]) {
        [self.statusImage setImage:[UIImage imageNamed:@"lock_icon"] forState:UIControlStateNormal];
    } else if ([server.status isEqualToString:@"down"]) {
        [self.statusImage setImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal];
    } else if ([server.status isEqualToString:@"missing"]) {
        [self.statusImage setImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal];
    }
}

- (IBAction)toggleWatch:(id)sender {
    if ([[WatchServer sharedInstance] watchingServer:self.server]) {
        [[WatchServer sharedInstance] removeWatch:self.server];
    } else {
        [[WatchServer sharedInstance] watchForServer:self.server];
    }
    [self setServer:self.server];
    
    if ([[WatchServer sharedInstance] watchingServer:self.server]) {
        if (NSClassFromString(@"UIUserNotificationSettings")) {
            NSLog(@"requesting notification permissions");
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NotificationPermissionRequested"]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server Watch Notifications"
                                                                               message:@"If you would like to receive notification alerts when your chosen servers change status, you should allow Notifications."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
                    [[UIApplication sharedApplication] performSelector:@selector(registerUserNotificationSettings:) withObject:notificationSettings afterDelay:0.1];
                }];
                [alert addAction:defaultAction];
                [self.vcForAlerts presentViewController:alert animated:YES completion:nil];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotificationPermissionRequested"];
            }
        } else { // iOS7 or earlier
        }
    }
}

@end
