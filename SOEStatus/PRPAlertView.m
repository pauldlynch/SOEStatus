//
//  PRPAlertView.m
//  PRPAlertView
//
//  Created by Matt Drance on 1/24/11.
//  Copyright 2011 Bookhouse Software LLC. All rights reserved.
//

#import "PRPAlertView.h"

// START: PrivateInterface
@interface PRPAlertView ()

@property (nonatomic, copy) PRPAlertBlock cancelBlock;
@property (nonatomic, copy) PRPAlertBlock otherBlock;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *otherButtonTitle;

@end
// END: PrivateInterface

@implementation PRPAlertView

@synthesize cancelBlock;
@synthesize otherBlock;
@synthesize cancelButtonTitle;
@synthesize otherButtonTitle;

// START:ShowNoHandler
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle {
    [self showWithTitle:title message:message
            cancelTitle:buttonTitle cancelBlock:nil
             otherTitle:nil otherBlock:nil];
}
// END:ShowNoHandler

// START:ShowWithTitle        
+ (void)showWithTitle:(NSString *)title 
              message:(NSString *)message 
          cancelTitle:(NSString *)cancelTitle 
          cancelBlock:(PRPAlertBlock)cancelBlk
           otherTitle:(NSString *)otherTitle
           otherBlock:(PRPAlertBlock)otherBlk {
    [[[self alloc] initWithTitle:title message:message
                      cancelTitle:cancelTitle cancelBlock:cancelBlk
                       otherTitle:otherTitle otherBlock:otherBlk] show];                           
}
// END:ShowWithTitle

// START:InitWithTitle
- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message 
        cancelTitle:(NSString *)cancelTitle 
        cancelBlock:(PRPAlertBlock)cancelBlk
         otherTitle:(NSString *)otherTitle
         otherBlock:(PRPAlertBlock)otherBlk {
    if ((self = [super initWithTitle:title 
                             message:message
                            delegate:self
                   cancelButtonTitle:cancelTitle 
                   otherButtonTitles:otherTitle, nil])) {
        if (cancelBlk == nil && otherBlk == nil) {
            self.delegate = nil;
        }
        self.cancelButtonTitle = cancelTitle;
        self.otherButtonTitle = otherTitle;
        self.cancelBlock = cancelBlk;
        self.otherBlock = otherBlk;
    }
    return self;
}
// END:InitWithTitle

#pragma mark -
#pragma mark UIAlertViewDelegate
// START:DelegateImpl
- (void)alertView:(UIAlertView *)alertView
willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:self.cancelButtonTitle]) {
        if (self.cancelBlock) self.cancelBlock(buttonTitle);
        //} else if ([buttonTitle isEqualToString:self.otherButtonTitle]) {
    } else {
        if (self.otherBlock) self.otherBlock(buttonTitle);
    }
}
// END:DelegateImpl

- (void)dealloc {
    cancelButtonTitle = nil;
    otherButtonTitle = nil;
    cancelBlock = nil;
    otherBlock = nil;
}

@end