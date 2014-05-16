//
//  Design.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "Design.h"


@implementation Design

@synthesize name, icon, style, layout, layoutDensityAmp, layoutDensityBlur, layoutDensityChannel, layoutDensityOffset;
@synthesize maxItemSize, minItemSize, sparseFactor, scaleWithItems, leftMargin, rightMargin, topMargin, bottomMargin;
@synthesize itemGap, type, width, height, x, y, version, numRandomVersions, numModes, defaultNumItems, mode;
@synthesize versionMenu, frame, elements, texts;

- (id) init
{
	self = [super init];
	if (self != nil) {
		elements = [[NSMutableArray alloc] init];
		texts = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[icon release];
	[style release];
	[layout release];
	[layoutDensityAmp release];
	[layoutDensityBlur release];
	[layoutDensityChannel release];
	[layoutDensityOffset release];
	[maxItemSize release];
	[minItemSize release];
	[sparseFactor release];
	[scaleWithItems release];
	[leftMargin release];
	[rightMargin release];
	[topMargin release];
	[bottomMargin release];
	[itemGap release];
	[type release];
	[width release];
	[height release];
	[x release];
	[y release];
	[version release];
	[numRandomVersions release];
	[numModes release];
	[defaultNumItems release];
	[mode release];
	[versionMenu release];
	[frame release];
	[elements release];
	[texts release];
    [super dealloc];
}


@end
