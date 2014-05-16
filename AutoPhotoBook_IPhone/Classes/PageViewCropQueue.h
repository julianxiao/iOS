//
//  PageViewCropQueue.h
//  iphotobookThumbnail
//
//  Created by Song on 3/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseQueue.h"

@class PhotoPosition;

@interface PageViewCropQueue : BaseQueue {
	NSString *imageURL;
	NSString *autocropURL;
	CGFloat scalingFactor;
	PhotoPosition *position;
	NSString *imageNum;
	UIView *renderedPage;
	UIImageView *oneImageView;
}

@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *autocropURL;
@property (nonatomic, retain) NSString *imageNum;
@property (nonatomic, retain) UIView *renderedPage;
@property (nonatomic, retain) UIImageView *oneImageView;
@property (nonatomic, retain) PhotoPosition *position;
@property (nonatomic) CGFloat scalingFactor;
@end
