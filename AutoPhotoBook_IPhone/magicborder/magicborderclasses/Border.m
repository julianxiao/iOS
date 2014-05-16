//
//  Border.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "Border.h"


@implementation Border

@synthesize path, cutout, topMargin, bottomMargin, leftMargin, rightMargin, width, height, type, aspectRatio;

- (void)dealloc {
	[path release];
	[cutout release];
	[topMargin release];
	[bottomMargin release];
	[leftMargin release];
	[rightMargin release];
	[width release];
	[height release];
	[type release];
	[aspectRatio release];
	[super dealloc];
}

@end
