//
//  BookLayoutData.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/31/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Pagination;
@class PageLayoutData;

//----------------------------------------------------------------------------------------------------------------------//
@interface BookLayoutData : NSObject {
	Pagination		*curPagination;										// starting point for book layout
	NSMutableArray	*pageLayouts;										// array of PageLayoutData, not used yet
}

@property (nonatomic, retain)  Pagination		*curPagination;	
@property (nonatomic, retain)  NSMutableArray	*pageLayouts;

@end
//----------------------------------------------------------------------------------------------------------------------//
