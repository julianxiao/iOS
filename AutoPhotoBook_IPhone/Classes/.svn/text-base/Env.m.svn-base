//
//  Env.m
//  iphotobookThumbnail
//
//  Created by Song on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Env.h"


@implementation Env
@synthesize storage;
@synthesize documentRoot;
@synthesize serverURL;
@synthesize firstTime;

static Env *ins;

+ (Env *) instance{
	if (ins == nil) {
		ins = [[Env alloc] init];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *path = [paths objectAtIndex: 0];
		ins.documentRoot = path;
		//ins.serverURL = @"http://www.autophotobook.com";
		//ins.serverURL = @"http://16.157.69.125:8089/AutoBook";
		ins.serverURL = @"http://198.55.32.89/";
		[ins prepare];
	}
	return ins;
}

- (void) prepare{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *storePath = [self.documentRoot stringByAppendingPathComponent:@"store.txt"];
	if ([fileManager isReadableFileAtPath: storePath]) {
		self.storage = [NSMutableDictionary dictionaryWithContentsOfFile: storePath];
	}
	if (self.storage == nil) {
		self.storage = [NSMutableDictionary dictionary];
		[self save];
		self.firstTime = YES;
	}
}

- (void) save{
	NSString *storePath = [self.documentRoot stringByAppendingPathComponent:@"store.txt"];
	[self.storage writeToFile: storePath atomically: YES];
}

- (void) dealloc{
	self.storage = nil;
	self.documentRoot = nil;
	[super dealloc];
}
@end
