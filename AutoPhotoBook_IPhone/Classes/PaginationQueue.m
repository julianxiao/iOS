//
//  PaginationQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaginationQueue.h"
#import "Env.h"
#import "Gallery.h"
#import "URLLoader.h"

@implementation PaginationQueue
@synthesize album;
@synthesize gallery;

- (void) run{
	NSString *url = [NSString stringWithFormat:@"%@/paginationSer.do?albumId=%@", [Env instance].serverURL, [album valueForKey:@"id"]];
	NSData *data = [URLLoader resourceFor: url];
	NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	[album setValue: ret forKey: @"pagination"];
	gallery.pagination = ret;
	//NSLog(@"%@", ret);
	[ret release];
}

- (void) apply{
}

- (void) onStop{
}

//- (BOOL) canSync{
	//NSString *url = [NSString stringWithFormat:@"%@/paginationSer.do?albumId=%@", [Env instance].serverURL, [album valueForKey:@"id"]];
    //return [URLLoader hasResource: url];
//}

- (void) dealloc{
	self.album = nil;
	self.gallery = nil;
    [super dealloc];
}
@end
