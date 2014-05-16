//
//  PageLayoutData.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/31/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "PageLayoutData.h"
#import "Page.h";
#import "PhotoPosition.h";

//----------------------------------------------------------------------------------------------------------------------//
@implementation PageLayoutData

@synthesize ourPageID;
@synthesize BRICinput;
@synthesize BRICoutput;
@synthesize photoPositions;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (id)initWithBRICinput:(NSString *)input BRICoutput:(NSString *)output ourPageID:(NSInteger)pageID
{
	if (self = [super init]) {
		self.BRICinput	= input;
		self.BRICoutput = output;
		self.ourPageID  = pageID;

		NSArray			*itemsReturned  = [NSArray arrayWithArray:[self.BRICoutput componentsSeparatedByString:@";"]];	
		NSMutableArray  *imagePositions = [[NSMutableArray alloc] init];
		NSMutableArray  *imagePosition  = [[NSMutableArray alloc] init];
		
		NSInteger i = 0;
		for (NSString *item in itemsReturned) {				// parse the BRICoutput string (data for 1 page)
			[imagePosition addObject:item];		
			if (i % 6 == 5) {								// pack up each group of six items into a PhotoPosition object
				PhotoPosition *aPhotoPosition = [[PhotoPosition alloc] initWithImagePosition:imagePosition];
				[imagePositions addObject:aPhotoPosition];
				[aPhotoPosition release];					// release added by KC, 06may09 •••
				
				[imagePosition removeAllObjects];
			}		
			i++;
		}
		self.photoPositions = imagePositions;				// convert NSMutableArray to NSArray
		[imagePositions release];
		[imagePosition  release];							// release the last one from loop, added by KC 06may09 •••
	}
	
	return self;
}	
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.BRICinput = nil;
	self.BRICoutput = nil;
	self.photoPositions = nil;
	
	[super  dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)description {
	NSMutableString *stringToPrint = [NSMutableString string];

	[stringToPrint appendString:[NSString stringWithFormat:@"\nourpageID     = %d",		 ourPageID ]];
	[stringToPrint appendString:[NSString stringWithFormat:@"\ninput  string = %@",      BRICinput ]];
	[stringToPrint appendString:[NSString stringWithFormat:@"\noutput string = %@\n",    BRICoutput]];
	[stringToPrint appendString:[NSString stringWithFormat:@"\n    LAYOUT FOR ONE PAGE --"		]];

	for (PhotoPosition *photo in self.photoPositions)			
		[stringToPrint appendString:[NSString stringWithFormat:@"%@", photo] ];
	
	[stringToPrint appendString:[NSString stringWithFormat:@"\n"] ];

	return [stringToPrint retain];	
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (UIView *)layOutPage							// not currently used.  This is view-action and is now in PageView class
{
	for (PhotoPosition *position in photoPositions) {
		NSLog(@"In PageLayoutData.  position = %@,", position);												// temp debug
		
		//  < instantiate UIViews (inside it) to be set up with 1st page photos >  

	}
	
	return nil;
}
//----------------------------------------------------------------------------------------------------------------------//
@end
