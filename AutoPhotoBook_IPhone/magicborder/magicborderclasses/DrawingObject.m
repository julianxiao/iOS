//
//  DrawingObject.m
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-15.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import "DrawingObject.h"


@implementation DrawingObject

@synthesize box, repeat, mat, imgname;

- (void)dealloc {
	[imgname release];
	[super dealloc];
}

@end
