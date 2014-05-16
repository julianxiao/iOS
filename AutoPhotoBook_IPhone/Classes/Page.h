//
//  Page.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/30/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ThumbsDataSource;

// NOTE:
//				   Page.pageNum		  is 0-based				
//	ThumbnailScrollView.pageNumber    is 1-based
//	ThumbnailScrollView.positionIndex is 1 based

//----------------------------------------------------------------------------------------------------------------------//
@interface Page : NSObject {
	NSInteger			pageNum;
	NSMutableArray		*imageNums;									// NSString, not NSNumber.  They are PhotoIDs
	BOOL				pageChanged;								// needs revision, à la Jun
	ThumbsDataSource	*datasource;
}

@property (nonatomic, assign)	NSInteger			pageNum;
@property (nonatomic, retain)	NSMutableArray		*imageNums;
@property (nonatomic, assign)	BOOL				pageChanged;
@property (nonatomic, retain)	ThumbsDataSource	*datasource;

- (void)	   setImageNums:  (NSMutableArray *)  nums;				// custum setter

@end
//----------------------------------------------------------------------------------------------------------------------//
