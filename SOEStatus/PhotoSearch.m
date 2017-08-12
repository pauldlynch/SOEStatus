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
#import "PLCategories.h"

@implementation PhotoSearch

+ (void)fetchJSONFromRequest:(NSURLRequest *)request completion:(void (^)(NSDictionary *results))completion {
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data) {
            NSLog(@"%s failed call to API: %@", __PRETTY_FUNCTION__, error);
            if (completion) completion(nil);
            return;
        }
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!results) {
            NSLog(@"%s bad JSON from API: %@ '%@'", __PRETTY_FUNCTION__, error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
        
        if (completion) completion(results);
    }];
    [downloadTask resume];
}

+ (void)fetchJSONFromURL:(NSURL *)url completion:(void (^)(NSDictionary *results))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *authHeaderValue = [NSString stringWithFormat:@"Client-ID %@", ImgurAPIKey];
    [request addValue:authHeaderValue forHTTPHeaderField:@"authorization"];
    
    [PhotoSearch fetchJSONFromRequest:request completion:completion];
}

+ (void)callFlickr:(NSString *)urlString completion:(void (^)(NSDictionary *results))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    [PhotoSearch fetchJSONFromURL:url completion:^(NSDictionary *results){
        NSString *status = [results objectForKey:@"stat"];
        if (![status isEqualToString:@"ok"]) {
            NSLog(@"Flickr API not good: %@ code %@ '%@'", status, [results objectForKey:@"code"], [results objectForKey:@"message"]);
        }
        
        if (completion) completion(results);
    }];
}

+ (void)callImgur:(NSString *)urlString completion:(void (^)(NSDictionary *results))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *authHeaderValue = [NSString stringWithFormat:@"Client-ID %@", ImgurAPIKey];
    [request addValue:authHeaderValue forHTTPHeaderField:@"authorization"];
    
    [PhotoSearch fetchJSONFromRequest:request completion:^(NSDictionary *results){
        NSNumber *success = [results objectForKey:@"success"];
        if (![success boolValue]) {
            NSLog(@"Imgur API not good: %@ status %@", success, [results objectForKey:@"status"]);
        }
        
        if (completion) completion(results);
    }];
}

- (void)photoSearch:(NSString *)searchString completion:(void (^)(void))completion {
    self.photoURLs = [NSMutableArray array];
    self.photoNames = [NSMutableArray array];
    dispatch_group_t photo_group = dispatch_group_create();
    
    NSLog(@"PhotoSearch requesting: %@", searchString);
    
    // start with queueing Flickr request
    dispatch_group_enter(photo_group);
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
        dispatch_group_leave(photo_group);
    }];
    
    // Now queue Imgur request
    dispatch_group_enter(photo_group);
    urlString = [NSString stringWithFormat:@"https://api.imgur.com/3/gallery/search/?q=%@", [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [PhotoSearch callImgur:urlString completion:^(NSDictionary *results){
        NSArray *photos = [results valueForKeyPath:@"data"];
        if (![photos isKindOfClass:[NSArray class]]) photos = nil; // returns dict on error
        NSLog(@"imgur returned %lu for %@", (unsigned long)[photos count], searchString);
        for (NSDictionary *photo in photos) {
            NSString *photoURLString = [photo objectForKey:@"link"];
            NSNumber *isAlbum = [photo objectForKey:@"is_album"];
            if (![isAlbum boolValue]) { // skip albums for now
                if ([photoURLString hasPrefix:@"http:"]) {
                    photoURLString = [photoURLString stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
                }
                NSURL *url = [NSURL URLWithString:photoURLString];
                [self.photoURLs addObject:url];
                NSString *title = [photo objectForKey:@"title"];
                [self.photoNames addObject:([title length] > 0 ? title : @"Untitled")];
            }
        }
        dispatch_group_leave(photo_group);
    }];
    
    dispatch_group_notify(photo_group, dispatch_get_main_queue(), ^{
        // now shuffle
        [self.photoURLs shuffle];
        if (completion) completion();
        NSLog(@"PhotoSearch returning: %lu", (unsigned long)self.photoURLs.count);
    });
}

@end
