//
//  GetAlbumPhotosQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GetAlbumPhotosQueue.h"
#import "URLLoader.h"
#import "JSON.h"
#import "Env.h"
#import "Gallery.h"
#import "AlbumPhotosPreDownloadQueue.h"
#import "DataLoaderQueue.h"

@implementation GetAlbumPhotosQueue
@synthesize album;
@synthesize gallery;

- (void) run{
	NSString *url = [NSString stringWithFormat:@"%@/getPhotoSer.do?albumId=%@", [Env instance].serverURL, [self.album valueForKey:@"id"]];
	NSData *data = [URLLoader resourceFor: url withCache: NO];
	if (data == nil) {
		return;
	}
	if(self.stop)return;
	NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	SBJSON *json = [[SBJSON alloc] init];
	NSArray *arr = [json objectWithString: ret error: nil];
	//NSLog(@"%@", ret);
	[self.album setValue: arr forKey: @"photos"];
	[json release];
	[ret release];
	
	self.gallery.filemap = [NSMutableDictionary dictionaryWithCapacity: [arr count]];
	NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
	for (int j = 0; j < [arr count];  j++) {
		NSDictionary *photo = [arr objectAtIndex: j];
		NSString *turl = [photo valueForKey: @"turl"];
		NSString *key = [[photo valueForKey: @"id"] stringValue];
		[self.gallery.filemap setValue: turl forKey: key];
		NSString *acresult = [photo valueForKey: @"crop"];
		if (acresult != nil) {
			NSString *acURL = [NSString stringWithFormat:@"%@/getBestPartSer.do?pid=%@&picUrl=%@", [Env instance].serverURL, key, turl];
			NSString *acPath = [URLLoader toResourePath: acURL];
			[acresult writeToFile: acPath atomically: YES encoding: NSUTF8StringEncoding error: nil];
		}
		[photoMap setValue: photo forKey: [[photo valueForKey: @"id"] stringValue]];
	}	

	AlbumPhotosPreDownloadQueue *apq = [AlbumPhotosPreDownloadQueue queue];
	apq.albumId = [self.album valueForKey:@"id"];
	apq.width = @"100";
	apq.height = @"100";
	[[DataLoaderQueue instance] addQueue: apq withCategory: @"get_albumphotos_icons_cache"];
	
	apq = [AlbumPhotosPreDownloadQueue queue];
	apq.albumId = [self.album valueForKey:@"id"];
	apq.width = @"480";
	apq.height = @"480";
	[[DataLoaderQueue instance] addQueue: apq withCategory: @"get_albumphotos_icons_cache"];
	
}

- (void) apply{
}

- (void) onStop{
}

- (void) dealloc {
	self.album = nil;
	self.gallery = nil;
	[super dealloc];
}
@end
