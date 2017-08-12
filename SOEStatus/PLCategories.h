//
//  NSString+Base64.h
//  iHuddle
//
//  Created by Paul Lynch on 01/06/2009.
//  Copyright 2009 P & L Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

-(NSString *) pl_stringByStrippingHTML;

@end

@interface NSString (Base64)

- (NSString *)base64;

- (NSString *)memoryFormatted;

@end

@interface NSURL (REST)

- (NSURL *)urlByAddingPath:(NSString *)path parameters:(NSDictionary *)parameters;

@end

@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end
