//
//  Page.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/30/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "Page.h"
#import "iphotobookThumbnailAppDelegate.h"
#import "iphotobookThumbnailViewController.h"
#import "ThumbnailScrollView.h"
#import "ThumbsDataSource.h"
#import "GalleriesViewController.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation Page

@synthesize pageNum;
@synthesize imageNums;
@synthesize pageChanged;
@synthesize datasource;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (id)init {																					
	if (self = [super init]) {
		self.pageNum	 = -2;												// -2, so it stands out if not assigned to
		self.imageNums	 = [NSMutableArray array];
		self.pageChanged = YES;
	}
	
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (id)mutableCopyWithZone:(NSZone *)zone									// never called, why not?	
{
	Page   *copy  = [[[self class] allocWithZone: zone] init];	
	copy.pageNum	= self.pageNum;
//	copy.imageNums	= [self.imageNums mutableCopy];
	copy.imageNums	= self.imageNums;
	
	NSLog(@"************* in Page.mutableCopyWithZone *************");		// never called !?
	
	return copy;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) dealloc {
	self.imageNums = nil;
	self.datasource = nil;
	
	[super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark custom accessors
//----------------------------------------------------------------------------------------------------------------------//
- (void) setImageNums:(NSMutableArray *)nums {
	if (imageNums != nums) {
		[imageNums	release];
		imageNums = [nums retain];
		
		if ([self datasource].keepPageChangedFalseWhileLoading)				// needs revision, à la Jun
			self.pageChanged = NO;
		else
			self.pageChanged = YES;			
	}
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark utility
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)description									
{
	NSMutableString *stringToPrint	= [NSMutableString string];
	
	// images in this page
	for (NSString *num in self.imageNums) {
		[stringToPrint appendString:[NSString stringWithFormat:@"\t%@", num]];				
	}
	[stringToPrint appendString:@"\n"];
	
	return [stringToPrint retain];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark storage
//----------------------------------------------------------------------------------------------------------------------//
- (void)encodeWithCoder:(NSCoder *)coder														// not used yet, should be
{
	[coder encodeInteger:pageNum		forKey: @"pageNum"		];
	[coder encodeObject:imageNums		forKey: @"imageNums"	];
}
//----------------------------------------------------------------------------------------------------------------------//
-(id)initWithCoder:(NSCoder*)coder																// not used yet, should be
{		
	self.pageNum		= [coder decodeIntegerForKey:@"pageNum"		];
	self.imageNums		= [coder decodeObjectForKey: @"imageNums"	];
	
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark utility methods
//----------------------------------------------------------------------------------------------------------------------//
- (iphotobookThumbnailAppDelegate *)appDelegate		
{
	return (iphotobookThumbnailAppDelegate *)[[UIApplication sharedApplication] delegate];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (ThumbsDataSource *)datasource
{
	GalleriesViewController			   *viewController1 = (GalleriesViewController			 *)[self appDelegate].viewController;	
	iphotobookThumbnailViewController  *viewController2 = (iphotobookThumbnailViewController *)viewController1.thumbnailViewController;
	ThumbnailScrollView				   *scrollView		= (ThumbnailScrollView				 *)viewController2.thumbnailScrollView;
	
	return scrollView.datasource;
}
//----------------------------------------------------------------------------------------------------------------------//
@end