//
//  PhotoPosition.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/31/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "PhotoPosition.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation PhotoPosition

@synthesize ourImageID;
@synthesize BRICsImageID;
@synthesize upperLeft;							
@synthesize lowerRight;							

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
//  Not currently used
- (id)initWithOurImageID:(NSString *)ourID BRICsID:(NSString *)BRICsID upperLeft: (CGPoint)uLeft 
			  lowerRight:(CGPoint)lRight {
//	if (self = [super init]) {
//		self.ourImageID		= ourID;
//		self.BRICsImageID	= BRICsID;
//		self.upperLeft		= uLeft;					
//		self.lowerRight		= lRight;	
//	}
	
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (id)initWithImagePosition:(NSArray *)imagePositionArray {										// designated initializer
	if (self = [super init]) {		
		self.ourImageID		= [imagePositionArray objectAtIndex:0];
		self.BRICsImageID	= [imagePositionArray objectAtIndex:1];		

		NSString *item2		= [imagePositionArray objectAtIndex:2];
		NSString *item3		= [imagePositionArray objectAtIndex:3];
		NSString *item4		= [imagePositionArray objectAtIndex:4];
		NSString *item5		= [imagePositionArray objectAtIndex:5];
		self.upperLeft		= CGPointMake(item2.floatValue, item3.floatValue);					
		self.lowerRight		= CGPointMake(item4.floatValue, item5.floatValue);	
	}
	
//	NSLog(@"PhotoPosition.  %@", [self description]);
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) dealloc {
	self.ourImageID = nil;
	self.BRICsImageID = nil;
	
	[super  dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)description {
	NSMutableString *stringToPrint = [NSMutableString string];
	
	[stringToPrint appendString:[NSString stringWithFormat:
	  @"\nour imageID    = %@ \nBRIC's imageID = %@ \ntop   left     = (%0.0f,%0.0f) \nlower right    = (%0.0f,%0.0f) \n",
										ourImageID, BRICsImageID, upperLeft.x, upperLeft.y, lowerRight.x, lowerRight.y ]];			
	return [stringToPrint retain];	
//	return stringToPrint;	
}
//----------------------------------------------------------------------------------------------------------------------//
@end
