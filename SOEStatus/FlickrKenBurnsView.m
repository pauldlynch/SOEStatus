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

NSDictionary *sizeCodes;

+ (void)initialize {
    if (self == [FlickrKenBurnsView class]) {
        sizeCodes = [@{
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
                      } retain];
    }
}

+ (id)callFlickr:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    if (!jsonData) {
        NSLog(@"%s failed call to Flickr API", __PRETTY_FUNCTION__);
        return nil;
    }
    NSError *error;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!results) {
        NSLog(@"%s bad JSON from Flickr API: %@ '%@'", __PRETTY_FUNCTION__, error, [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease]);
        return nil;
    }
    
    NSString *status = [results objectForKey:@"stat"];
    if (![status isEqualToString:@"ok"]) {
        NSLog(@"Flickr API not good: %@ code %@ '%@'", status, [results objectForKey:@"code"], [results objectForKey:@"message"]);
    }
    
    return results;
}

- (void)loadFlickrPhotoSearch:(NSString *)searchString apiKey:(NSString *)apiKey {
    self.photoURLs = [NSMutableArray array];
    self.photoURLStrings = [NSMutableArray array];
    self.photoNames = [NSMutableArray array];

    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=20&format=json&nojsoncallback=1&content_type=7&safe_search=2", apiKey, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [FlickrKenBurnsView callFlickr:urlString];
    if (!results) {
        return;
    }
        
    NSArray *photos = [results valueForKeyPath:@"photos.photo"];
    for (NSDictionary *photo in photos) {
        NSString *title = [photo objectForKey:@"title"];
        [self.photoNames addObject:([title length] > 0 ? title : @"Untitled")];
   
        urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%@&format=json&nojsoncallback=1&photo_id=%@", apiKey, [photo objectForKey:@"id"]];
        NSString *photoURLString = [[[FlickrKenBurnsView callFlickr:urlString] valueForKeyPath:@"sizes.size.source"] lastObject];
        [self.photoURLStrings addObject:photoURLString];
        [self.photoURLs addObject:[NSURL URLWithString:photoURLString]];
    }
}

- (void)animateWithSearch:(NSString *)searchString apiKey:(NSString *)apiKey transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)inLandscape {
    [self loadFlickrPhotoSearch:searchString apiKey:apiKey];
    if ([self.photoURLStrings count]) {
        [super animateWithURLs:self.photoURLStrings transitionDuration:duration loop:shouldLoop isLandscape:inLandscape];
    } else {
        // halt animations, if we're lucky
        self.isLoop = NO;
    }
}

@end
