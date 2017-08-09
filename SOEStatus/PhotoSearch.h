//
//  PhotoSearch.h
//  SOEStatus
//
//  Created by Paul Lynch on 06/08/2017.
//  Copyright © 2017 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoSearch : NSObject

@property (nonatomic, strong) NSMutableArray *photoURLs;
@property (nonatomic, strong) NSMutableArray *photoNames;

+ (void)callFlickr:(NSString *)urlString completion:(void (^)(NSDictionary *results))completion;
- (void)photoSearch:(NSString *)searchString completion:(void (^)(void))completion;

@end
