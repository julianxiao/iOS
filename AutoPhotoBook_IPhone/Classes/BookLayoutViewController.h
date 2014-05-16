//
//  BookLayoutViewController.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 03/31/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LayoutScrollView;
@class ThumbsDataSource;
@class PhotoStripView;

//----------------------------------------------------------------------------------------------------------------------//
@interface BookLayoutViewController : UIViewController <UIActionSheetDelegate> {
	IBOutlet LayoutScrollView	*layoutScrollView;						// single UIView that is shared by each pageView
//	NSArray			*pageViews;								// array of UIViews, each representing one page
	NSUInteger			currentPageNum;
	ThumbsDataSource	*thumbsDataSource;
	UIActivityIndicatorView	*activityIndicator;
	NSString *returnString;
	NSMutableURLRequest *request;
}

- (void) handleDoneButton;
-(void) backgroundSending;


@property (nonatomic, retain) LayoutScrollView	*layoutScrollView;
//@property (nonatomic, retain) NSArray			*pageViews;
@property (nonatomic, assign) NSUInteger		currentPageNum;
@property (nonatomic, retain) ThumbsDataSource	*thumbsDataSource;
@property (nonatomic, retain) UIActivityIndicatorView	*activityIndicator;
@property (nonatomic, retain) NSString *returnString;
@property (nonatomic, retain) NSMutableURLRequest *request;

@end
//----------------------------------------------------------------------------------------------------------------------//
