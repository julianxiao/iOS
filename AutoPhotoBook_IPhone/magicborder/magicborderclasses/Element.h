//
//  Element.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Element : NSObject {
	NSString * position;
	NSString * type;
	NSString * style;
	NSString * width;
	NSString * height;
	NSString * x;
	NSString * y;
	NSString * layoutDensity;
	NSString * group;
	NSString * mode;
	NSString * marginpusher;
	NSString * alignment;
	NSString * version;
	NSString * setScale;
	NSString * xstep;
	NSString * ystep;
	NSString * oddXCount;
	NSString * oddYCount;
	NSMutableArray * images;
}

@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * width;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * x;
@property (nonatomic, retain) NSString * y;
@property (nonatomic, retain) NSString * layoutDensity;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSString * marginpusher;
@property (nonatomic, retain) NSString * alignment;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * setScale;
@property (nonatomic, retain) NSString * xstep;
@property (nonatomic, retain) NSString * ystep;
@property (nonatomic, retain) NSString * oddXCount;
@property (nonatomic, retain) NSString * oddYCount;
@property (nonatomic, retain) NSMutableArray * images;

@end
