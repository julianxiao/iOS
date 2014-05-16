//
//  ThumbnailImageView.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

//----------------------------------------------------------------------------------------------------------------------//
@interface ThumbnailImageView : UIView {
	
	NSString		*photoName;
	NSUInteger		photoID;				// uniquely identifies an image & should be held constant	
	NSUInteger		positionIndex;			// replaces UIView's "tag", now available for other purposes, & "imageNumber"
	NSInteger		pageNumber;
	BOOL			pageBreak;
	UIImageView		*badgeView;
	
	// for touch event records
	CGPoint			startLocation;
	NSTimeInterval	startTime;	
	CGPoint			lastTouchPoint;
	BOOL			disableScrolling;
}

@property (nonatomic, retain)				NSString	 *photoName;
@property (nonatomic, assign)				NSUInteger   photoID;
@property (nonatomic, assign)				NSUInteger   positionIndex;
@property (nonatomic, assign)				NSInteger    pageNumber;
@property (nonatomic)						BOOL		 pageBreak;
@property (nonatomic, retain)				UIImageView  *badgeView;

#pragma mark experimental
- (void) leftSwipe;
- (void) rightSwipe;
- (void) detectBoundary:	(UITouch *)touch;
- (void) enableScrollingAgain;

#pragma mark touch handling
- (void) movePhoto:			(NSSet *)touches;
- (void) highlightTarget;
- (void) highlightTargetUndo;
- (void) highlightTargetUndoAll;
- (void) singleTap;
- (void) doubleTap:			(UITouch *)touch;

@end
//----------------------------------------------------------------------------------------------------------------------//
