//
//  SingleImageCropViewController.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"

@class ThumbsDataSource;
@class TapDetectingImageView;

@interface SingleImageCropViewController : UIViewController  <UIScrollViewDelegate, TapDetectingImageViewDelegate>  {
	IBOutlet UIImageView *imageCanvas;
	IBOutlet UIImageView *cropCanvas;
	IBOutlet UIView *mainView;
	IBOutlet UIScrollView *imageScrollView;
	ThumbsDataSource	*thumbsDataSource;
	NSInteger imageNum;
	NSInteger pageNum;
	float imageScale;
	TapDetectingImageView *imageView;
}

@property (nonatomic, retain)  UIImageView *imageCanvas;
@property (nonatomic, retain)  TapDetectingImageView *imageView;
@property (nonatomic, retain) ThumbsDataSource	*thumbsDataSource;
@property (nonatomic, assign)  NSInteger		imageNum;
@property (nonatomic, assign)  NSInteger		pageNum;
@property (nonatomic, assign)  float	imageScale;
@property (nonatomic, retain)  UIScrollView *imageScrollView;

- (void) resetImage: (UIView *)imageView inScrollView: (UIScrollView *)scrollView;

@end