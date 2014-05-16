//
//  Gallery.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 04/17/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "Gallery.h"


//----------------------------------------------------------------------------------------------------------------------//
@implementation Gallery

@synthesize title;
@synthesize icon;
@synthesize uuid;
@synthesize pagination;
@synthesize filemap;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.title = nil;
	self.filemap = nil;
	self.icon = nil;
	self.uuid = nil;
	self.pagination = nil;
	[super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//
@end
