//
//  ThumbnailImageView.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "ThumbnailImageView.h"
#import "ThumbnailScrollView.h"

extern  CGFloat kImageWidth;
extern  CGFloat kImageHeight;
extern  CGFloat kImageGap;

//----------------------------------------------------------------------------------------------------------------------//
@implementation ThumbnailImageView

@synthesize photoName;
@synthesize photoID;
@synthesize positionIndex;
@synthesize pageNumber;
@synthesize pageBreak;
@synthesize badgeView;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		startLocation.x = 0;
		startLocation.y = 0;
		startTime		= 0;
		
		// set up badge space
		UIImageView *uiv = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, 26, 26)];
		self.badgeView = uiv;
		uiv.image		= nil;
		uiv.contentMode	= UIViewContentModeScaleAspectFit;
		[uiv release];
		
		[self addSubview:self.badgeView];
	}
    return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)description 
{
	NSString		*stringToPrint   = [NSString stringWithFormat:
										@"photoID=%d  photoName=%@  positionIndex=%d  pageNumber=%d  pageBreak=%d\n", 
										photoID, photoName, positionIndex, pageNumber,	pageBreak];	
	return [stringToPrint retain];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.photoName = nil;
	self.badgeView = nil;
    [super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark experimental
//----------------------------------------------------------------------------------------------------------------------//
- (void)leftSwipe
{
	NSLog(@"\n left swipe detected -- Calling [self.superview handleLeftSwipe], which will switch into compressedMode.");
	ThumbnailScrollView  *thumbnailScrollView = (ThumbnailScrollView *)[self superview];
	[thumbnailScrollView handleLeftSwipe];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)rightSwipe
{
	NSLog(@"\n right swipe detected -- Calling [superview handleRightSwipe], which will switch out of compressedMode.");
	ThumbnailScrollView  *thumbnailScrollView = (ThumbnailScrollView *)[self superview];
	[thumbnailScrollView handleRightSwipe];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) detectBoundary: (UITouch *)touch
{	
	if (disableScrolling) 
		return;
	
	//	NSLog(@"detect boundary");
	ThumbnailScrollView  *thumbnailScrollView = (ThumbnailScrollView *)[self superview];
	CGPoint thisTouchPoint = [touch locationInView: nil];
	
	NSInteger y1 = lastTouchPoint.y;
	NSInteger y2 = thisTouchPoint.y;
	
	if (y2 > 440  &&  y2-y1 > 0) 
	{
		
		CGPoint pt =  thumbnailScrollView.contentOffset;
		pt.y +=400;
		if (pt.y > thumbnailScrollView.contentSize.height) pt.y = thumbnailScrollView.contentSize.height;
		[thumbnailScrollView setContentOffset:pt animated:YES];
		disableScrolling = YES;
		[self performSelector:@selector(enableScrollingAgain) withObject:nil afterDelay:1];
	}
	if (y2 < 40  &&  y2-y1 < 0) 
	{
		CGPoint pt =  thumbnailScrollView.contentOffset;
		pt.y -=400;
		if (pt.y < 0 ) pt.y = 0;
		[thumbnailScrollView setContentOffset:pt animated:YES];
		disableScrolling = YES;
		[self performSelector:@selector(enableScrollingAgain) withObject:nil afterDelay:1];
	}
	lastTouchPoint = [touch locationInView:nil];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) enableScrollingAgain
{
	disableScrolling = NO;
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark touch events
//----------------------------------------------------------------------------------------------------------------------//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	CGPoint pt = [[touches anyObject] locationInView:self];
	UITouch *touch = [touches anyObject];
	startLocation = pt;
	
	// quick flick
	//	NSLog(@"\ntouchesBegan, for %d", self.positionIndex);
	
	disableScrolling = NO;
	lastTouchPoint = [touch locationInView:nil];
	
	startTime = touch.timestamp;
	NSUInteger tapCount = [touch tapCount];
	switch (tapCount) {
		case 1:
			[self performSelector:@selector(highlightTarget) withObject:nil afterDelay:0.3];
			break;
		case 2:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
			//			[self doubleTap];
			break;
		default:
			break;
	}
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.transform = CGAffineTransformIdentity;											// KC, stop oversized photo
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self highlightTargetUndo];
	UITouch *touch = [touches anyObject];
	
	//it's a flick, not drag
	if((touch.timestamp - startTime) < 0.5) return;
	
	CGPoint pt = [touch locationInView:self];
	CGRect frame = [self frame];
	frame.origin.x += pt.x - startLocation.x;
	frame.origin.y += pt.y - startLocation.y;
	[self setFrame:frame];
	
	[self detectBoundary:touch];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	ThumbnailScrollView *thumbnailScrollView = (ThumbnailScrollView *)[self superview];

// Changed, •• KC 29apr09.  The following line prevented the animation in [scrollView uncompressLayout] -->
//	    [self performSelector:@selector(highlightTargetUndoAll) withObject:nil afterDelay:0.3]; // KC, will redraw screen
//      So I have relocated the call to the "drag and drop" case below & inside conditionals.
	
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	NSLog(@"\ntapcount:%d", tapCount);
	switch (tapCount) {
		case 0:
			if ((touch.timestamp - startTime) < 0.5)										// quick flick
			{
//				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highlightTarget) object:nil];
				NSLog(@"swipe\n");
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				CGPoint pt = [touch locationInView:self];
				if ((pt.x - startLocation.x) > 10)
				{
					if (thumbnailScrollView.currentMode == compressedMode)					// KC, 05may09, works
						[self performSelector:@selector(rightSwipe) withObject:nil afterDelay:0.3];
					else
						[self performSelector:@selector(highlightTargetUndoAll) withObject:nil afterDelay:0.3];
				}
				if ((startLocation.x - pt.x) > 10)
				{	
					if (thumbnailScrollView.currentMode == normalMode)						// KC, 05may09, works
						[self performSelector:@selector(leftSwipe) withObject:nil afterDelay:0.3];
					else
						[self performSelector:@selector(highlightTargetUndoAll) withObject:nil afterDelay:0.3];
				}				
			}
			else																			// it's a drag and drop
			{
				[self performSelector:@selector(highlightTargetUndoAll) withObject:nil afterDelay:0.3];	 // redraws
				[self movePhoto:touches];
			}
			break;
			
		case 1:
//			NSLog(@"\nTimeStamp%f", touch.timestamp - startTime);
			if((touch.timestamp - startTime) < 0.5)
			{
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				[self performSelector:@selector(singleTap) withObject:nil afterDelay:0.3];
//				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highlightTarget) object:nil];
			}
			break;
		case 2:
			[self doubleTap:touch];
			break;
		default:
			break;
	}
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark touch handling
//----------------------------------------------------------------------------------------------------------------------//
- (void) movePhoto:(NSSet *)touches
{
	UITouch *touch = [touches anyObject];
	ThumbnailScrollView *thumbnailScrollView = (ThumbnailScrollView *)[self superview];
	
	if (thumbnailScrollView.currentMode == compressedMode) 
	{
		[thumbnailScrollView handlePageMoveInCompressedMode:(NSSet *)touches];
		return;
	}
	
	CGPoint ptParent = [touch locationInView: thumbnailScrollView];
	NSUInteger row = ptParent.y;
	NSUInteger col = ptParent.x;
	row = row / (kImageHeight + kImageGap);
	col = col / (kImageWidth  + kImageGap);
	NSUInteger tagNum = row * 4 + col + 1;
	
	ThumbnailImageView *view	   = nil;
	ThumbnailImageView *targetView = nil;
	NSArray *subviews = [thumbnailScrollView subviews];
	for (view in subviews)	
	{
		if ([view isKindOfClass:[ThumbnailImageView class]] && view.positionIndex == tagNum)
		{
			targetView = view;
			break;
		}
	}
	
	if (self.pageNumber<0 && targetView.pageNumber<0)						// disallow moves within unselected
		return;
	
	if (targetView != nil)													// disallow move to past the last image
		[thumbnailScrollView movePhotoFrom:self to:targetView]; 	
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) highlightTarget
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.05, 1.05);
	self.transform = transform;
	[[self superview] bringSubviewToFront:self];
	[UIView commitAnimations];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) highlightTargetUndo
{
	// Set the transform back to the identity, thus undoing the previous scaling effect.
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	
	self.transform = CGAffineTransformIdentity;
	
	[[self superview] bringSubviewToFront:self];
	[UIView commitAnimations];	
}
//----------------------------------------------------------------------------------------------------------------------//
-(void) highlightTargetUndoAll
{
	ThumbnailScrollView *thumbnailScrollView = (ThumbnailScrollView *) [self superview];
	
	ThumbnailImageView  *view = nil;
	NSArray *subviews = [thumbnailScrollView subviews];
	for (view in subviews)
	{
		if ([view isKindOfClass:[ThumbnailImageView class]] )
			view.transform = CGAffineTransformIdentity;
	}
	
	if (thumbnailScrollView.currentMode == compressedMode) 
	{
		// In highlightTargetUndoAll.  Exit withdout calling updateLayout if in compressedMode, KC 30apr09		
		return;
	}
		
	[thumbnailScrollView updateLayout];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) singleTap
{
	NSLog(@"\n singleTap detected");
	
	ThumbnailScrollView *thumbnailScrollView = (ThumbnailScrollView *)[self superview];	
	[thumbnailScrollView handleSingleTap:self];
	
	// to do: show individual image
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)doubleTap:(UITouch *)touch
{
	NSLog(@"\n double tap detected");
	
	//	[self.superview makeNewPageFrom:(UIView *)view];
	ThumbnailScrollView *thumbnailScrollView = (ThumbnailScrollView *)[self superview];	
	[thumbnailScrollView handleDoubleTap:touch];
	
	// to do: shuffle acording to motion sensor data.
	//	ThumbnailScrollView  *thumbnailScrollView = (ThumbnailScrollView*)[self superview];
	//	[thumbnailScrollView getClusterResults];
	//	[thumbnailScrollView updateLayoutAnimated];
}
//----------------------------------------------------------------------------------------------------------------------//
@end
