//
//  Text.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "Text.h"


@implementation Text

@synthesize group, mode, tid, position, type, fontSize, fontWeight, fontStyle, fontFamily, fontColor, areaAlpha, textAlign, text, width, height, x, y, textAreaFontColors, version;


- (void)dealloc {
	[group release];
	[mode release];
	[tid release];
	[position release];
	[type release];
	[fontSize release];
	[fontWeight release];
	[fontStyle release];
	[fontFamily release];
	[fontColor release];
	[areaAlpha release];
	[textAlign release];
	[text release];
	[width release];
	[height release];
	[x release];
	[y release];
	[textAreaFontColors release];
	[version release];
	[super dealloc];
}

@end
