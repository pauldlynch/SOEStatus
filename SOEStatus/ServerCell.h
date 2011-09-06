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

@property (nonatomic, retain) IBOutlet UILabel *serverName;
@property (nonatomic, retain) IBOutlet UILabel *region;
@property (nonatomic, retain) IBOutlet UILabel *age;
@property (nonatomic, retain) IBOutlet UILabel *status;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
