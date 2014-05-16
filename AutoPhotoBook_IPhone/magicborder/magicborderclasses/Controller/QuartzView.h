//
//  QuartzView.h
//  MagicPhotoBook
//
//  Created by Fujuhua on 10-3-12.
//  Copyright 2010 HP Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuartzView : UIView
{
}

// As a matter of convinience we'll do all of our drawing here in subclasses of QuartzView.
-(void)drawInContext:(CGContextRef)context;

@end
