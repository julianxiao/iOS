//
//  Utils.m
//  iphotobookThumbnail
//
//  Created by Song on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Utils

+(NSString *) md5: (NSString *)data
{
	if (data == nil) {
		return nil;
	}
	const char *cStr = [data UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString 
			stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
}

+(CGImageRef)scaleCGImage: (CGImageRef) image withPrefix: (CGSize) size
{  
	CGContextRef    context = NULL;  
	void *          bitmapData;  
	int             bitmapByteCount;  
	int             bitmapBytesPerRow;  
	
	int width = size.width;  
	int height = size.height;
	
	bitmapBytesPerRow   = (width * 4);  
	bitmapByteCount     = (bitmapBytesPerRow * height);  
	
	bitmapData = malloc( bitmapByteCount );  
	if (bitmapData == NULL)  
	{  
		return nil;  
	}  
	memset(bitmapData, 0, bitmapByteCount);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();  
	context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,  
									 colorspace,kCGImageAlphaPremultipliedFirst);  
	CGColorSpaceRelease(colorspace);  
	
	if (context == NULL)  
		return nil;  
    //CGContextSetRGBFillColor (context, 0.9, 0.9, 0.9, 1);
    //CGContextFillRect (context, CGRectMake(0, 0, width, height));
	//CGContextEndTransparencyLayer (context);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
	CGImageRef imgRef = CGBitmapContextCreateImage(context);  
	CGContextRelease(context);  
	free(bitmapData);  
	
	return imgRef;  
}

@end
