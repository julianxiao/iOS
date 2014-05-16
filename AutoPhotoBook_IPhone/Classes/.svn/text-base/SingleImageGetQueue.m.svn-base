//
//  SingleImageGetQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SingleImageGetQueue.h"
#import "URLLoader.h"

@implementation SingleImageGetQueue
@synthesize url;
@synthesize image;

- (void) run{
	if (self.url != nil) {
		NSData *data = [URLLoader resourceFor: self.url];
		self.image = [UIImage imageWithData: data];					
	}
}

- (void) apply{
	((UIImageView *)(self.target)).image = self.image;	
}

- (void) onStop{
}

//- (BOOL) canSync{
//    return [URLLoader hasResource: self.url];
//}

- (void) dealloc{
	self.image = nil;
	self.url = nil;
	[super dealloc];
}
@end
