//
//  VersionMenu.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-11.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menuitem.h"


@interface VersionMenu : NSObject {
	NSString * vid;
	NSMutableArray * menuitems;
}

@property (nonatomic, retain) NSString * vid;
@property (nonatomic, retain) NSMutableArray * menuitems;

@end
