//
//  BuildPDFQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BuildPDFQueue.h"
#import "Env.h"

@implementation BuildPDFQueue
@synthesize pdfURL;
@synthesize json;

- (void) run{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/orderBookPDFSer.do", [Env instance].serverURL]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: url];
	[req setHTTPMethod: @"POST"];
	[req setValue: @"application/octet-stream" forHTTPHeaderField: @"Content-Type"];
	NSData *dat = [self.json dataUsingEncoding: NSUTF8StringEncoding];
	[req setHTTPBody: dat];
	dat = [NSURLConnection sendSynchronousRequest: req returningResponse: nil error: nil];
	NSString *ret = [[NSString alloc] initWithData: dat encoding: NSUTF8StringEncoding];
	NSLog(@"%@", ret);
	self.pdfURL = [NSString stringWithFormat: @"%@/%@", [Env instance].serverURL, ret];
	[ret release];
}

- (void) apply{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: self.pdfURL]];
}

- (void) onStop{
}

- (void) dealloc {
	self.pdfURL = nil;
	self.json = nil;
	[super dealloc];
}
@end
