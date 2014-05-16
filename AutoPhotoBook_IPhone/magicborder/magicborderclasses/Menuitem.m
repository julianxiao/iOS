//
//  Menuitem.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "Menuitem.h"


@implementation Menuitem

@synthesize label, imagesrc;

- (void)dealloc {
	[label release];
	[imagesrc release];
	[super dealloc];
}

@end
