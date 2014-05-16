//
//  Pagination.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/25/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

//----------------------------------------------------------------------------------------------------------------------//
@interface Pagination : NSObject {
	NSUInteger			paginationID;
	NSMutableArray		*pages;										
	NSMutableArray		*unselected;
}

@property (nonatomic, assign)	NSUInteger			paginationID;
@property (nonatomic, retain)	NSMutableArray		*pages;			// array of Page
@property (nonatomic, retain)	NSMutableArray		*unselected;	// array of imageNums

#pragma mark custom accessors
- (void) setPages:	(NSMutableArray *)	thePages;					// custum setter

@end
//----------------------------------------------------------------------------------------------------------------------//
