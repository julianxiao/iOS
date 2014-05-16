//
//  PageView.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 04/09/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "PageView.h"
#import "PageLayoutData.h"
#import "PhotoPosition.h"
#import "ThumbsDataSource.h"
#import "Pagination.h"
#import "BookLayoutViewController.h"
#import "PhotoStripView.h"
#import "LayoutScrollView.h"
#import "PhotoStripView.h"

#import "SingleImageCropViewController.h"
#import "iphotobookThumbnailAppDelegate.h"

#import "URLLoader.h"
#import "JSON.h"
#import "Gallery.h"
#import "DataLoaderQueue.h"
#import "PageViewCropQueue.h"
#import "Env.h"

#import <QuartzCore/QuartzCore.h>

//----------------------------------------------------------------------------------------------------------------------//
@implementation PageView

@synthesize layoutFromBRIC;
@synthesize myViewController;
@synthesize dragStartView;
@synthesize scalingFactor, landscapeView, canShake; 
@synthesize newImageNumHandle, locationHandle;
@synthesize singleImageCropViewController;
//@synthesize magicBorder;


#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
//- (id)initWithPageLayout:(PageLayoutData *)aLayout
- (id)initWithViewController:(BookLayoutViewController *)controller
{
	if (self = [super init]) {
		self.myViewController = controller;		
		scalingFactor = 0.63;
		landscapeView = NO;
	}
	
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = self;
	accelerometer.updateInterval = 1.0f/6.0f;
	canShake = YES;
	
	
	// add scrollview of the photo list, hidden at the back
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.layoutFromBRIC = nil;
	self.myViewController = nil;
	self.dragStartView = nil;
	self.singleImageCropViewController = nil;
	//self.magicBorder = nil;
	
    [super dealloc];
}

#pragma mark rendering
//----------------------------------------------------------------------------------------------------------------------//

- (void) accelerometer:(UIAccelerometer *) accelerometer didAccelerate:(UIAcceleration *) acceleration 
{
	static NSInteger shakeCount = 0;
	static NSDate *shakeStart;
	
	if(!canShake) return;
	
	NSDate *now = [[NSDate alloc] init];
	NSDate *checkDate = [[NSDate alloc] initWithTimeInterval:1.5f sinceDate:shakeStart];
	if([now compare:checkDate] == NSOrderedDescending || shakeStart == nil)
	{
		shakeCount = 0;
		[shakeStart release];
		shakeStart = [[NSDate alloc] init];
	}
	[now release];
	[checkDate release];
	
	if (fabsf(acceleration.x) > 2.0 || fabsf(acceleration.y)>2.0 || fabsf(acceleration.z)>2.0)
	{
		shakeCount ++;
		if (shakeCount > 0)
		{
			canShake = NO;
			[self performSelector:@selector(layoutAlternative) withObject:nil afterDelay:0.3];
			//			[self performSelector:@selector(setCanShake) withObject:nil afterDelay:3];
			shakeCount = 0;
			[shakeStart release];
			shakeStart = [[NSDate alloc] init];
		}
	}
}



- (void) layoutAlternative
{
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;	
	self.layoutFromBRIC	  = [datasource getBRICresultsAlternativeForPage: self.myViewController.currentPageNum];
	[self updateLayoutAnimated];
	canShake = YES;
}

- (void) updateLayoutAnimated{
	[self updateLayoutAnimated: NO];
}

