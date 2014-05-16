//
//  VersionMenu.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "VersionMenu.h"


@implementation VersionMenu

@synthesize vid, menuitems;


- (void)dealloc {
	[vid release];
	[menuitems release];
	[super dealloc];
}

@end
