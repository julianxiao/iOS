//
//  InitResourceQueue.m
//  AutoPhoneBook_iPad
//
//  Created by Song on 5/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InitResourceQueue.h"
#import "ZipArchive.h"
#import "Env.h"

@implementation InitResourceQueue

- (void) run{
	NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Archive" ofType: @"zip"];
	if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
		ZipArchive* zipFile = [[ZipArchive alloc] init];
		[zipFile UnzipOpenFile: filePath];
		[zipFile UnzipFileTo: [Env instance].documentRoot overWrite: YES];
		[zipFile UnzipCloseFile];
		[zipFile release];
		
		[[Env instance] prepare];
	}
}

- (void) apply{
}

- (void) onStop{
}

- (void)dealloc {
    [super dealloc];
}


@end
