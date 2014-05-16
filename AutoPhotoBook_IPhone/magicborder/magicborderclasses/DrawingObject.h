//
//  DrawingObject.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-15.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DrawingObject : NSObject {
	CGRect box;
	BOOL repeat;
	CGAffineTransform mat;
	NSString *imgname;
}

@property (nonatomic, assign) CGRect box;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) CGAffineTransform mat;
@property (nonatomic, retain) NSString *imgname;

@end
