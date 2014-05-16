//
//  ThumbnailScrollView.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactor				0.1
#define kMinEraseInterval				0.4
#define kEraseAccelerationThreshold		2.0

@class iphotobookThumbnailAppDelegate;
@class ThumbnailImageView;
@class ThumbsDataSource;
@class BookLayoutViewController;
@class SingleImageViewController;
@class Gallery;

typedef enum photosSelectionMode {	
	normalMode,
	compressedMode
}  photosSelectionMode;

//----------------------------------------------------------------------------------------------------------------------//
@interface ThumbnailScrollView : UIScrollView <UINavigationBarDelegate, UIAccelerometerDelegate, 
														UIImagePickerControllerDelegate, UINavigationControllerDelegate> 
{	
	photosSelectionMode			currentMode;	
	ThumbsDataSource			*datasource;
	BookLayoutViewController	*bookLayoutViewController;
	SingleImageViewController	*singleImageViewController;
	//UIActivityIndicatorView		*activityIndicator;
	
	UIAccelerationValue	myAccelerometer[3];
	CFTimeInterval		lastTime;
}

@property (nonatomic, assign)  photosSelectionMode			currentMode;
@property (nonatomic, retain)  ThumbsDataSource				*datasource;
@property (nonatomic, retain)  BookLayoutViewController		*bookLayoutViewController;
@property (nonatomic, retain)  SingleImageViewController	*singleImageViewController;
//@property (nonatomic, retain)  UIActivityIndicatorView		*activityIndicator;

#pragma mark init
- (BOOL)	  initThumbnailView: (Gallery *) gallery;
- (NSDictionary *) getActiveFilelist;
- (NSUInteger)getActiveCollectionNum;
- (void)	  setUpNavigationController;

#pragma mark loading the images
- (void) loadImages;
- (void) setUpImageView:				(UIImageView		*) imageView		
							 forPageNum:	(NSInteger	 ) pageNum 
							  imageName:	(NSString	*) imgName 
						 imageNameIndex:	(NSInteger	 ) imgNameIndex
						 imagePageIndex:	(NSInteger	 ) imgPageIndex
					andImageScreenIndex:	(NSInteger	 ) imgScreenIndex;

#pragma mark normal layout
- (void) updateLayout;
- (void) updateLayoutAnimated;
- (void) addBadgeToView:				(ThumbnailImageView *)view				pageNumber:(NSInteger)	pageNumber;  
- (void) removeBadgeFromView:			(ThumbnailImageView *)view;

#pragma mark compressed layout
- (void) compressView;
- (void) layoutCompressedView;
- (void) hideNonpagebreakViews;
- (void) uncompressView;
- (void) uncompressLayout;

#pragma mark move an image
- (void) movePhotoFrom:					(ThumbnailImageView *) fromImage		to:(ThumbnailImageView *) toImage;
- (void) makeNewPageFrom:				(ThumbnailImageView *) theTappedImage;
- (void) makeNewPageFromUnselectedImage:(ThumbnailImageView *) fromImage;

- (void) adjustPageNums:				(ThumbnailImageView *) fromImage		to:(ThumbnailImageView *) toImage;
- (void) adjustPositionIndexes:			(ThumbnailImageView *) fromImage		to:(ThumbnailImageView *) toImage;

#pragma mark move a page
- (void) handlePageMoveInCompressedMode:(NSSet	 *) touches;
- (void) exchangePage:					(NSInteger) pageNumA	   withPage: (NSInteger) pageB;
- (void) movePageToUnselected:			(NSInteger) pageNum;

#pragma mark maintain currentPagination
- (void)				  updateCurPagination;													// calls datasource
- (NSString *)			  getBRICinputStringForPage:		(NSInteger)	 pageNum;	
- (NSString	*)			  constructNewPaginationStringFromAlteredLayout;

#pragma mark action methods
- (IBAction)			  handleLayoutButton:				(id)		 sender;
- (void)				  handleSingleTap:					(ThumbnailImageView *) image;
- (void)				  handleDoubleTap:					(UITouch *)  touch;
- (void)				  handleLeftSwipe; 
- (void)				  handleRightSwipe;
- (void)				  takePhoto;

#pragma mark utility methods
- (ThumbnailImageView *)  viewHavingPositionIndex:			(NSUInteger) position;
- (ThumbnailImageView *)  viewHavingPhotoID:				(NSUInteger) photoID;
- (ThumbnailImageView *)  pageheadForPage:					(NSInteger)  pageNumber;
- (void)				  updateBadges;
- (void)				  infoAboutImagesFrom:				(NSUInteger) A			to: (NSUInteger) B;	// for debug
- (iphotobookThumbnailAppDelegate *)  appDelegate;	
- (UINavigationController		  *)  navController;

#pragma mark touch events
- (BOOL)				  touchesShouldCancelInContentView:	(UIView  *)  view;
@end
//----------------------------------------------------------------------------------------------------------------------//
