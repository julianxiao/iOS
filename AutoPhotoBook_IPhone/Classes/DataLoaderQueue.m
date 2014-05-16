//
//  DataLoaderQueue.m
//  OnlinePhotoSlideShow
//
//  Created by Song on 3/6/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataLoaderQueue.h"
#import "BaseQueue.h"
#import "GlobalController.h"
#import "SelectorInvokeQueue.h"

@implementation DataLoaderQueue
@synthesize categoryMap;
@synthesize threads;
@synthesize queueOfCategory;

static DataLoaderQueue *loader;

+(DataLoaderQueue *) instance{
    if(loader == nil){
        @synchronized(self){
            if(loader == nil){
                loader = [[DataLoaderQueue alloc] init];
                loader.categoryMap = [NSMutableDictionary dictionaryWithCapacity: 10];
                loader.threads = [NSMutableDictionary dictionaryWithCapacity: 10];
                loader.queueOfCategory = [NSMutableDictionary dictionaryWithCapacity: 10];
            }
        }
    }
    return loader;
}

+ (void) addTarget: (id) target withSelector: (SEL) selector withObject: (id) obj{
	[self addTarget: target withSelector: selector withObject: obj canDelay: YES];
}

+ (void) addTarget: (id) target withSelector: (SEL) selector withObject: (id) obj canDelay: (BOOL) canDelay{
	SelectorInvokeQueue *queue = [SelectorInvokeQueue queue];
	queue.target = target;
	queue.runSelector = selector;
	queue.object = obj;
	queue.canDelay = canDelay;
	if (obj == nil) {
		NSString *method = NSStringFromSelector(selector);
		if ([method rangeOfString:@":"].length > 0) {
			queue.hasParam = YES;
		}
	}
	[[DataLoaderQueue instance] addQueue: queue withCategory: @"Default"];
}

+(void) dealloc{
    [loader release];
    [super dealloc];
}

-(void)dealloc{
    [categoryMap release];
    [super dealloc];
}

- (BaseQueue *)nextQueue:(NSString *) category{
    NSMutableArray *list = [categoryMap valueForKey: category];
    @try {
		@synchronized(list){
            if(list != nil && [list count] > 0){
                BaseQueue *queue = [[list objectAtIndex: 0] retain];
                [list removeObjectAtIndex: 0];
                return [queue autorelease];
            }
        }
    }
    @catch (NSException * e) {
    }
    @catch (NSError * e) {
    }
    return nil;
}

- (void) queueThread:(NSString *) category{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BaseQueue *queue = nil;
    while((queue = [self nextQueue: category]) != nil){
        [queueOfCategory setValue: queue forKey: category];
        NSLog(@"starting queue %@ on %@", queue, category);
        @try {
            [queue runDelegate];
            [queue performSelectorOnMainThread: @selector(applyDelegate) withObject: nil waitUntilDone: YES];
			while ([queue needAsync] && !queue.stop) {
				[NSThread sleepForTimeInterval: 1];
			}
            [queue performSelectorOnMainThread: @selector(stopQueue) withObject: nil waitUntilDone: YES];
		}
        @catch (NSException * e) {
            //NSLog(@"Queue Exception: name=%@ reason=%@", [e name], [e reason]);
        }
        @catch (NSError * e) {
        }
    }
	[queueOfCategory removeObjectForKey: category];
	[self stopCategory: category];
    [pool release];
}

- (void) addQueue: (BaseQueue *) queue withCategory:(NSString *) category{
	category = @"Default";
    [[GlobalController instance] resetTotalBusy];
    if([queue canSync]){
        category = @"syncQueue";
    }else {
        [[GlobalController instance] addBusy];
        queue.hasBusy = YES;
    }

    NSMutableArray *list = [categoryMap valueForKey: category];
    @try {
        if(list == nil){
            @synchronized(categoryMap){
                if(list == nil){
                    list = [NSMutableArray array];
                    [categoryMap setValue: list forKey: category];
                }
            }
        }
    }
    @catch (NSException * e) {
    }
    @catch (NSError * e) {
    }
    if(queue != nil){
        @synchronized(list){
			[list addObject: queue];
		}
        @synchronized(threads){
			NSThread *thread = [threads valueForKey: category];
            if(thread == nil || [thread isFinished]){
                thread = [[NSThread alloc] initWithTarget: self selector: @selector(queueThread:) object: category];
				NSLog(@"created new thread - %@ for %@", thread, category);
                [threads setValue: thread forKey: category];
                [thread release];
                [thread start];
            }/*else{
				if (thread == [NSThread currentThread]) {
					@synchronized(list){
						if ([list count] > 2) {
							[list exchangeObjectAtIndex: [list count] - 1 withObjectAtIndex: 1];
						}
					}
				}
			}*/
        }
    }
}

- (void) stopCategory: (NSString *) category{
    NSMutableArray *list = [categoryMap valueForKey: category];
    if(list != nil){
        @try {
            @synchronized(list){
                for (int i = 0; i < [list count]; i++) {
                    BaseQueue *queue = [list objectAtIndex: i];
                    [queue stopQueue];
                }
                [list removeAllObjects];
            }            
        }
        @catch (NSException * e) {
        }
        @catch (NSError * e) {
        }
    }
    BaseQueue *queue = [queueOfCategory valueForKey: category];
    if(queue != nil){
        [queue stopQueue];
        [queueOfCategory removeObjectForKey: category];
    }
	@synchronized(threads){
		NSThread *thread = [threads valueForKey: category];
		if(thread != nil){
			[threads removeObjectForKey: category];
		}
	}
    [[GlobalController instance] resetTotalBusy];
}
@end
