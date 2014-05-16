//
//  LoginQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginQueue.h"
#import "Env.h"
#import "Utils.h"
#import "JSON.h"
#import "Gallery.h"
#import "URLLoader.h"
#import "LoginController.h"
#import "PaginationQueue.h"
#import "DataLoaderQueue.h"
#import "GetAlbumPhotosQueue.h"
#import "iphotobookThumbnailAppDelegate.h"

@implementation LoginQueue
@synthesize username;
@synthesize password;
@synthesize collections;

- (void) run{
	NSString *url = [NSString stringWithFormat:@"%@/logInServ.do?name=%@&pwd=%@", [Env instance].serverURL, self.username,
					 [Utils md5: 
					  [self.password stringByTrimmingCharactersInSet: 
					   [NSCharacterSet whitespaceAndNewlineCharacterSet]
					   ]
					  ]
					 ];
	NSData *data = [URLLoader resourceFor: url withCache: NO];
	if (data == nil) {
		serverError = YES;
		return;
	}
	if(self.stop)return;
	NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog(@"%@", ret);
	
	SBJSON *json = [[SBJSON alloc] init];
	NSObject *dic = [json objectWithString: ret error: nil];
	[json release];
	[ret release];
	loginSuccess = [[dic valueForKey:@"success"] isEqualToString: @"true"];
	if (!loginSuccess) {
		return;
	}
	NSString *userId = [dic valueForKey:@"msg"];
	url = [NSString stringWithFormat:@"%@/getAlbumSer.do?userId=%@", [Env instance].serverURL, userId];
	data = [URLLoader resourceFor: url withCache: NO];
	if (data == nil) {
		serverError = YES;
		return;
	}
	if(self.stop)return;
	ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog(@"%@", ret);

	json = [[SBJSON alloc] init];
	NSArray *arr = [json objectWithString: ret error: nil];
	[[Env instance].storage setValue: arr forKey: @"albums"];
	[json release];
	[ret release];
	
	self.collections = [NSMutableArray array];
	
	NSArray *albums = [[Env instance].storage valueForKey:@"albums"];
	NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
	if (photoMap == nil) {
		photoMap = [NSMutableDictionary dictionary];
		[[Env instance].storage setValue: photoMap forKey: @"photoMap"];
	}else {
		[photoMap removeAllObjects];
	}

	for (int i = 0; i < [albums count]; i++) {
		NSMutableDictionary *album = [albums objectAtIndex: i];
		Gallery   *gallery = [[Gallery alloc] init]; 
		gallery.title		=  [album valueForKey: @"caption"];
		gallery.uuid		=  [album valueForKey: @"id"];
		gallery.icon		=  [album valueForKey: @"iconUrl"];
		
		GetAlbumPhotosQueue *gaq = [GetAlbumPhotosQueue queue];
		gaq.album = album;
		gaq.gallery = gallery;
		[[DataLoaderQueue instance] addQueue: gaq withCategory: @"queue_in_login_queue"];
		
		if(self.stop)return;
		PaginationQueue *queue = [PaginationQueue queue];
		queue.album = album;
		queue.gallery = gallery;
		[[DataLoaderQueue instance] addQueue: queue withCategory: @"queue_in_login_queue"];
		[self.collections addObject:gallery];
		[gallery release];
	}
	[[Env instance] save];
}

- (void) apply{
	iphotobookThumbnailAppDelegate *appDelegate = (iphotobookThumbnailAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (serverError) {
		[appDelegate doOnOffLine];
	}else {
		if (loginSuccess) {
			[appDelegate doOnLoginSuccess: self.collections];
		} else {
			[appDelegate doOnLoginFail];
		}		
	}
}

- (void) onStop{
}

- (void) dealloc {
	self.username = nil;
	self.password = nil;
	[super dealloc];
}
@end
