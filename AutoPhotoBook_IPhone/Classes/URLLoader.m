//
//  URLLoader.m
//  iphotobookThumbnail
//
//  Created by Song on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "URLLoader.h"
#import "Env.h"
#import "Utils.h"

@implementation URLLoader

static BOOL offline;

//#define ACCESS_TRACK

+ (void) setOffline: (BOOL) value{
	offline = value;
}

+ (BOOL) isOffline{
	return offline;
}

+ (NSString *) resourcePathFor: (NSString *) url{
	return [self resourcePathFor: url withCache: YES];
}

+ (NSData *) resourceFor:(NSString *)url withCache: (BOOL) usingCache{
	usingCache = usingCache || offline;
	
	if (url == nil) {
		return nil;
	}
	//NSLog(@"request for %@", url);
	url = [url stringByReplacingOccurrencesOfString: @"\\" withString: @"/"];
	url = [url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	NSString *key = [Utils md5: url];
	NSString *cache = [[Env instance].documentRoot stringByAppendingPathComponent:@"cache"];
	NSString *storePath = [cache stringByAppendingPathComponent:key];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager createDirectoryAtPath: cache attributes: nil];
	
#ifdef ACCESS_TRACK
	NSString *access = [[Env instance].documentRoot stringByAppendingPathComponent:@"access"];
	[fileManager createDirectoryAtPath: access attributes: nil];
	[fileManager copyItemAtPath: storePath toPath: [access stringByAppendingPathComponent: key] error: nil];
#endif
	
	if (usingCache && [fileManager isReadableFileAtPath: storePath]) {
		return [NSData dataWithContentsOfFile: storePath];
	}else {
		NSURLRequest *req = [NSURLRequest requestWithURL: [NSURL URLWithString: url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 600]; 
		NSData *data = [NSURLConnection sendSynchronousRequest: req returningResponse: nil error: nil];
		if (data != nil) {
			[data writeToFile: storePath atomically: YES];
			return data;
		}
		return nil;
	}
	
	return nil;
}

+ (NSString *) resourcePathFor: (NSString *) url withCache: (BOOL) usingCache{
	usingCache = usingCache || offline;
	
	if (url == nil) {
		return nil;
	}
	//NSLog(@"request for %@", url);
	url = [url stringByReplacingOccurrencesOfString: @"\\" withString: @"/"];
	url = [url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	NSString *key = [Utils md5: url];
	NSString *cache = [[Env instance].documentRoot stringByAppendingPathComponent:@"cache"];
	NSString *storePath = [cache stringByAppendingPathComponent:key];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager createDirectoryAtPath: cache attributes: nil];
	
#ifdef ACCESS_TRACK
	NSString *access = [[Env instance].documentRoot stringByAppendingPathComponent:@"access"];
	[fileManager createDirectoryAtPath: access attributes: nil];
	[fileManager copyItemAtPath: storePath toPath: [access stringByAppendingPathComponent: key] error: nil];
#endif
	
	if (usingCache && [fileManager isReadableFileAtPath: storePath]) {
		return storePath;
	}else {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSURLRequest *req = [NSURLRequest requestWithURL: [NSURL URLWithString: url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 600];
		NSData *data = [NSURLConnection sendSynchronousRequest: req returningResponse: nil error: nil];
		if (data != nil) {
			[data writeToFile: storePath atomically: YES];
			[pool release];
			return storePath;
		}else {
			[pool release];
		}
		
		return nil;
	}
}

+ (NSData *) resourceFor: (NSString *) url{
	return [self resourceFor: url withCache: YES];
}

+ (BOOL) hasResource: (NSString *) url {
	NSString *storePath = [URLLoader toResourePath: url];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath: storePath] && [[fileManager attributesOfItemAtPath: storePath error: nil] fileSize] > 0) {
		return YES;
	}
	return NO;
}

+ (NSString *) toResourePath: (NSString *) url{
	url = [url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	NSString *key = [Utils md5: url];
	NSString *cache = [[Env instance].documentRoot stringByAppendingPathComponent:@"cache"];
	NSString *storePath = [cache stringByAppendingPathComponent:key];
	
#ifdef ACCESS_TRACK
	NSString *access = [[Env instance].documentRoot stringByAppendingPathComponent:@"access"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager createDirectoryAtPath: access attributes: nil];
	[fileManager copyItemAtPath: storePath toPath: [access stringByAppendingPathComponent: key] error: nil];
#endif
	
	return storePath;	
}
@end
