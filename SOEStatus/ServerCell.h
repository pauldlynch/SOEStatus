//
//  ServerCell.h
//  SOEStatus
//
//  Created by Paul Lynch on 06/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPNibBasedTableViewCell.h"

@class SOEServer;

@interface ServerCell : PRPNibBasedTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *serverName;
@property (nonatomic, weak) IBOutlet UILabel *region;
@property (nonatomic, weak) IBOutlet UILabel *age;
@property (nonatomic, weak) IBOutlet UILabel *status;
@property (nonatomic, weak) IBOutlet UIButton *statusImage;
@property (nonatomic, weak) IBOutlet UIImageView *watchStatus;

@property (nonatomic, strong) SOEServer *server;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) UIViewController *vcForAlerts;

- (IBAction)toggleWatch:(id)sender;

@end
