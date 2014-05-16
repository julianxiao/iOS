//
//  AlbumPhotosPreDownloadQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlbumPhotosPreDownloadQueue.h"
#import "URLLoader.h"
#import "Env.h"
#import "GlobalController.h"
#import "ZipArchive.h"

@implementation AlbumPhotosPreDownloadQueue
@synthesize albumId;
@synthesize width;
@synthesize height;
@synthesize output;
@synthesize tempStore;

- (void) apply{
	NSString *surl = [NSString stringWithFormat:@"%@/getAlbumFilesSer.do?albumId=%@&width=%@&height=%@",
					  [Env instance].serverURL, albumId, width, height];
	self.tempStore = [URLLoader toResourePath: surl];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: self.tempStore]) {
		needAsync_ = NO;
		return;
	}else {
		needAsync_ = YES;
	}

	NSURL *url = [NSURL URLWithString: surl];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest: req delegate: self];
	if(conn) {
		self.output = [NSOutputStream outputStreamToFileAtPath:self.tempStore append: NO];
		[self.output open];
	}
}

- (BOOL) needAsync {
	return needAsync_;
}

- (void) dealloc {
	self.albumId = nil;
	self.tempStore = nil;
	self.width = nil;
	self.height = nil;
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	total = [response expectedContentLength];
	loaded = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.output write: [data bytes] maxLength: [data length]];
	loaded += [data length];
	[[GlobalController instance] updateDownloadProgress: loaded * 100 / total];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
	[self.output close];
	self.output = nil;
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath: self.tempStore error: nil];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed!"
													message:[NSString stringWithFormat:@"%@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]]
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self stopQueue];
	[[GlobalController instance] updateDownloadProgress: -1];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [connection release];
    
	[self.output close];
	self.output = nil;
	[self stopQueue];
	[[GlobalController instance] updateDownloadProgress: -1];
	
	NSString *tempzipDir = [[Env instance].documentRoot stringByAppendingPathComponent:@"tempzip"];
	NSFileManager *fm = [NSFileManager defaultManager];
	if(![fm fileExistsAtPath: tempzipDir]){
		[fm createDirectoryAtPath: tempzipDir attributes: nil];
	}
	NSString *albumDir = [tempzipDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@", self.albumId, self.width, self.height]];
	if ([fm fileExistsAtPath: albumDir]) {
		NSArray *filelist = [fm directoryContentsAtPath: albumDir];
		int count = [filelist count];
		for (int i = 0; i < count; i++){
			[fm removeItemAtPath: [filelist objectAtIndex: i] error: nil];
			NSLog (@"%@", [filelist objectAtIndex: i]);
		}
	}else {
		[fm createDirectoryAtPath: albumDir attributes: nil];
	}
	
	ZipArchive* zipFile = [[ZipArchive alloc] init];
	[zipFile UnzipOpenFile: self.tempStore];
	[zipFile UnzipFileTo: albumDir overWrite: YES];
	[zipFile UnzipCloseFile];
	[zipFile release];
	
	NSArray *filelist = [fm directoryContentsAtPath: albumDir];
	int count = [filelist count];
	
	NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
	for (int i = 0; i < count; i++){
		NSString *name = [filelist objectAtIndex: i];
		NSArray *params = [name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString: @"_x."]];
		NSString *photoId = [params objectAtIndex: 0];
		NSString *pw = [params objectAtIndex: 1];
		NSString *ph = [params objectAtIndex: 2];
		NSString *ourl = [[photoMap valueForKey: photoId] valueForKey:@"turl"];
		NSString *curl = [NSString stringWithFormat:@"%@&width=%@&height=%@", ourl, pw, ph];
		NSString *cacheFile = [URLLoader toResourePath: curl];
		NSString *fromFile = [albumDir stringByAppendingPathComponent: name];
		[fm removeItemAtPath: cacheFile error: nil];
		[fm moveItemAtPath: fromFile toPath: cacheFile error: nil];
		//NSLog (@"%@", curl);
	}
}

@end
