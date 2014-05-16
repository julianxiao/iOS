//
//  AlbumPhotosPreDownloadQueue.h
//  iphotobookThumbnail
//
//  Created by Song on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseQueue.h"

@interface AlbumPhotosPreDownloadQueue : BaseQueue {
	NSString *albumId;
	NSString *width;
	NSString *height;
	NSOutputStream *output;
	NSString *tempStore;
	long total;
	long loaded;
	BOOL needAsync_;
}

@property (nonatomic, retain) NSString *albumId;
@property (nonatomic, retain) NSString *tempStore;
@property (nonatomic, retain) NSOutputStream *output;
@property (nonatomic, retain) NSString *width;
@property (nonatomic, retain) NSString *height;

@end
