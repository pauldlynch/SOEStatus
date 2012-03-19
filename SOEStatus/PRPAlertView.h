//
//  PRPAlertView.h
//  PRPAlertView
//
//  Created by Matt Drance on 1/24/11.
//  Copyright 2011 Bookhouse Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// START:PRPAlertBlock
typedef void(^PRPAlertBlock)(NSString *title);
// END:PRPAlertBlock

@interface PRPAlertView : UIAlertView <UIAlertViewDelegate>

// START:ShowNoHandler
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle;
// END:ShowNoHandler

// START:ShowWithTitle
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message 
          cancelTitle:(NSString *)cancelTitle 
          cancelBlock:(PRPAlertBlock)cancelBlock
           otherTitle:(NSString *)otherTitle
           otherBlock:(PRPAlertBlock)otherBlock;
// END:ShowWithTitle

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(PRPAlertBlock)cancelBlock
         otherTitle:(NSString *)otherTitle
         otherBlock:(PRPAlertBlock)otherBlock;

@end
