//
//  PLCategories.m
//
//  Created by Paul Lynch on 01/06/2009.
//  Copyright 2009 - 2013 P & L Systems. All rights reserved.
//

#import "PLCategories.h"

@implementation NSString (HTML)

-(NSString *)pl_stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

@end

@implementation NSString (Base64)

+ (NSString *)base64:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSString *)base64 {
	NSData *rawBytes = [self dataUsingEncoding:NSASCIIStringEncoding];
    return [NSString base64:(const uint8_t *)rawBytes.bytes length:rawBytes.length];
}

// I have put this in NSString, but arguably should be in NSNumber,
// and use a NSNumberFormatter with valid rounding
- (NSString *)memoryFormatted {
	int size, fraction = 0;
	size = [self intValue];
	NSString *formatString = @"%d";
	if (size == 1) formatString = NSLocalizedString(@"%d byte", @"%d byte");
	else if (size < 1000) {
		formatString = NSLocalizedString(@"%d bytes", @"%d bytes");
	} else if (size < 1000000) {
		formatString = NSLocalizedString(@"%d.%d KB", @"%d.%d KB");
		fraction = size % 1000;
		size = size / 1000;
	} else if (size < 1000000000) {
		formatString = NSLocalizedString(@"%d.%d MB", @"%d.%d MB");
		fraction = size % 1000000;
		size = size / 1000000;
	} else {
		formatString = NSLocalizedString(@"%d.%d GB", @"%d.%d GB");
		fraction = size % 1000000000;
		size = size / 1000000000;
	}
	// round fraction part
	while (fraction > 100) fraction /= 10;
	return [NSString stringWithFormat:formatString, size, fraction];
}

@end

@implementation NSURL (REST)

- (NSURL *)urlByAddingPath:(NSString *)path parameters:(NSDictionary *)parameters; {
    NSURL *requestURL = [self URLByAppendingPathComponent:path];
    NSString *requestString = [requestURL absoluteString];
    if (parameters) {
        requestString = [requestString stringByAppendingString:@"?"];
        BOOL first = YES;
        for (NSString *key in [parameters allKeys]) {
            if (!first) {
                requestString = [requestString stringByAppendingString:@"&"];
            }
            requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [[[parameters objectForKey:key] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            first = NO;
        }
    }
    return [NSURL URLWithString:requestString];
}

@end


@implementation NSMutableArray (Shuffling)

- (void)shuffle {
    NSUInteger count = [self count];
    if (count <= 1) return;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
