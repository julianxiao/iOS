//
//  AutoCropQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AutoCropQueue.h"
#import "URLLoader.h"

@implementation AutoCropQueue
@synthesize cropURL;

- (void) run{
	[URLLoader resourceFor: self.cropURL];
}

- (void) dealloc{
	self.cropURL = nil;
	[super dealloc];
}
@end
