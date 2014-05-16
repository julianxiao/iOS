//
//  PhotoStripView.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 4/17/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "PhotoStripView.h"
#import "PhotoPosition.h"
#import "ThumbsDataSource.h"
#import "Pagination.h"
#import "BookLayoutViewController.h"
#import "PhotoStripThumbView.h"
#import "LayoutScrollView.h"
#import "PageView.h"
#import "URLLoader.h"

@implementation PhotoStripView;

@synthesize autoHideTimer, myController;
@synthesize autoHideTimerRestart;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
        // Initialization code
		

    }
    return self;
}

- (void) initWithController:(BookLayoutViewController *)controller
{
	
	myController = controller;
	ThumbsDataSource *datasource = myController.thumbsDataSource;
	[self loadImages:datasource];
}


- (void) loadImages: (ThumbsDataSource *) datasource
{
	self.backgroundColor = [UIColor clearColor];	
	NSMutableArray	*unselectedImages = datasource.currentPagination.unselected;
	int count = [unselectedImages count];
	[self setContentSize:CGSizeMake(count*80, [self bounds].size.height)];
	for (UIView *view in [self subviews])
	{
		[view removeFromSuperview];
	}

	for (int i=0; i< count; i++) 
	{
		NSString *imageNumber = [unselectedImages objectAtIndex:i];
		NSString	*imageName  = [datasource.thumbImageNames valueForKey: imageNumber];
		
		NSString	*imagePath  = [URLLoader resourcePathFor: imageName];
		NSLog(@"load image:%@", imagePath);
		UIImage		*image		= [UIImage imageWithContentsOfFile:imagePath];
		UIImageView *imageView	= [[UIImageView alloc] initWithImage:image];	// place image in an imageView
		CGRect rect = imageView.frame;
		rect.size.height = 75;											
		rect.size.width  = 75;
		rect.origin.x	 = 3;
		rect.origin.y	 = 3;
		imageView.frame			= rect;
		imageView.contentMode	= UIViewContentModeScaleAspectFill;
		imageView.clipsToBounds = YES;
		
		CGRect rectView = rect;
		rectView.size.height	= 80;
		rectView.size.width	    = 80;
		rectView.origin.x		= i*80;
		rectView.origin.y		= 0;
		
		PhotoStripThumbView  *myView = [[PhotoStripThumbView alloc] initWithFrame:rectView];  		
		[myView addSubview:imageView];
		myView.backgroundColor = [UIColor whiteColor];
		myView.userInteractionEnabled = YES;
		myView.tag = imageNumber.intValue;
		[self addSubview:myView];
		
		[imageView release];
		[myView release];
	}
//	self.delaysContentTouches = NO;
	self.canCancelContentTouches = NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view 
{
	return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	autoHideTimerRestart = YES;
	
//	NSLog(@"touch began\n");
}




- (void) addPhoto:(NSInteger)imageNum atPoint:(CGPoint) location
{
	BookLayoutViewController *controller = self.myController;
	NSInteger pageNum =  controller.currentPageNum;
	[controller.thumbsDataSource addUnselectedImage:imageNum toPage:pageNum];	
	
	[controller.layoutScrollView.pageView addNewImage:imageNum atLocation:location];

}

-(void)hideStrip: (bool) animated
{
	if(self.autoHideTimer!=nil ) 
	{
		if ([self.autoHideTimer isValid]) 
		{
			[self.autoHideTimer invalidate];
			self.autoHideTimer = nil;
		}
	}
	self.alpha = 1;
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1];
		[self setAlpha:0.0];
		[UIView commitAnimations];	
		
	}
	else
	{
		self.alpha = 0;
	}
	self.userInteractionEnabled = NO;
}
	

-(void)showStrip: (bool) animated
{
	self.autoHideTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autoHide:) userInfo:nil repeats:YES];
	autoHideTimerRestart = NO;
	self.alpha = 0;
	self.userInteractionEnabled = YES;
	if(animated)
	{
		[UIView beginAnimations:NULL context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.5];
		self.alpha = 1;
		[UIView commitAnimations];	
		
	}
	else
	{
		self.alpha = 1;
	}
}

-(void)autoHide:(NSTimer *)theTimer 
{
	if(autoHideTimerRestart)
	{
		autoHideTimerRestart = NO;
	}
	else
	{
		[self hideStrip:YES];
	}
}



- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	if(self.autoHideTimer!=nil)
	{
		if ([self.autoHideTimer isValid]) 
		{
			[self.autoHideTimer invalidate];
			self.autoHideTimer = nil;
		}
	}
	self.myController = nil;
    [super dealloc];
}


@end
