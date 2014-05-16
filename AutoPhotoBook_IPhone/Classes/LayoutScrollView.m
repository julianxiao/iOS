//
//  LayoutScrollView.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 04/08/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "LayoutScrollView.h"
#import "PhotoStripView.h"
#import "PageView.h"
#import "ThumbsDataSource.h"

@implementation LayoutScrollView

@synthesize pageView;
@synthesize touchStart;
@synthesize photoStripView;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		
	}
    return self;
}

- (void) setupPhotoStrip:(BookLayoutViewController *)controller
{
	
	[[photoStripView superview] bringSubviewToFront:photoStripView];
	//	view.hidden = FALSE;
	photoStripView.alpha = 0;
	photoStripView.userInteractionEnabled = NO;
	[photoStripView initWithController:controller];
}

#pragma mark touch events
//----------------------------------------------------------------------------------------------------------------------//

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	UITouch *touch = [touches anyObject];	
	NSLog(@"touchesBegan\n");
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
	lastTouchPoint = [touch locationInView:nil];
	
	startTime = touch.timestamp;
	NSUInteger tapCount = [touch tapCount];
	switch (tapCount) {
		case 1:
			touchStart = touch;
			[self performSelector:@selector(highlightTarget) withObject:nil afterDelay:0.5];
			break;
		case 2:
//			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
			break;
		default:
			break;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSLog(@"touchesEnded\n");
	
	//	[self performSelector:@selector(highlightTargetUndoAll) withObject:nil afterDelay:0.3];
	
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
//	NSLog(@"tapcount:%d\n", tapCount);

	CGPoint pt = [touch locationInView:self];
//	NSLog(@"startx:%f, endx:%f\n", startLocation.x, pt.x);
	switch (tapCount) {
		case 0:
			if ((touch.timestamp - startTime) < 0.5)										// quick flick
			{
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				NSLog(@"swipe action\n");
				if ((pt.x - startLocation.x) > 10)
				{
					
					[self performSelector:@selector(rightSwipe) withObject:nil afterDelay:0.3];
				}
				if ((startLocation.x - pt.x) > 10)
				{
					[self performSelector:@selector(leftSwipe) withObject:nil afterDelay:0.3];
				}				
			}
			else																			// it's a drag and drop
			{
				NSLog(@"move photo action\n");
				[self movePhoto:touch];
			}
			break;
			
		case 1:
		{
			NSLog(@"single tap actin\n");
			[self singleTap:touch];
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			
			break;
		}
		case 2:
		{
			NSLog(@"double tap action\n");
			[self doubleTap:touch];
			break;
		}
		default:
			break;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesMoved\n");
	//	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
	//it's a flick, not drag
	UITouch *touch = [touches anyObject];
	if((touch.timestamp - startTime) < 0.5) return;
	
	[pageView dragMove:touch];
}

- (void) movePhoto:(UITouch *)touch
{
	[pageView dragEnd:touch];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) highlightTarget
{
	[pageView dragStart:touchStart];
}


- (void) leftSwipe
{
	[pageView nextPage];
}

- (void) rightSwipe
{
	[pageView previousPage];
}

- (void)doubleTap:(UITouch *)touch
{
	NSLog(@"\n double tap detected");

}

- (void)hidePhotoStrip
{
	[photoStripView hideStrip:NO];
}

- (void)changePhotoStrip
{
	if(pageView.landscapeView) return;
	if(!photoStripView.userInteractionEnabled)
	{
		if(pageView.landscapeView) return;
		[self bringSubviewToFront:photoStripView];
		CGRect frame = [photoStripView frame];
		frame.origin.x = 0;
		frame.origin.y = 380;
		[photoStripView setFrame:frame];
		[photoStripView showStrip:YES];		
	}
	else
	{
		photoStripView.autoHideTimerRestart = YES;
	}
}

- (void)singleTap:(UITouch *) touch
{
	NSLog(@"\n single tap detected");
	[pageView singleTap:touch];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	self.pageView = nil;
	self.touchStart = nil;
	self.photoStripView = nil;
	
    [super dealloc];
}


@end
