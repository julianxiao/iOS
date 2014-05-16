//
//  SelectorInvokeQueue.m
//  iphotobookThumbnail
//
//  Created by Song on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SelectorInvokeQueue.h"


@implementation SelectorInvokeQueue
@synthesize selector;
@synthesize runSelector;
@synthesize object;
@synthesize hasParam;

- (void) run{
	if (self.runSelector != nil) {
		if (self.object != nil || self.hasParam) {
			[target performSelector: self.runSelector withObject: self.object];
		}else {
			[target performSelector: self.runSelector];
		}
	}
}

- (void) apply{
	if (self.selector != nil) {
		if (self.object != nil || self.hasParam) {
			[target performSelector: self.selector withObject: self.object];
		}else {
			[target performSelector: self.selector];
		}
	}
}

- (void) onStop{
}

- (NSString *) description {
	return [NSString stringWithFormat: @"<SelectorInvokeQueue target=%@ selector=%@ runSelector=%@>", self.target, NSStringFromSelector(self.selector), NSStringFromSelector(self.runSelector)];
}

- (void) dealloc {
	self.selector = nil;
	self.runSelector = nil;
	self.object = nil;
	[super dealloc];
}
@end
