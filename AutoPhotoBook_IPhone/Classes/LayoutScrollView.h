//
//  LayoutScrollView.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 04/08/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PageView;
@class PhotoStripView;
@class BookLayoutViewController;
@class ThumbsDataSource;

@interface LayoutScrollView : UIView {	
	PageView *pageView;
	IBOutlet PhotoStripView *photoStripView;
	CGPoint			startLocation;
	NSTimeInterval	startTime;	
	CGPoint			lastTouchPoint;
	UITouch	*touchStart;	
}

- (void)doubleTap:(UITouch *)touch;
- (void) movePhoto:(UITouch *)touch;
- (void) highlightTarget;
- (void) setupPhotoStrip:(BookLayoutViewController *)controller;
- (void) changePhotoStrip;
- (void) hidePhotoStrip;
- (void)singleTap:(UITouch *) touch;

@property (nonatomic, retain) PageView *pageView;
@property (nonatomic, retain) UITouch *touchStart;
@property (nonatomic, retain) PhotoStripView	*photoStripView;
@end
