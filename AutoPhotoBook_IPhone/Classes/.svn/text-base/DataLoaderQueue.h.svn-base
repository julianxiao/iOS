//
//  DataLoaderQueue.h
//  OnlinePhotoSlideShow
//
//  Created by Song on 3/6/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseQueue;

@interface DataLoaderQueue : NSObject {
    NSMutableDictionary *categoryMap;
    NSMutableDictionary *threads;
    NSMutableDictionary *queueOfCategory;
}

+(DataLoaderQueue *) instance;
+ (void) addTarget: (id) target withSelector: (SEL) selector withObject: (id) obj;
+ (void) addTarget: (id) target withSelector: (SEL) selector withObject: (id) obj canDelay: (BOOL) canDelay;

- (void) addQueue: (BaseQueue *) queue withCategory:(NSString *) category;
- (void) stopCategory: (NSString *) category;

@property(nonatomic, retain) NSMutableDictionary *categoryMap;
@property(nonatomic, retain) NSMutableDictionary *threads;
@property(nonatomic, retain) NSMutableDictionary *queueOfCategory;
@end
