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
    
    id <PRPWebViewControllerDelegate> delegate;
}

@property (nonatomic, retain) NSURL *url;

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL shouldShowDoneButton;

@property (nonatomic, assign) id <PRPWebViewControllerDelegate> delegate;

- (void)reload;

@end