//
//  PhotoStripThumbView.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 4/17/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "PhotoStripThumbView.h"
#import "PhotoStripView.h"


@implementation PhotoStripThumbView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"\ntouchesEnded");
	
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	NSLog(@"\ntapcount:%d", tapCount);
	
	//	CGPoint pt = [touch locationInView:self];
	switch (tapCount) {
		case 0:
			break;
		case 1:
		    NSLog(@"photo %d added", self.tag);
			PhotoStripView *photoStripView = (PhotoStripView *) [self superview];
			CGPoint thisTouchPoint = [touch locationInView: nil];
			[photoStripView addPhoto:self.tag atPoint:thisTouchPoint];
			break;
		case 2:
			break;
		default:
			break;
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
