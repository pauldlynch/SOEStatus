//
//  FlickrKenBurnsView.m
//  FlickrTest
//
//  Created by Paul Lynch on 23/05/2013.
//  Copyright (c) 2013 Paul Lynch. All rights reserved.
//

#import "FlickrKenBurnsView.h"

@interface FlickrKenBurnsView ()

@property (nonatomic, retain) NSMutableArray *photoURLs;
@property (nonatomic, retain) NSMutableArray *photoURLStrings;
@property (nonatomic, retain) NSMutableArray *photoNames;

- (void)loadFlickrPhotoSearch:(NSString *)searchString apiKey:(NSString *)apiKey;
@end

@implementation FlickrKenBurnsView

- (void)loadFlickrPhotoSearch:(NSString *)searchString apiKey:(NSString *)apiKey {
    self.photoURLs = [NSMutableArray array];
    self.photoURLStrings = [NSMutableArray array];
    self.photoNames = [NSMutableArray array];

    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=20&format=json&nojsoncallback=1&content_type=7&safe_search=2", apiKey, searchString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    if (!jsonData) {
        NSLog(@"%s failed call to Flickr API", __PRETTY_FUNCTION__);
        return;
    }
    NSError *error;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!results) {
        NSLog(@"%s bad JSON from Flickr API: %@", __PRETTY_FUNCTION__, error);
        return;
    }
    
    NSString *status = [results objectForKey:@"stat"];
    if ([status isEqualToString:@"ok"]) {
        NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
        for (NSDictionary *photo in photos) {
            NSString *title = [photo objectForKey:@"title"];
            [self.photoNames addObject:([title length] > 0 ? title : @"Untitled")];
            NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            [self.photoURLStrings addObject:photoURLString];
            [self.photoURLs addObject:[NSURL URLWithString:photoURLString]];
        }
    } else {
        NSLog(@"Flickr API not good: %@ code %@ '%@'", status, [results objectForKey:@"code"], [results objectForKey:@"message"]);
    }
}

- (void) animateWithSearch:(NSString *)searchString apiKey:(NSString *)apiKey transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape {
    [self loadFlickrPhotoSearch:searchString apiKey:apiKey];
    [super animateWithURLs:self.photoURLStrings transitionDuration:duration loop:shouldLoop isLandscape:inLandscape];
}

@end
