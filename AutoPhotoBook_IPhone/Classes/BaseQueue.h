//
//  BaseQueue.h
//  OnlinePhotoSlideShow
//
//  Created by Song on 3/6/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseQueue : NSObject {
    id target;
    BOOL stop;
    BOOL hasBusy;
	BOOL canDelay;
}

- (void) run;
- (void) apply;
- (void) onStop;

- (BOOL) canSync;

- (BOOL) needAsync;

- (void) stopQueue;
- (void) applyDelegate;
- (void) runDelegate;

+ (id) queue;

@property(nonatomic, retain) id target;
@property(nonatomic, readonly) BOOL stop;
@property(nonatomic) BOOL hasBusy;
@property(nonatomic) BOOL canDelay;
@end
