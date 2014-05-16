//
//  Image.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "Image.h"


@implementation Image

@synthesize source, width, height, contentWidth, contentHeight;

- (void)dealloc {
	[source release];
	[width release];
	[height release];
	[contentWidth release];
	[contentHeight release];
	[super dealloc];
}

@end
