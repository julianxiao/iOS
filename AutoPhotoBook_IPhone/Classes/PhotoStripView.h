//
//  PhotoStripView.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 4/17/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BookLayoutViewController;
@class ThumbsDataSource;

@interface PhotoStripView : UIScrollView {
	
	BookLayoutViewController *myController;
	
	NSTimer *autoHideTimer;
	bool autoHideTimerRestart;
	
}

@property  (nonatomic, retain) NSTimer *autoHideTimer;
@property  (nonatomic, retain) BookLayoutViewController *myController;
@property (nonatomic, assign) bool autoHideTimerRestart;

-(void)autoHide:(NSTimer *) theTimer;
-(void)hideStrip: (bool) animated;
-(void)showStrip: (bool) animated;
- (void) addPhoto:(NSInteger)imageNum atPoint:(CGPoint) location;
- (void) initWithController:(BookLayoutViewController *)controller;
- (void) loadImages: (ThumbsDataSource *) datasource;
@end
