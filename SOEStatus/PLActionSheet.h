//
//  PLActionSheet.h
//  SOEStatus
//
//  Created by Paul Lynch on 14/03/2012.
//  Copyright (c) 2012 P & L Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DismissBlock)(int buttonIndex);
typedef void (^CancelBlock)();

@interface PLActionSheet : UIActionSheet <UIActionSheetDelegate>

+ (void)actionSheetWithTitle:(NSString *)title                     
      destructiveButtonTitle:(NSString *)destructiveButtonTitle
                     buttons:(NSArray *)buttonTitles
                    showFrom:(id)view
//                    onDismiss:(void(^)(int index))dismissed                   
//                     onCancel:(void(^)())cancelled;
                   onDismiss:(DismissBlock)dismissed                   
                    onCancel:(CancelBlock)cancelled;

- (id)initWithTitle:(NSString *)title                     
destructiveButtonTitle:(NSString *)destructiveButtonTitle
            buttons:(NSArray *)buttonTitles
           showFrom:(id)view
          onDismiss:(DismissBlock)dismissed                   
           onCancel:(CancelBlock)cancelled;

- (void)show;

@end
