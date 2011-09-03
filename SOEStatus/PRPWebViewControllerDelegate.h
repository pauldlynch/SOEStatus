//
//  PRPWebViewControllerDelegate.h
//  SmartWebView
//
//  Created by Matt Drance on 3/21/11.
//  Copyright 2011 Bookhouse Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// START:PRPWebViewControllerDelegate
@class PRPWebViewController;

@protocol PRPWebViewControllerDelegate <NSObject>

@optional
- (void)webControllerDidFinishLoading:(PRPWebViewController *)controller;

- (void)webController:(PRPWebViewController *)controller 
 didFailLoadWithError:(NSError *)error;

- (BOOL)webController:(PRPWebViewController *)controller
shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;
@end
// END:PRPWebViewControllerDelegate