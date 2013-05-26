//
//  PLActionSheet.m
//  SOEStatus
//
//  Created by Paul Lynch on 14/03/2012.
//  Copyright (c) 2012 P & L Systems. All rights reserved.
//

#import "PLActionSheet.h"

@interface PLActionSheet ()

@property (nonatomic, copy) DismissBlock dismissBlock;
@property (nonatomic, copy) VoidBlock cancelBlock;
@property (nonatomic, copy) VoidBlock finalBlock;
@property (nonatomic, strong) id view;

@end


@implementation PLActionSheet

@synthesize dismissBlock, cancelBlock, finalBlock, view;

+ (void)actionSheetWithTitle:(NSString *)title                     
      destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     buttons:(NSArray *)buttonTitles
                    showFrom:(id)view
                   onDismiss:(DismissBlock)dismissed                   
                    onCancel:(VoidBlock)cancelled
                     finally:(VoidBlock)finally {
    [[[self alloc] initWithTitle:title destructiveButtonTitle:destructiveButtonTitle buttons:buttonTitles showFrom:view onDismiss:dismissed onCancel:cancelled finally:finally] show];
}

- (id)initWithTitle:(NSString *)title                     
destructiveButtonTitle:(NSString *)destructiveButtonTitle
            buttons:(NSArray *)buttonTitles
           showFrom:(id)aView
          onDismiss:(DismissBlock)dismissed                   
           onCancel:(VoidBlock)cancelled
            finally:(VoidBlock)finally {
    self  = [self initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    
    for (NSString *thisButtonTitle in buttonTitles)
        [self addButtonWithTitle:thisButtonTitle];
    
    //if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
        self.cancelButtonIndex = [buttonTitles count];
    //}
    
    if (destructiveButtonTitle)
        self.cancelButtonIndex ++;
    
    self.dismissBlock = dismissed;
    self.cancelBlock = cancelled;
    self.finalBlock = finally;
    self.view = aView;
    
    return self;
}


- (void)show {
    if (view) {
        if ([view isKindOfClass:[UITabBar class]]) {
            [self showFromTabBar:(UITabBar*) view];
        } else if ([view isKindOfClass:[UIView class]]) {
            [self showInView:view];
        } else if ([view isKindOfClass:[UIBarButtonItem class]]) {
            [self showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
        }
    } else {
        [self showInView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [actionSheet cancelButtonIndex]) {
		if (self.cancelBlock) self.cancelBlock();
	} else {
        if (self.dismissBlock) self.dismissBlock(buttonIndex);
    }
    if (self.finalBlock) self.finalBlock();
}

@end
