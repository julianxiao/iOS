//
//  SetupImageViewQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SetupImageViewQueue.h"
#import "ThumbnailScrollView.h"

@implementation SetupImageViewQueue
@synthesize imageView;
@synthesize imgName;
@synthesize pageNum;
@synthesize imgNameIndex;
@synthesize imgPageIndex;
@synthesize imgScreenIndex;

- (void) run{
}

- (void) apply{
	[((ThumbnailScrollView *)self.target) setUpImageView: self.imageView
											  forPageNum: self.pageNum
											   imageName: self.imgName
										  imageNameIndex: self.imgNameIndex
										  imagePageIndex: self.imgPageIndex
									 andImageScreenIndex: self.imgScreenIndex];
	[((ThumbnailScrollView *)self.target) updateLayout];
}

- (void) onStop{
}

- (void) dealloc {
	self.imageView = nil;
	self.imgName = nil;
	[super dealloc];
}
@end
