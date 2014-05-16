//
//  RepObject.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-14.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RepObject : NSObject {
	CGFloat xcount;
	CGFloat ycount;
	CGFloat xstep;
	CGFloat ystep;
	CGFloat xstart;
	CGFloat ystart;
}

@property (nonatomic, assign) CGFloat xcount;
@property (nonatomic, assign) CGFloat ycount;
@property (nonatomic, assign) CGFloat xstep;
@property (nonatomic, assign) CGFloat ystep;
@property (nonatomic, assign) CGFloat xstart;
@property (nonatomic, assign) CGFloat ystart;

@end