- (void) updateLayoutAnimated: (BOOL) refreshBorder
{
	NSArray	 *subviews;
	UIView *renderedPage = [self getCanvasView];
	[UIView beginAnimations:@"fly" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1];
	
	CGRect rect = renderedPage.frame;
	if(!landscapeView)
	{
		rect.size.height = 200;											
		rect.size.width  = 300;
		rect.origin.x	 = 10;
		rect.origin.y	 = 140;
		scalingFactor = 0.63;
	}
	else
	{
		rect.size.height = 320;											
		rect.size.width  = 480;
		rect.origin.x	 = 0;
		rect.origin.y	 = 0;
		scalingFactor = 1;
	}
	renderedPage.frame = rect;
	
/*	if (refreshBorder) {
		[self refreshMagicBorder];
	}*/
	
	for (PhotoPosition *position in self.layoutFromBRIC.photoPositions) {
		NSString	*imageNum		= position.ourImageID;			
		subviews = [renderedPage subviews];
		UIView *oneImageView = nil;
		for (oneImageView in subviews)
		{
			if ([oneImageView isKindOfClass:[UIImageView class]])	{				
				if (oneImageView.tag == imageNum.intValue) {
					break;
				}
			}
		}
		CGRect rect = oneImageView.frame;		
		CGFloat height	  = scalingFactor*position.lowerRight.y - scalingFactor*position.upperLeft.y;
		CGFloat width     = scalingFactor*position.lowerRight.x - scalingFactor*position.upperLeft.x;
		
		rect.size.height  = height;													
		rect.size.width   = width;													
		rect.origin.x     = scalingFactor*position.upperLeft.x;						
		rect.origin.y     = scalingFactor*position.upperLeft.y;				
		
		oneImageView.frame			= rect;
		
	}
	[UIView commitAnimations];			
}

