//
//  PPRWebViewController.h
//
//  Created by Matt Drance on 6/30/10.
//  Copyright 2010 Bookhouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPWebViewControllerDelegate.h"

@interface PRPWebViewController : UIViewController <UIWebViewDelegate> {
    NSURL *url;
    
    UIColor *backgroundColor;
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    
    BOOL shouldShowDoneButton;
    
    id <PRPWebViewControllerDelegate> __weak delegate;
}

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL shouldShowDoneButton;

@property (nonatomic, weak) id <PRPWebViewControllerDelegate> delegate;

- (void)reload;

@end