//
//  FlickrKenBurnsView.h
//  FlickrTest
//
//  Created by Paul Lynch on 23/05/2013.
//  Copyright (c) 2013 Paul Lynch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBKenBurnsView.h"

@interface FlickrKenBurnsView : KenBurnsView

- (void)animateWithSearch:(NSString *)searchString apiKey:(NSString *)apiKey transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape;

@end
