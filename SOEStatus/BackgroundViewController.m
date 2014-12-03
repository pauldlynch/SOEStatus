//
//  BackgroundViewController.m
//  SOEStatus
//
//  Created by Paul Lynch on 25/05/2013.
//  Copyright (c) 2013 P & L Systems. All rights reserved.
//

#import "BackgroundViewController.h"
#import "FlickrAPIKey.h"
#import "JBKenBurnsView.h"
#import "RootViewController.h"
#import "SOEGame.h"

@interface BackgroundViewController ()

@property (nonatomic, strong) NSMutableArray *photoURLs;
@property (nonatomic, strong) NSMutableArray *photoURLStrings;
@property (nonatomic, strong) NSMutableArray *photoNames;

+ (void)callFlickr:(NSString *)urlString completion:(void (^)(NSDictionary *results))completion;
- (void)loadFlickrPhotoSearch:(NSString *)searchString apiKey:(NSString *)apiKey completion:(void (^)(void))completion;

@end

@implementation BackgroundViewController

NSDictionary *sizeCodes;

+ (void)initialize {
    if (self == [BackgroundViewController class]) {
        sizeCodes = @{
                      @"Square": @"s",
                      @"Large Square": @"q",
                      @"Thumbnail": @"t",
                      @"Small": @"m",
                      @"Small 320": @"n",
                      @"Medium": @"-",
                      @"Medium 640": @"z",
                      @"Medium 800": @"c",
                      @"Large": @"b",
                      @"Original": @"o",
                      };
    }
}

+ (void)callFlickr:(NSString *)urlString completion:(void (^)(NSDictionary *results))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    if (!jsonData) {
        NSLog(@"%s failed call to Flickr API", __PRETTY_FUNCTION__);
        return;
    }
    NSError *error;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!results) {
        NSLog(@"%s bad JSON from Flickr API: %@ '%@'", __PRETTY_FUNCTION__, error, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        return;
    }
    
    NSString *status = [results objectForKey:@"stat"];
    if (![status isEqualToString:@"ok"]) {
        NSLog(@"Flickr API not good: %@ code %@ '%@'", status, [results objectForKey:@"code"], [results objectForKey:@"message"]);
    }
    
    if (completion) completion(results);
}

- (void)loadFlickrPhotoSearch:(NSString *)searchString apiKey:(NSString *)apiKey completion:(void (^)(void))completion {
    self.photoURLs = [NSMutableArray array];
    self.photoURLStrings = [NSMutableArray array];
    self.photoNames = [NSMutableArray array];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=20&format=json&nojsoncallback=1&content_type=7&safe_search=2", apiKey, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [BackgroundViewController callFlickr:urlString completion:^(NSDictionary *results){
        NSArray *photos = [results valueForKeyPath:@"photos.photo"];
        NSLog(@"flickr returned %d for %@", [photos count], searchString);
        for (NSDictionary *photo in photos) {
            NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%@&format=json&nojsoncallback=1&photo_id=%@", apiKey, [photo objectForKey:@"id"]];
            [BackgroundViewController callFlickr:urlString completion:^(NSDictionary *results){
                NSString *photoURLString = [[results valueForKeyPath:@"sizes.size.source"] lastObject];
                [self.photoURLStrings addObject:photoURLString];
                [self.photoURLs addObject:[NSURL URLWithString:photoURLString]];
                NSString *title = [photo objectForKey:@"title"];
                [self.photoNames addObject:([title length] > 0 ? title : @"Untitled")];
            }];
        }
    }];
}

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

- (void)animateWithSearch:(NSString *)searchString apiKey:(NSString *)apiKey transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape {
    dispatch_queue_t task_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(task_queue, ^{
        [self loadFlickrPhotoSearch:searchString apiKey:apiKey completion:^{}];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.photoURLStrings count]) {
                [self.backgroundView animateWithImages:self.photoURLs transitionDuration:duration loop:shouldLoop isLandscape:inLandscape];
            } else {
                // halt animations, if we're lucky
                [self.backgroundView flush];
            }
        });
    });
}

- (void)gameChanged:(NSNotification *)notification {
    SOEGame *game = [[notification userInfo] objectForKey:@"game"];
    NSLog(@"%s %@", __PRETTY_FUNCTION__, game.name);
    if (game.search) {
        [self animateWithSearch:game.search apiKey:FlickrAPIKey transitionDuration:15.0 loop:YES isLandscape:UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])];
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

    [self animateWithSearch:@"everquest2" apiKey:FlickrAPIKey transitionDuration:15.0 loop:YES isLandscape:UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])];
    
    RootViewController *rootVC = [[RootViewController alloc] init];
    UINavigationController *statusVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.statusPopover = [[UIPopoverController alloc] initWithContentViewController:statusVC];
    self.statusPopover.popoverContentSize = CGSizeMake(320.0, 440.0);
    
    // need to do this rather than call directly to allow rotation to landscape to happen first <shrug>
    [self performSelector:@selector(togglePopover:) withObject:self.statusButton afterDelay:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationPortrait;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
