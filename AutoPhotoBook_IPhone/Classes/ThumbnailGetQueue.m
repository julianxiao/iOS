//
//  ThumbnailGetQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailGetQueue.h"
#import "URLLoader.h"

@implementation ThumbnailGetQueue
@synthesize url;
@synthesize image;

- (void) run{
	NSString *imagePath  = [URLLoader resourcePathFor: self.url];
	self.image = [UIImage imageWithContentsOfFile:imagePath];
}

- (void) apply{
	UIImage *folder = [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"bigalbum" ofType: @"png"]];
	UIGraphicsBeginImageContext(folder.size);
	[folder drawAtPoint:CGPointMake(0,0)];
	[self.image drawAtPoint:CGPointMake(50 - self.image.size.width/2, 40 - self.image.size.height/2)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	((UIImageView *)self.target).image = newImage;
	UIGraphicsEndImageContext();
	[folder release];
	self.image = nil;
}

- (void) onStop{
}

- (BOOL) canSync{
    return NO;
}

- (void) dealloc {
	self.url = nil;
	self.image = nil;
	[super dealloc];
}
@end
