//
//  BaseQueue.m
//  OnlinePhotoSlideShow
//
//  Created by Song on 3/6/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseQueue.h"
#import "GlobalController.h"

@implementation BaseQueue
@synthesize target;
@synthesize stop;
@synthesize hasBusy;
@synthesize canDelay;

- (id) init{
	if ((self = [super init]) != nil) {
		self.canDelay = YES;
	}
	return self;
}

- (void) run{
}

- (void) apply{
}

- (void) onStop{
}

- (void) applyDelegate{
    //NSLog(@"apply %@", self);
	
    @try {
        if(!stop){
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[self apply];
			[pool release];
        }
    }
    @catch (NSException * e) {
    }
    @catch (NSError * e) {
    }
}

- (void) runDelegate{
    if(!stop){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[self run];
		[pool release];
    }
}

- (void) stopQueue{
	if (stop) {
		return;
	}
    NSLog(@"stop %@", self);
	if(hasBusy){
		hasBusy = NO;
		[[GlobalController instance] removeBusy];
	}
	stop = YES;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self onStop];
	[pool release];
}

- (BOOL) canSync{
    return NO;
}

- (BOOL) needAsync {
	return NO;
}

- (void) dealloc{
    self.target = nil;
    [super dealloc];
}

+ (id) queue{
    return [[[self alloc] init] autorelease];
}
@end
