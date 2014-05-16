//
//  GetAutoCropQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GetAutoCropQueue.h"
#import "URLLoader.h"

@implementation GetAutoCropQueue
@synthesize autocropURL;

- (void) run{
	if (self.autocropURL == nil) {
		return;
	}
	NSData *data = [URLLoader resourceFor: self.autocropURL];
	NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	if ([data length] == 0 || [ret characterAtIndex: 0] != '{') {
		[ret release];
		ret = nil;
		data = [URLLoader resourceFor: self.autocropURL withCache: NO];
		ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	}
	[ret release];
	ret = nil;	
}

- (void) apply{
}

- (void)dealloc {
    [super dealloc];
}


@end
