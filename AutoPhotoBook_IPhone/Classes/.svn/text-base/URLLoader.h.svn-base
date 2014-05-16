//
//  URLLoader.h
//  iphotobookThumbnail
//
//  Created by Song on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLLoader : NSObject {
	
}

+ (NSData *) resourceFor: (NSString *) url;
+ (NSData *) resourceFor:(NSString *)url withCache: (BOOL) usingCache;
+ (NSString *) resourcePathFor: (NSString *) url;
+ (NSString *) resourcePathFor: (NSString *) url withCache: (BOOL) usingCache;
+ (BOOL) hasResource: (NSString *) url;
+ (NSString *) toResourePath: (NSString *) url;

+ (void) setOffline: (BOOL) value;
+ (BOOL) isOffline;
@end
