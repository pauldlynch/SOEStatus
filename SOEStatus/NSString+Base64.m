//
//  NSString+Base64.m
//  iHuddle
//
//  Created by Paul Lynch on 01/06/2009.
//  Copyright 2009 P & L Systems. All rights reserved.
//

#import "NSString+Base64.h"

/* static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst) {
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3) {
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte) {
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; // shift left to next 6bit alignment
		
		if (d_len < 4) return 1; // error - dest too short 
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte) {
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	return 0;
}

@implementation NSString (Base64)

- (NSString *)base64 {
	NSData *encodeData = [self dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	// Base64 Encode
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	
	return [NSString stringWithCString:encodeArray length:strlen(encodeArray)];
}

@end */

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
	
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
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
