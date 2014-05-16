//
//  Pagination.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/25/09.
//  Copyright 2009 HP Labs. Most rights reserved.
//

#import "Pagination.h"
#import "Page.h"
#import "iphotobookThumbnailAppDelegate.h"
#import "GalleriesViewController.h"
#import "iphotobookThumbnailViewController.h"
#import "ThumbnailScrollView.h"
#import "ThumbsDataSource.h"


//----------------------------------------------------------------------------------------------------------------------//
@implementation Pagination

@synthesize paginationID;
@synthesize pages;
@synthesize unselected;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (id)init {																					
	if (self = [super init]) {
		self.paginationID	= 0;
		self.pages			= [NSMutableArray array];
		self.unselected		= [NSMutableArray array];
	}
	
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (id)mutableCopyWithZone:(NSZone *)zone												
{
	Pagination	*copy   = [[[self class] allocWithZone: zone] init];	
	copy.paginationID	= self.paginationID;
	
	for (Page *ourPage in self.pages) {
		Page  *newPage	= [[Page alloc] init];
		newPage.pageNum	  = ourPage.pageNum;
		newPage.imageNums = ourPage.imageNums;					// uses custom setter that does a mutable deep copy
		[copy.pages addObject:newPage];
	}
	
	copy.unselected	= self.unselected;
	
	return copy;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) dealloc {
	self.pages = nil;
	self.unselected = nil;
	
	[super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark custom accessors
//----------------------------------------------------------------------------------------------------------------------//
- (void) setPages:(NSMutableArray *)thePages {
	if (pages != thePages) {
		[pages	release];
		pages = [thePages mutableCopy];
	}
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark utility
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)description									//:(Pagination *)pagination line:(int)lineNum 
{
	NSMutableString *stringToPrint	= [NSMutableString string];
	NSMutableString *lineNumString  = [NSMutableString stringWithFormat:@"\npagination num = %d", self.paginationID];

	// round-about way to get to datasource -------------------	
	iphotobookThumbnailAppDelegate		*appDelegate = [UIApplication sharedApplication].delegate;
	GalleriesViewController				*vc1		 = appDelegate.viewController;
	iphotobookThumbnailViewController	*vc2		 = vc1.thumbnailViewController;
	ThumbnailScrollView					*vc3		 = vc2.thumbnailScrollView;
	ThumbsDataSource					*datasource	 = vc3.datasource;
	NSUInteger  clusterAnalysisPageChoice = datasource.actualPaginationChoice;
	
	if (self.paginationID == clusterAnalysisPageChoice)										
		[lineNumString appendString:[NSString stringWithFormat:
									 @"   <-- suggestedPaginationChoice (number of pages = %d)", 
									 self.paginationID + 1]];
	[lineNumString appendString:@"\n"];
	[stringToPrint appendString:lineNumString];
	//----------------------------------------------------------	
		
	for (Page *page in self.pages)															// list images in each page
		[stringToPrint appendString:[NSString stringWithFormat:@"%@", [page description]]];				
	
	// unselected images
	NSMutableString *unselectedImages = [NSMutableString stringWithFormat:@"   unselected: "];
	if (self.unselected.count > 0) 
		for (NSString *imageNum in self.unselected) 
			[unselectedImages appendString:[NSString stringWithFormat:@"%@  ", imageNum]];
	else
		[unselectedImages appendString:@"none"];
	
	[stringToPrint appendString:unselectedImages];		
	[stringToPrint appendString:@"\n"];
	
	return stringToPrint;
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark storage
//----------------------------------------------------------------------------------------------------------------------//
- (void)encodeWithCoder:(NSCoder *)coder													// not used yet, should be
{
	[coder encodeInteger:paginationID	forKey: @"paginationID"	];
	[coder encodeObject:pages			forKey: @"pages"		];
	[coder encodeObject:unselected		forKey: @"unselected"	];
}
//----------------------------------------------------------------------------------------------------------------------//
-(id)initWithCoder:(NSCoder*)coder															// not used yet, should be
{
	self.paginationID	= [coder decodeIntegerForKey:@"paginationID"];
	self.pages			= [coder decodeObjectForKey: @"pages"		];
	self.unselected		= [coder decodeObjectForKey: @"unselected"	];

	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
@end