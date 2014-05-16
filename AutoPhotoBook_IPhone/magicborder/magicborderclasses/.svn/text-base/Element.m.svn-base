//
//  Element.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "Element.h"


@implementation Element

@synthesize position, type, style, width, height, x, y, layoutDensity, group, images, mode, marginpusher, alignment, version, setScale;
@synthesize xstep, ystep, oddXCount, oddYCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
		images = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[position release];
	[type release];
	[style release];
	[width release];
	[height release];
	[x release];
	[y release];
	[layoutDensity release];
	[group release];
	[images release];
	[mode release];
	[marginpusher release];
	[alignment release];
	[version release];
	[setScale release];
	[xstep release];
	[ystep release];
	[oddXCount release];
	[oddYCount release];
	[super dealloc];
}

@end