- (void) dragStart:(UITouch *)touch
{
	UIView *renderedPage = [self getCanvasView];
	CGPoint pt = [touch locationInView:renderedPage];
	NSArray	 *subviews = [renderedPage subviews];
	UIImageView *oneImageView = nil;
	
	for (oneImageView in subviews)
	{
		if ([oneImageView isKindOfClass:[UIImageView class]])
		{				
			if (CGRectContainsPoint([oneImageView frame], pt)) {
				NSLog(@"find image: %d", oneImageView.tag);
				break;
			}
		}
	}
	
	self.dragStartView = oneImageView;
	
	if(self.dragStartView == nil) return;
	
	startLocation = [touch locationInView:oneImageView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
	oneImageView.transform = transform;
	[[oneImageView superview] bringSubviewToFront:oneImageView];
	[UIView commitAnimations];	
}

- (void) dragMove:(UITouch *)touch
{
	if (self.dragStartView == nil) return;
	CGPoint pt = [touch locationInView: self.dragStartView];	
	CGRect frame = [self.dragStartView frame];
	frame.origin.x += (pt.x - startLocation.x);
	frame.origin.y += (pt.y - startLocation.y);
	[self.dragStartView setFrame:frame];
}

- (void) dragEnd:(UITouch *)touch
{
//	if(touch == nil)
//	{
//		NSLog(@"touch object equals nil\n");
//		return;
//	}
	UIView *renderedPage = [self getCanvasView];
	CGPoint pt = [touch locationInView:renderedPage];
	NSArray	 *subviews = [renderedPage subviews];
	UIImageView *oneImageView = nil;
	
	for (oneImageView in subviews)
	{
		if ([oneImageView isKindOfClass:[UIImageView class]])
		{				
			if (CGRectContainsPoint([oneImageView frame], pt)) {
				//			NSLog(@"\nx:%f, %f", pt.x, pt.y);
				break;
			}
		}
	}
	
	if(oneImageView == nil) 
	{
		NSLog(@"invalid End\n");
		return;
	}
	if(self.dragStartView == nil) 
	{
		NSLog(@"invalid Start\n");
		return;
	}
	
	
	self.dragStartView.transform = CGAffineTransformIdentity;
	
	NSInteger index1=-1;
	NSInteger index2=-1;
	for (PhotoPosition *position in self.layoutFromBRIC.photoPositions) {
		NSString	*imageNum		= position.ourImageID;	
		if (self.dragStartView.tag == imageNum.intValue)
		{
			index1 = position.BRICsImageID.intValue;
			NSLog(@"drag start, imageid:%d\n", imageNum.intValue);
			break;
		}
	}	
	
	if(pt.y < 0 || pt.y> renderedPage.frame.size.height) 
	{
		//to do: remove image from page.
		NSLog(@"\n remove image");
		[self removePhoto:self.dragStartView];
	}
	else
	{
		
		for (PhotoPosition *position in self.layoutFromBRIC.photoPositions) {
			NSString	*imageNum		= position.ourImageID;	
			if (oneImageView.tag == imageNum.intValue)
			{
				index2 = position.BRICsImageID.intValue;
				NSLog(@"drag end, imageid:%d\n", imageNum.intValue);
				break;
			}
		}	
		if (index1 == -1 || index2 ==-1)
		{
			NSLog(@"invalid index for swap\n");
			return;
		}
		if (index1 == index2) 
		{
			[self updateLayoutAnimated: NO];
		}
		else
		{
			[self layoutSwap:index1 withImage:index2];
		}
	}
	self.dragStartView = nil;
}

- (void) removePhoto:(UIImageView *) image
{
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;	
	[datasource movePhotoToUnselected:image.tag];
	[image removeFromSuperview];
	
	// ••• June says he knows about this.
	// ••• KC: You refresh the pageView but you need to also refresh the strip.  The removed photo does not appear in the strip right away.
	// ••• KC  In your ADD-a-photo-to-page, the strip IS refreshed, but not when you REMOVE.
	// ••• KC
	// ••• KC  [controller.layoutScrollView.pageView addNewImage:imageNum atLocation:location];
	// ••• KC  in addNewImage --> [self.myViewController.layoutScrollView.photoStripView hideStrip: NO];
	// ••• KC
	// ••• KC: is this my bug?
	
	[datasource getBRICresultsForPageInThread:self.myViewController.currentPageNum forPage:self forMethod:2];
}

-(void) callbacKFromBRICForRemove:(PageLayoutData *) aPagelayout
{
	self.layoutFromBRIC	  = aPagelayout;
	[self updateLayoutAnimated: NO];
	[self.myViewController.layoutScrollView.photoStripView initWithController: self.myViewController];
}

- (void) singleTap:(UITouch *)touch
{
	if(self.landscapeView) return;
	UIView *renderedPage = [self getCanvasView];
	CGPoint pt = [touch locationInView:renderedPage];
	NSArray	 *subviews = [renderedPage subviews];
	UIImageView *oneImageView = nil;
	
	NSLog(@"\nx:%f, %f", pt.x, pt.y);
	
	
	for (oneImageView in subviews)
	{
		if ([oneImageView isKindOfClass:[UIImageView class]])
		{				
			if (CGRectContainsPoint([oneImageView frame], pt)) {
				break;
			}
		}
	}
	
	if(pt.y < 0 || pt.y> renderedPage.frame.size.height) 
	{
		LayoutScrollView * layoutScrollView = (LayoutScrollView *) [self superview];
		[layoutScrollView changePhotoStrip];
	}
	else
	{
		if (oneImageView == nil)               // only unselected , but not gray "X"
			return;
		if (self.singleImageCropViewController == nil)												// create just once but lazily
			self.singleImageCropViewController = [[[SingleImageCropViewController alloc] init] autorelease];
		ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;
		singleImageCropViewController.title = [NSString stringWithFormat:@"%d", oneImageView.tag];
		singleImageCropViewController.thumbsDataSource = datasource;
		singleImageCropViewController.imageNum = oneImageView.tag;
		singleImageCropViewController.pageNum = self.myViewController.currentPageNum;
		
		iphotobookThumbnailAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		
		UINavigationController *navcon = appDelegate.navigationController;
		[navcon pushViewController:singleImageCropViewController animated:YES];					// display 1st layout page	
		
		// set up for next view
		NSString *buttonTitle = [NSString stringWithFormat:@"Page %d", singleImageCropViewController.pageNum+1];
		UINavigationBar  *navBar	 = navcon.navigationBar;
		UINavigationItem *leftButton = navBar.backItem;	
		[leftButton setTitle:buttonTitle];							
	}
	
}



- (UIView *) getCanvasView
{
	NSArray	 *subviews = [self subviews];
	UIView *renderedPage = nil;
	for (renderedPage in subviews)
	{
		if ([renderedPage isKindOfClass:[UIView class]])	
		{	
			if (renderedPage.tag == -1) {
				break;
			}
		}
	}
	return renderedPage;
}

- (void) layoutSwap:(NSInteger)imageid1 withImage: (NSInteger)imageid2
{
	NSLog(@"swap image: %d, %d", imageid1, imageid2);
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;	
	self.layoutFromBRIC	  = [datasource getBRICresultsSwapForPage: self.myViewController.currentPageNum image1:imageid1 image2:imageid2];
	[self updateLayoutAnimated: NO];
}

-(void) callbacKFromBRICForAdd:(PageLayoutData *) aPagelayout
{
	UIView *renderedPage = [self getCanvasView];
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;	
	
	self.layoutFromBRIC	  = aPagelayout;
	BOOL needUpdate = NO;
	for (PhotoPosition *position in aPagelayout.photoPositions) {
		NSString	*imageNum		= position.ourImageID;	
		NSLog(@"photoid: %d\n", imageNum.intValue);
		if(imageNum.intValue == newImageNumHandle)
		{
			NSString	*imageURL		= [datasource.screenImageNames valueForKey: imageNum];
			NSString *autocropURL = [datasource.autocropResultsNames valueForKey: imageNum];
			PageViewCropQueue *queue = [PageViewCropQueue queue];
			queue.imageNum = imageNum;
			queue.imageURL = imageURL;
			queue.autocropURL = autocropURL;
			queue.renderedPage = renderedPage;
			queue.scalingFactor = scalingFactor;
			queue.position = position;
			[[DataLoaderQueue instance] addQueue:queue withCategory: @"pageviewcrop_load"];
			needUpdate = YES;
			break;
		}
	}
	if (needUpdate) 
	{
		[self updateLayoutAnimated: NO];
	}
	
	[self.myViewController.layoutScrollView.photoStripView initWithController: self.myViewController];
	
}


- (void) addNewImage:(NSInteger) newImageNum atLocation:(CGPoint)location
{
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;	
	newImageNumHandle = newImageNum;
	locationHandle = location;
	[self.myViewController.layoutScrollView.photoStripView hideStrip: NO];
	[datasource getBRICresultsForPageInThread:self.myViewController.currentPageNum forPage:self forMethod:1];
	
}

/*- (void) refreshMagicBorder{
	if (self.magicBorder != nil) {
		[self.magicBorder removeFromSuperview];
		self.magicBorder = nil;
	}
	UIView *renderedPage = [self getCanvasView];
	self.magicBorder = [[[MagicBorder alloc] initWithFrame: renderedPage.frame] autorelease];
	int dversion = layoutFromBRIC.ourPageID % 9;
	[self.magicBorder setDversion: dversion];
	CGRect tmprect = CGRectMake(0.0f, 0.0f, renderedPage.frame.size.width,renderedPage.frame.size.height);
	[self.magicBorder setViewRect:tmprect];
	NSMutableArray *borders = [[Env instance].storage valueForKey: @"borders"];
	
	NSString *xmlPath = [[NSBundle mainBundle] pathForResource:[borders objectAtIndex: arc4random() % [borders count]] ofType:nil];
	NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
	[self.magicBorder set_borderXML:xmlData]; //set xml
	[self.magicBorder set_ppi:50];
	[self.magicBorder prepare];
	[self addSubview: self.magicBorder];
	[self sendSubviewToBack: self.magicBorder];
}*/

- (UIView *) setupNewpage: (int) pageNum withSync: (BOOL) sync
{	
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;
	//[datasource writeBRICinputStringToDisk: pageNum];
	self.layoutFromBRIC	  = [datasource getBRICresultsForPage: pageNum];
	NSLog(@"\n\nIn PageView.layOutPage   aLayout = %@", self.layoutFromBRIC);
	
	UIView			  *renderedPage = [[UIView alloc] init];
	renderedPage.tag = -1;
	
	//renderedPage.backgroundColor = [UIColor whiteColor];
	CGRect rect = renderedPage.frame;
	
	if(!landscapeView)
	{
		rect.size.height = 200;											
		rect.size.width  = 300;
		rect.origin.x	 = 10;
		rect.origin.y	 = 140;
		renderedPage.frame = rect;
		rect.size.height = 480;											
		rect.size.width  = 320;
		rect.origin.x	 = 0;
		rect.origin.y	 = 0;
		self.frame = rect;
		scalingFactor = 0.63;
	}
	else
	{
		rect.size.height = 320;											
		rect.size.width  = 480;
		rect.origin.x	 = 0;
		rect.origin.y	 = 0;
		renderedPage.frame = rect;
		rect.size.height = 320;											
		rect.size.width  = 480;
		rect.origin.x	 = 0;
		rect.origin.y	 = 0;
		self.frame = rect;	
		scalingFactor = 1;
	}
		
	[[DataLoaderQueue instance] stopCategory: @"pageviewcrop_load"];
	for (PhotoPosition *position in self.layoutFromBRIC.photoPositions) {
		NSString  *imageNum		= position.ourImageID;
		NSString  *imageURL	= [[datasource screenImageNames] valueForKey: imageNum];
		NSString *autocropURL = [datasource.autocropResultsNames valueForKey: imageNum];
		PageViewCropQueue *queue = [PageViewCropQueue queue];
		queue.imageNum = imageNum;
		queue.imageURL = imageURL;
		queue.autocropURL = autocropURL;
		queue.renderedPage = renderedPage;
		queue.scalingFactor = scalingFactor;
		queue.position = position;
		if (sync) {
			[queue runDelegate];
			[queue applyDelegate];
			[queue stopQueue];
		}else {
			[[DataLoaderQueue instance] addQueue:queue withCategory: @"pageviewcrop_load"];
		}
	}
	//self.layoutFromBRIC = nil;
	renderedPage.backgroundColor = [UIColor whiteColor];
	return renderedPage;
}

- (NSString *) buildLayout{
	NSMutableArray *pages = self.myViewController.thumbsDataSource.currentPagination.pages;
	ThumbsDataSource  *datasource = self.myViewController.thumbsDataSource;
	NSMutableArray *layouts = [NSMutableArray arrayWithCapacity: [pages count]];
	for (int i = 0; i < [pages count]; i++) {
		//[datasource writeBRICinputStringToDisk: i];
		PageLayoutData *layout = [datasource getBRICresultsForPage: i];
		NSMutableArray *page = [NSMutableArray arrayWithCapacity: [layout.photoPositions count]];
		for (PhotoPosition *position in layout.photoPositions) {
			NSString  *imageNum		= position.ourImageID;
			//NSString  *imageURL	= [[datasource screenImageNames] valueForKey: imageNum];
			NSString *autocropURL = [datasource.autocropResultsNames valueForKey: imageNum];
			NSData *data = [URLLoader resourceFor: autocropURL];
			NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
			if ([data length] == 0 || [ret characterAtIndex: 0] != '{') {
				[ret release];
				data = [URLLoader resourceFor: autocropURL withCache: NO];
				ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
			}
			SBJSON *json = [[SBJSON alloc] init];
			NSDictionary *dic = [json objectWithString: ret error: nil];
			[json release];
			[ret release];
			
			NSString *sx = [dic valueForKey: @"startX"];
			float px = [sx floatValue];
			NSString *sy = [dic valueForKey: @"startY"];
			float py = [sy floatValue];
			NSString *sw = [dic valueForKey: @"width"];
			float pw = [sw floatValue];
			NSString *sh = [dic valueForKey: @"height"];
			float ph = [sh floatValue];
			//NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
			//float imgWidth = [[[photoMap valueForKey: imageNum] valueForKey:@"width"] floatValue];
			//float imgHeight = [[[photoMap valueForKey: imageNum] valueForKey:@"height"] floatValue];
			NSMutableDictionary *pic = [NSMutableDictionary dictionaryWithCapacity: 8];
			//[pic setValue: imageNum forKey: @"id"];
			//[pic setValue: imageURL forKey: @"url"];
			[pic setValue: [datasource.activeGallery.filemap valueForKey: imageNum] forKey: @"cropurl"];
			[pic setValue: [NSNumber numberWithFloat: position.upperLeft.x] forKey: @"x"];
			[pic setValue: [NSNumber numberWithFloat: position.upperLeft.y] forKey: @"y"];
			[pic setValue: [NSNumber numberWithFloat: position.lowerRight.y - position.upperLeft.y] forKey: @"height"];
			[pic setValue: [NSNumber numberWithFloat: position.lowerRight.x - position.upperLeft.x] forKey: @"width"];
			[pic setValue: [NSNumber numberWithFloat: px] forKey: @"cropx"];
			[pic setValue: [NSNumber numberWithFloat: py] forKey: @"cropy"];
			[pic setValue: [NSNumber numberWithFloat: pw] forKey: @"cropw"];
			[pic setValue: [NSNumber numberWithFloat: ph] forKey: @"croph"];
			[page addObject: pic];
		}
		[layouts addObject: page];
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity: 2];
	[dic setValue: layouts forKey: @"pages"];
	if(!landscapeView)
	{
		[dic setValue: [NSNumber numberWithInt: 480] forKey: @"width"];
		[dic setValue: [NSNumber numberWithInt: 320] forKey: @"height"];
	}
	else
	{
		[dic setValue: [NSNumber numberWithInt: 480] forKey: @"width"];
		[dic setValue: [NSNumber numberWithInt: 320] forKey: @"height"];
	}
	
	SBJSON *json = [[SBJSON alloc] init];
	NSString *ret = [json stringWithObject: dic error: nil];
	[json release];
	return ret;
}

- (void) nextPage
{	
	
	//to-do: get number of pages correctly
	if (self.myViewController.currentPageNum + 1 == [self.myViewController.thumbsDataSource.currentPagination.pages count]) return;
	
	// clear the screen of previous renderings
	
	UIView *oldpage = [self getCanvasView];
	
	self.myViewController.currentPageNum = self.myViewController.currentPageNum + 1;
	UIView *renderedPage = [self setupNewpage: self.myViewController.currentPageNum withSync: NO];
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setDuration:0.5f];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[self addSubview:renderedPage];	
	
	[[self layer] addAnimation:animation forKey:@"transitionViewAnimation"];	
	[renderedPage release];
	[oldpage removeFromSuperview];
	
	NSString *title = [NSString stringWithFormat:@"Page %d/%d", self.myViewController.currentPageNum+1, self.myViewController.thumbsDataSource.currentPagination.pages.count];
	self.myViewController.title			  = title;
	//[self refreshMagicBorder];
}

