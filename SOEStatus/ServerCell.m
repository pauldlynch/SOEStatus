//
//  ServerCell.m
//  SOEStatus
//
//  Created by Paul Lynch on 06/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "ServerCell.h"

@implementation ServerCell

@synthesize serverName, region, age, status, imageView;

- (void)dealloc {
    self.serverName = nil;
    self.region = nil;
    self.age = nil;
    self.status = nil;
    self.imageView = nil;
    [super dealloc];
}

@end
