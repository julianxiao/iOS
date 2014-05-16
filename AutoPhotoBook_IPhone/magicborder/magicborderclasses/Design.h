//
//  Design.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VersionMenu.h"
#import "Frame.h"

@interface Design : NSObject {
	NSString * name;
	NSString * icon;
	NSString * style;
	NSString * layout;
	NSString * layoutDensityAmp;
	NSString * layoutDensityBlur;
	NSString * layoutDensityChannel;
	NSString * layoutDensityOffset;
	NSString * maxItemSize;
	NSString * minItemSize;
	NSString * sparseFactor;
	NSString * scaleWithItems;
	NSString * leftMargin;
	NSString * rightMargin;
	NSString * topMargin;
	NSString * bottomMargin;
	NSString * itemGap;
	NSString * type;
	NSString * width;
	NSString * height;
	NSString * x;
	NSString * y;
	NSString * version;
	NSString * numRandomVersions;
	NSString * numModes;
	NSString * defaultNumItems;
	NSString * mode;
	VersionMenu * versionMenu;
	Frame * frame;
	NSMutableArray * elements;
	NSMutableArray * texts;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * layout;
@property (nonatomic, retain) NSString * layoutDensityAmp;
@property (nonatomic, retain) NSString * layoutDensityBlur;
@property (nonatomic, retain) NSString * layoutDensityChannel;
@property (nonatomic, retain) NSString * layoutDensityOffset;
@property (nonatomic, retain) NSString * maxItemSize;
@property (nonatomic, retain) NSString * minItemSize;
@property (nonatomic, retain) NSString * sparseFactor;
@property (nonatomic, retain) NSString * scaleWithItems;
@property (nonatomic, retain) NSString * leftMargin;
@property (nonatomic, retain) NSString * rightMargin;
@property (nonatomic, retain) NSString * topMargin;
@property (nonatomic, retain) NSString * bottomMargin;
@property (nonatomic, retain) NSString * itemGap;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * width;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * x;
@property (nonatomic, retain) NSString * y;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * numRandomVersions;
@property (nonatomic, retain) NSString * numModes;
@property (nonatomic, retain) NSString * defaultNumItems;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) VersionMenu * versionMenu;
@property (nonatomic, retain) Frame * frame;
@property (nonatomic, retain) NSMutableArray * elements;
@property (nonatomic, retain) NSMutableArray * texts;

@end
