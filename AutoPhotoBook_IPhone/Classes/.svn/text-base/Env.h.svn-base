//
//  Env.h
//  iphotobookThumbnail
//
//  Created by Song on 3/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Env : NSObject {
	NSMutableDictionary *storage;
	NSString *documentRoot;
	NSString *serverURL;
	
	BOOL firstTime;
}

+ (Env *) instance;

- (void) prepare;
- (void) save;

@property(nonatomic, retain) NSMutableDictionary *storage;
@property(nonatomic, retain) NSString *documentRoot;
@property(nonatomic, retain) NSString *serverURL;
@property(nonatomic, assign) BOOL firstTime;

@end
