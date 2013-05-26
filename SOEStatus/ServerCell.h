//
//  ServerCell.h
//  SOEStatus
//
//  Created by Paul Lynch on 06/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPNibBasedTableViewCell.h"

@interface ServerCell : PRPNibBasedTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *serverName;
@property (nonatomic, strong) IBOutlet UILabel *region;
@property (nonatomic, strong) IBOutlet UILabel *age;
@property (nonatomic, strong) IBOutlet UILabel *status;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end
