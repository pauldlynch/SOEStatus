//
//  ReachabilityAdditions.m
//  Oetker
//
//  Created by Paul Lynch on 20/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "ReachabilityAdditions.h"

@implementation Reachability (ReachabilityAdditions)

+ (BOOL)checkReachability:(NSURL *)url {
    //TODO: use NSError to return reason rather than create an alert
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];	
	NetworkStatus netStatus = [hostReach currentReachabilityStatus];	
	if (netStatus == NotReachable) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"Network", @"Network") message:NSLocalizedString(@"Not connected to the Internet.", @"Not connected to the Internet.") buttonTitle:NSLocalizedString(@"Continue", @"Continue")];
        return NO;
    } else {
        hostReach = [Reachability reachabilityWithHostName:[url host]];
        NetworkStatus netStatus = [hostReach currentReachabilityStatus];	
        if (netStatus == NotReachable) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Network", @"Network") message:NSLocalizedString(@"Can't reach server.", @"Can't reach server.") buttonTitle:NSLocalizedString(@"Continue", @"Continue")];
            return NO;
        }
    }
    return YES;
}

@end