- (void) previousPage
{
	if(self.myViewController.currentPageNum==0) return;
	
	// clear the screen of previous renderings
	UIView *oldpage = [self getCanvasView];
	
	self.myViewController.currentPageNum = self.myViewController.currentPageNum - 1;
	UIView *renderedPage = [self setupNewpage: self.myViewController.currentPageNum withSync: NO];
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setDuration:0.5f];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[self addSubview:renderedPage];	
	
	[[self layer] addAnimation:animation forKey:@"transitionViewAnimation"];	
	[renderedPage release];
	[oldpage removeFromSuperview];
	
//	NSString *title = [NSString stringWithFormat:@"Page %d", self.myViewController.currentPageNum +1];
	NSString *title = [NSString stringWithFormat:@"Page %d/%d", self.myViewController.currentPageNum+1, self.myViewController.thumbsDataSource.currentPagination.pages.count];
	self.myViewController.title			  = title;
	//[self refreshMagicBorder];
}


- (void)layOutPage															// based on ThumbnailScrollView.loadImages
{
	
	self.tag  = self.layoutFromBRIC.ourPageID;
	
	// clear the screen of previous renderings
	NSArray	 *subviews = [self.myViewController.layoutScrollView subviews];
	for (UIView *v in subviews)
		if ([v isKindOfClass:[PageView class]])	{	
			if (v.tag == self.layoutFromBRIC.ourPageID) {
				[v removeFromSuperview];
			}
		}
	
	UIView* renderedPage = [self setupNewpage: self.myViewController.currentPageNum withSync: NO];
	[self addSubview:renderedPage];
	[renderedPage release];
	//[self refreshMagicBorder];
}
//----------------------------------------------------------------------------------------------------------------------//
@end
