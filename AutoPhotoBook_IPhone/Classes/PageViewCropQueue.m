//
//  PageViewCropQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PageViewCropQueue.h"
#import "DataLoaderQueue.h"
#import "URLLoader.h"
#import "JSON.h"
#import "PhotoPosition.h"

@implementation PageViewCropQueue
@synthesize imageURL;
@synthesize autocropURL;
@synthesize imageNum;
@synthesize position;
@synthesize scalingFactor;
@synthesize renderedPage;
@synthesize oneImageView;

- (void) run{
	NSString  *imagePath  = [URLLoader resourcePathFor: self.imageURL];		
	UIImage	  *image	  = [[UIImage alloc] initWithContentsOfFile: imagePath];
	NSData *data = [URLLoader resourceFor: self.autocropURL];
	NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	if ([data length] == 0 || [ret characterAtIndex: 0] != '{') {
		[ret release];
		ret = nil;
		data = [URLLoader resourceFor: self.autocropURL withCache: NO];
		ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	}
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *dic = [json objectWithString: ret error: nil];
	[json release];
	[ret release];
	ret = nil;
	
	NSString *sx = [dic valueForKey: @"startX"];
	float px = [sx floatValue];
	NSString *sy = [dic valueForKey: @"startY"];
	float py = [sy floatValue];
	NSString *sw = [dic valueForKey: @"width"];
	float pw = [sw floatValue];
	NSString *sh = [dic valueForKey: @"height"];
	float ph = [sh floatValue];
	
	if(pw == 0) pw = 1;
	if(ph == 0) ph = 1;
	
	CGImageRef originalImage, resizedImage;
	originalImage = [image CGImage];
	resizedImage = CGImageCreateWithImageInRect(originalImage, CGRectMake(px * CGImageGetWidth(originalImage), py * CGImageGetHeight(originalImage), pw * CGImageGetWidth(originalImage), ph * CGImageGetHeight(originalImage)));
	NSLog(@"crop result %@: %f, %f, %f, %f", self.imageURL, px * CGImageGetWidth(originalImage), py * CGImageGetHeight(originalImage), pw * CGImageGetWidth(originalImage), ph * CGImageGetHeight(originalImage));
	[image release];
	UIImage *newImage = [[UIImage alloc] initWithCGImage: resizedImage];
	CGImageRelease(resizedImage);
	UIImageView *imageView	= [[UIImageView alloc] initWithImage:newImage];
	[newImage release];
	
	CGRect rect = imageView.frame;		
	CGFloat height	  = self.scalingFactor*self.position.lowerRight.y - self.scalingFactor*self.position.upperLeft.y;
	CGFloat width     = self.scalingFactor*self.position.lowerRight.x - self.scalingFactor*self.position.upperLeft.x;
	
	rect.size.height  = height;
	rect.size.width   = width;
	rect.origin.x     = scalingFactor*position.upperLeft.x;						
	rect.origin.y     = scalingFactor*position.upperLeft.y;				
	
	imageView.frame			= rect;
	imageView.contentMode	= UIViewContentModeScaleAspectFill;
	imageView.clipsToBounds  = YES;
	imageView.tag = self.imageNum.intValue;
	NSLog(@"add image number:%d", imageView.tag);
	self.oneImageView = imageView;
	[imageView release];
}

- (void) apply{
	[self.renderedPage addSubview: self.oneImageView];
}

//- (BOOL) canSync{
//    return [URLLoader hasResource: self.imageURL] && [URLLoader hasResource: self.autocropURL];
//}

- (void) onStop{
}

- (void) dealloc {
	self.imageURL = nil;
	self.autocropURL = nil;
	self.imageNum = nil;
	self.position = nil;
	self.renderedPage = nil;
	self.oneImageView = nil;
	[super dealloc];
}
@end
