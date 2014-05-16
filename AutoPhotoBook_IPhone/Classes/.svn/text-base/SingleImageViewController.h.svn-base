//
//  SingleImageViewController.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 4/22/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"

@class ThumbsDataSource;
@class TapDetectingImageView;

@interface SingleImageViewController : UIViewController  <UIScrollViewDelegate, TapDetectingImageViewDelegate>  {
	IBOutlet UIImageView *imageCanvas;
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
