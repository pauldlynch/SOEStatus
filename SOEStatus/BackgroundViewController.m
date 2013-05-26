//
//  BackgroundViewController.m
//  SOEStatus
//
//  Created by Paul Lynch on 25/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import "BackgroundViewController.h"
#import "FlickrAPIKey.h"
#import "FlickrKenBurnsView.h"
#import "RootViewController.h"
#import "SOEGame.h"

@interface BackgroundViewController ()

@end

@implementation BackgroundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gameChanged:(NSNotification *)notification {
    SOEGame *game = [[notification userInfo] objectForKey:@"game"];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, game.name);
    if (game.search) {
        [self.backgroundView animateWithSearch:game.search apiKey:FlickrAPIKey transitionDuration:15.0 loop:YES isLandscape:UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])];
    }
}

- (IBAction)togglePopover:(id)sender {
    if (self.statusPopover.isPopoverVisible) {
        [self.statusPopover dismissPopoverAnimated:YES];
    } else {
        [self.statusPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:SOEGameSelectedNotification object:nil];

    [self.backgroundView animateWithSearch:@"everquest2" apiKey:FlickrAPIKey transitionDuration:15.0 loop:YES isLandscape:UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])];
    
    RootViewController *rootVC = [[RootViewController alloc] init];
    UINavigationController *statusVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.statusPopover = [[UIPopoverController alloc] initWithContentViewController:statusVC];
    self.statusPopover.popoverContentSize = CGSizeMake(320.0, 568.0);
    [self.statusPopover presentPopoverFromBarButtonItem:self.statusButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
