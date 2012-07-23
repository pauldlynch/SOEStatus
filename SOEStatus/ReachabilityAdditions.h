//
//  ReachabilityAdditions.h
//  Oetker
//
//  Created by Paul Lynch on 20/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "Reachability.h"

@interface Reachability (ReachabilityAdditions)

+ (BOOL)checkReachability:(NSURL *)url;

@end
