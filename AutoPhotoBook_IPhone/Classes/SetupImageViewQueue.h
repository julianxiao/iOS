//
//  SetupImageViewQueue.h
//  iphotobookThumbnail
//
//  Created by Song on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseQueue.h"

@interface SetupImageViewQueue : BaseQueue {
	UIImageView *imageView;
	NSInteger pageNum;
	NSString *imgName;
	NSInteger imgNameIndex;
	NSInteger imgPageIndex;
	NSInteger imgScreenIndex;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSString *imgName;
@property NSInteger pageNum;
@property NSInteger imgNameIndex;
@property NSInteger imgPageIndex;
@property NSInteger imgScreenIndex;
@end
