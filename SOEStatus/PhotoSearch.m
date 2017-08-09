//
//  PhotoSearch.m
//  SOEStatus
//
//  Created by Paul Lynch on 06/08/2017.
//  Copyright © 2017 P & L Systems. All rights reserved.
//

#import "PhotoSearch.h"
#import "FlickrAPIKey.h"
#import "ImgurAPIKey.h"

@implementation PhotoSearch

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

- (void)photoSearch:(NSString *)searchString completion:(void (^)(void))completion {
    self.photoURLs = [NSMutableArray array];
    self.photoNames = [NSMutableArray array];
    dispatch_group_t photo_group = dispatch_group_create();
    
    NSLog(@"PhotoSearch requesting: %@", searchString);
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=20&format=json&nojsoncallback=1&content_type=7&safe_search=2", FlickrAPIKey, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [PhotoSearch callFlickr:urlString completion:^(NSDictionary *results){
        NSArray *photos = [results valueForKeyPath:@"photos.photo"];
        NSLog(@"flickr returned %lu for %@", (unsigned long)[photos count], searchString);
        for (NSDictionary *photo in photos) {
            dispatch_group_enter(photo_group);
            NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=%@&format=json&nojsoncallback=1&photo_id=%@", FlickrAPIKey, [photo objectForKey:@"id"]];
            [PhotoSearch callFlickr:urlString completion:^(NSDictionary *results){
                NSString *photoURLString = [[results valueForKeyPath:@"sizes.size.source"] lastObject];
                [self.photoURLs addObject:[NSURL URLWithString:photoURLString]];
                NSString *title = [photo objectForKey:@"title"];
                [self.photoNames addObject:([title length] > 0 ? title : @"Untitled")];
                dispatch_group_leave(photo_group);
            }];
        }
    }];
    
    dispatch_group_notify(photo_group, dispatch_get_main_queue(), ^{
        if (completion) completion();
        NSLog(@"PhotoSearch returning: %lu", (unsigned long)self.photoURLs.count);
    });
}

@end
