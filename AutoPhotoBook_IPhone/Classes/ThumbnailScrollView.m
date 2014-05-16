//
//  ThumbnailScrollView.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "iphotobookThumbnailAppDelegate.h"
#import "ThumbnailScrollView.h"
#import "ThumbnailImageView.h"
#import "ThumbsDataSource.h"
#import "Pagination.h"
#import "Page.h"
#import "PaginationParser.h"

#import "GalleriesViewController.h"
#import "Gallery.h"
#import "BookLayoutViewController.h"
#import "SingleImageViewController.h"

#import "AutoCropQueue.h"

#import "URLLoader.h"
#import "Gallery.h"
#import "SingleImageGetQueue.h"
#import "SetupImageViewQueue.h"
#import "SelectorInvokeQueue.h"
#import "DataLoaderQueue.h"
#import "Env.h"

const CGFloat		kImageWidth	  = 75;
const CGFloat		kImageHeight  = 75;
const CGFloat		kImageGap	  = 4;

// NOTE: The meaning of -1 for pageNumber			==> image is in unselected group
//       The meaning of -1 for tag or positionIndex	==> image is pageBreak (only in "compressView" method)
//
//				   Page.pageNum		  is 0-based				
//	ThumbnailScrollView.pageNumber    is 1-based
//	ThumbnailScrollView.positionIndex is 1 based

//----------------------------------------------------------------------------------------------------------------------//
@implementation ThumbnailScrollView

@synthesize currentMode;
@synthesize datasource;
@synthesize bookLayoutViewController;
@synthesize singleImageViewController;
//@synthesize activityIndicator;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL) initThumbnailView: (Gallery *) gallery
{
	[self setContentOffset:CGPointZero animated:NO];			// KC 30apr09, start at top of page
	self.alwaysBounceVertical = YES;
	NSLog(@"In initThumbnailView.");
	ThumbsDataSource *tds = [[ThumbsDataSource alloc] init];
	tds.activeGallery = gallery;
	self.datasource	= tds;		// sets up images, parses cluster file, sets curPagination
	[tds release];
	
	self.datasource.activeFilelist		= [self getActiveFilelist	  ];
	self.datasource.activeCollectionNum = [self getActiveCollectionNum];
	[self.datasource initDatasource];							// 1st call to initDatasource
	
	GalleriesViewController			  *rootViewController = [self appDelegate].viewController;
	iphotobookThumbnailViewController *viewCon			  = rootViewController.thumbnailViewController;

	[viewCon setTitle: self.datasource.activeGallery.title];
	self.backgroundColor = [UIColor whiteColor];
	for(UIView *view in [self subviews])
	{
		[view removeFromSuperview];
	}
	
//	UIActivityIndicatorView *uiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
//	[uiv setCenter:CGPointMake(160.0f, 208.f)];
//	[uiv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//	[[self superview] addSubview:uiv];
//	[uiv startAnimating];
//	self.activityIndicator = uiv;
//	[uiv release];																			// KC, okay

	[self loadImages];
	self.currentMode  = normalMode;
	
	if (bookLayoutViewController != nil)												
	{
		bookLayoutViewController.currentPageNum = 0;
//		bookLayoutViewController.title			  = @"Page 1";
	}
	return YES;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSDictionary *)getActiveFilelist
{
	GalleriesViewController	 *rootViewController = [self appDelegate].viewController;
	
	NSUInteger currentGalleryNum  = rootViewController.indexOfCurrentGallery;
	Gallery    *galleryTapped	  = [rootViewController.galleries objectAtIndex:currentGalleryNum];
	return galleryTapped.filemap;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSUInteger)getActiveCollectionNum
{
	GalleriesViewController	 *rootViewController = [self appDelegate].viewController;	
	NSUInteger currentGalleryNum  = rootViewController.indexOfCurrentGallery;
	
	return currentGalleryNum;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)setUpNavigationController
{
	GalleriesViewController			  *rootViewController = [self appDelegate].viewController;
	iphotobookThumbnailViewController *viewCon			  = rootViewController.thumbnailViewController;
	
	UINavigationController	*navcon = [self appDelegate].navigationController;
	UINavigationBar			*navBar	= navcon.navigationBar;
	navBar.barStyle = UIBarStyleBlackTranslucent;
	
	UIBarButtonItem *layoutButton = [[UIBarButtonItem alloc]
									 initWithTitle:@"View Book" style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(handleLayoutButton:)];
	
	UINavigationItem *item = [viewCon navigationItem];	
	[item setRightBarButtonItem:layoutButton];
	[layoutButton release];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc 
{
	self.datasource = nil;
	self.bookLayoutViewController = nil;
	self.singleImageViewController = nil;
//	self.activityIndicator = nil;
	
    [super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark shake detection
//----------------------------------------------------------------------------------------------------------------------//
- (void) accelerometer:(UIAccelerometer *) accelerometer didAccelerate:(UIAcceleration *) acceleration 
{
	UIAccelerationValue	length,
	x,
	y,
	z;
	
	//Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * kFilteringFactor + myAccelerometer[0] * (1.0 - kFilteringFactor);
	myAccelerometer[1] = acceleration.y * kFilteringFactor + myAccelerometer[1] * (1.0 - kFilteringFactor);
	myAccelerometer[2] = acceleration.z * kFilteringFactor + myAccelerometer[2] * (1.0 - kFilteringFactor);
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[0];
	z = acceleration.z - myAccelerometer[0];
	
	//Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	// If above a given threshold, play the erase sounds and erase the drawing view
	if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
		[self performSelector:@selector(clusterAlternative) withObject:nil afterDelay:0.3];

		lastTime = CFAbsoluteTimeGetCurrent();
	}
}
//----------------------------------------------------------------------------------------------------------------------//
-(void) clusterAlternative
{
	[self.datasource updateAlternative];
	NSInteger unselectedPos;
	for (unselectedPos=datasource.numberOfImages; unselectedPos>0; unselectedPos--)
	{
		ThumbnailImageView *view = [self viewHavingPositionIndex:unselectedPos]; 
		if (view.pageNumber > 0)
			break;
	}
	unselectedPos ++;
	ThumbnailImageView *thumbUnselected = [self viewHavingPositionIndex:unselectedPos];
	
	NSInteger  imgScreenIndex = 1;	
	for (Page *page in datasource.currentPagination.pages)
	{
		NSInteger  imgPageIndex = 1;
		for (NSString *imageNumString in page.imageNums) 
		{
			NSInteger imageNum = imageNumString.intValue;
			ThumbnailImageView *thumb = [self viewHavingPhotoID:imageNum];
			thumb.pageNumber = page.pageNum + 1;
			thumb.positionIndex = imgScreenIndex;
			if(imgPageIndex == 1)
			{
				thumb.pageBreak = YES;
			}
			else 
			{
				thumb.pageBreak = NO;
			}
			imgPageIndex ++;
			imgScreenIndex ++;
		}
		page.pageChanged = YES;
	}
	
	thumbUnselected.pageBreak = YES;
	thumbUnselected.pageNumber = -1;
	thumbUnselected.positionIndex = imgScreenIndex;
	imgScreenIndex ++;
	
	for (NSString *imageNumString in datasource.currentPagination.unselected) 			// other unselected images
	{
		NSInteger imageNum = imageNumString.intValue;
		ThumbnailImageView *thumb = [self viewHavingPhotoID:imageNum];
		thumb.pageNumber = -1;
		thumb.pageBreak = NO;
		thumb.positionIndex = imgScreenIndex;
		imgScreenIndex ++;
	}

	[self updateLayoutAnimated];	// uses imageView.positionIndex's to lay down the images
	[self updateCurPagination];		// forces call to BRIC for page 1, even with no changes
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark loading the images
//----------------------------------------------------------------------------------------------------------------------//
- (void)loadComplete
{
	NSInteger numImages  = datasource.numberOfImages;	
	[self setUpNavigationController];
	[self setContentSize:CGSizeMake([self bounds].size.width, ((numImages+1)/4 +2)* kImageHeight)];
	//[activityIndicator stopAnimating];
	//[activityIndicator removeFromSuperview];
	self.alpha = 1;
	//[self updateLayout];										// uses imageView.positionIndex's to lay down the images
	[self updateCurPagination];									// forces call to BRIC for page 1, even with no changes
	
	self.datasource.keepPageChangedFalseWhileLoading = NO;		// needs revision, à la Jun
//	NSLog(@"keepPageChangedFalseWhileLoading set to NO");	
	
	// sometimes images are not visible even though they are loaded. weird.
	self.alpha = 1;
}

//----------------------------------------------------------------------------------------------------------------------//
- (void)loadImages					  // Called just once. Does the initial setup, uses the parsed cluster-analysis file.
{	
	// ------ images in pages ------	
	
	NSInteger  imgScreenIndex = 1;													// view.positionIndex is 1 based
	for (Page *page in datasource.currentPagination.pages)							// images in pages
	{
		NSInteger  imgPageIndex = 1;
		for (NSString *imageNum in page.imageNums) 
		{
			NSDictionary *dic = [datasource thumbImageNames];
			NSString	*imageURL  = [dic valueForKey: imageNum];
			if (imageURL == nil) {
				NSLog(@"Warning: %@ not found.", imageNum);
				continue;
			}
			UIImageView *imageView	= [[UIImageView alloc] init];	// place image in an imageView

			SingleImageGetQueue *queue = [SingleImageGetQueue queue];
			queue.url = imageURL;
			queue.target = imageView;
			[[DataLoaderQueue instance] addQueue: queue withCategory: @"thumbnail_get"];
			
			AutoCropQueue *aq = [AutoCropQueue queue];
			aq.cropURL = [datasource.autocropResultsNames valueForKey: imageNum];
			[[DataLoaderQueue instance] addQueue: aq withCategory: @"thumbnail_get"];

			SetupImageViewQueue *sq = [SetupImageViewQueue queue];
			sq.imageView = imageView;
			sq.pageNum = page.pageNum;
			sq.imgName = imageURL;
			sq.imgNameIndex = [imageNum intValue];
			sq.imgPageIndex = imgPageIndex++;
			sq.imgScreenIndex = imgScreenIndex++;
			sq.target = self;
			[[DataLoaderQueue instance] addQueue: sq withCategory: @"thumbnail_get"];
			
			[imageView release];
		}
		NSLog(@"Page %d\n", page.pageNum);
	}
	
	
	// ------ images not in pages (unselected) ------	
	
	NSInteger  imgPageIndex = 1;													// 1st unselected position (blank)
	{																					
		// place nil in imageView, so no photo
		UIImageView *imageView2		= [[UIImageView alloc] initWithImage:nil];	
		UIImage		*cameraIcon		= [UIImage imageNamed:@"delete.png"];
		UIImageView *cameraIconView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 14, 48, 48)];
		cameraIconView.image = cameraIcon;
		[imageView2 addSubview:cameraIconView];
		[cameraIconView release];	

		SetupImageViewQueue *sq = [SetupImageViewQueue queue];
		sq.imageView = imageView2;
		sq.pageNum = -2;
		sq.imgName = @"blank";
		sq.imgNameIndex = -1;
		sq.imgPageIndex = imgPageIndex++;
		sq.imgScreenIndex = imgScreenIndex++;
		sq.target = self;
		[[DataLoaderQueue instance] addQueue: sq withCategory: @"thumbnail_get"];
		
		[imageView2 release];					
	}
	
	for (NSString *imageNum in datasource.currentPagination.unselected) 			// other unselected images
	{
		NSString	*imageURL  = [datasource.thumbImageNames valueForKey: imageNum];
		UIImageView *imageView3	= [[UIImageView alloc] init];		// place image in an imageView
		SingleImageGetQueue *queue = [SingleImageGetQueue queue];
		queue.url = imageURL;
		queue.target = imageView3;
		[[DataLoaderQueue instance] addQueue: queue withCategory: @"thumbnail_get"];

		AutoCropQueue *aq = [AutoCropQueue queue];
		aq.cropURL = [datasource.autocropResultsNames valueForKey: imageNum];
		[[DataLoaderQueue instance] addQueue: aq withCategory: @"thumbnail_get"];
		
		SetupImageViewQueue *sq = [SetupImageViewQueue queue];
		sq.imageView = imageView3;
		sq.pageNum = -2;
		sq.imgName = imageURL;
		sq.imgNameIndex = [imageNum intValue];
		sq.imgPageIndex = imgPageIndex++;
		sq.imgScreenIndex = imgScreenIndex++;
		sq.target = self;
		[[DataLoaderQueue instance] addQueue: sq withCategory: @"thumbnail_get"];
		
		[imageView3 release];					
	}
	SelectorInvokeQueue *siq = [SelectorInvokeQueue queue];
	siq.target = self;
	siq.selector = @selector(loadComplete);
	[[DataLoaderQueue instance] addQueue: siq withCategory: @"thumbnail_get"];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)setUpImageView:(UIImageView *)imageView forPageNum:(NSInteger)pageNum imageName:(NSString *)imgName 
		imageNameIndex:	  (NSInteger)imgNameIndex
		imagePageIndex:	  (NSInteger)imgPageIndex
   andImageScreenIndex:	  (NSInteger)imgScreenIndex
{
	CGRect rect = imageView.frame;
	rect.size.height = kImageHeight;											
	rect.size.width  = kImageWidth;
	rect.origin.x	 = kImageGap;
	rect.origin.y	 = kImageGap;
	imageView.frame			= rect;
	imageView.contentMode	= UIViewContentModeScaleAspectFill;
	imageView.clipsToBounds = YES;
	
	CGRect rectView = rect;
	rectView.size.height	+= kImageGap;
	rectView.size.width		+= kImageGap;
	rectView.origin.x		= 0;
	rectView.origin.y		= 0;
	
	ThumbnailImageView  *myView = [[ThumbnailImageView alloc] initWithFrame:rectView];  // maybe use "LayoutScrollView"
	
	if (imgPageIndex == 1) 
		myView.pageBreak = YES;
	else
		myView.pageBreak = NO;
	
	myView.photoName		= imgName;											
	myView.pageNumber		= pageNum + 1;						// page.pageNum is 0 based.  view.pageNumber is 1 based	
	myView.photoID			= imgNameIndex;										// stays constant
	myView.positionIndex	= imgScreenIndex;									// view.positionIndex is 1 based
	
	if (pageNum==-2  &&  imgPageIndex==1) 										// for blank, gray start of unselected
		imageView.backgroundColor	= [UIColor grayColor];
	
	[myView addSubview:imageView];	
	[self addSubview:myView];													// place in self.view
	
	[myView release];	
}		
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark normal layout
//----------------------------------------------------------------------------------------------------------------------//
- (void)updateLayout
{
	if (self.currentMode == compressedMode) 
	{
		NSLog(@"In updateLayout.  Since in compressedMode, we call compressView");						 // KC, 30apr09
		[self compressView];
		return;
	}
	
	NSLog(@"In updateLayout.");	
	ThumbnailImageView *view = nil;
	NSArray *subviews = [self subviews];
	
	// reposition all image subviews in a tile fashion
	for (view in subviews)
	{
		if ([view isKindOfClass:[ThumbnailImageView class]] && (ThumbnailImageView *)view.positionIndex > 0)
		{
			CGRect frame   = view.frame;
			NSUInteger row = (view.positionIndex-1) / 4;
			NSUInteger col = (view.positionIndex-1) % 4;
			frame.origin   = CGPointMake(col*(kImageGap + kImageWidth), row *(kImageGap+kImageHeight));
			view.frame     = frame;
			
			[self removeBadgeFromView:view];
			if (view.pageBreak)
				[self addBadgeToView:view pageNumber:view.pageNumber];									// why 2nd param?
			
			if (view.pageNumber < 0)					
				view.alpha = 0.5;
			else
				view.alpha = 1.0;
		}
	}
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) updateLayoutAnimated
{	
	[UIView beginAnimations:@"fly" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	[self updateLayout];
	
	[UIView commitAnimations];	
	NSLog(@"Exit updateLayoutAnimated.");
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)addBadgeToView:(ThumbnailImageView *)view pageNumber:(NSInteger)pageNumber	   // view.pageNumber is 1-based
{
	if (pageNumber <= 0) 
		return;												// works
	if (!view.pageBreak) 
		return;			
	
	if (view.pageNumber != pageNumber) {
		NSLog(@"\n\n\nSevere error in addBadge.  PageNumbers out of sync.  %d != %d\n\n\n", view.pageNumber, pageNumber);
		return;
	}

//	NSLog(@"In addBadgeToView.    \nview = %@", [view description]);
	view.badgeView.image = [UIImage imageNamed:@"badge-bigger.png"];
	
	// remove old label
	NSArray	 *subviews = [view.badgeView subviews];
	for (UIView *v in subviews)														  // get rid of old badgePageNum label
		if ([v isKindOfClass:[UILabel class]])
			[v removeFromSuperview];	
	
	UILabel  *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 6, 15, 14)];
	badgeLabel.backgroundColor   = [UIColor clearColor];
	if (pageNumber >= 10)
		badgeLabel.textAlignment = UITextAlignmentLeft;
	else
		badgeLabel.textAlignment = UITextAlignmentCenter;
	
	badgeLabel.font		 = [UIFont boldSystemFontOfSize:13];
	badgeLabel.textColor = [UIColor whiteColor];
	badgeLabel.text		 = [NSString stringWithFormat:@"%d", pageNumber];
	
	[view.badgeView addSubview:badgeLabel];
	[badgeLabel release];
	[view bringSubviewToFront:view.badgeView];
}	
//----------------------------------------------------------------------------------------------------------------------//
- (void)removeBadgeFromView:(ThumbnailImageView *)view
{
	NSArray	 *subviews = [view.badgeView subviews];
	for (UIView *v in subviews)														   // get rid of badgePageNum label
		if ([v isKindOfClass:[UILabel class]]  &&  ![((UILabel *)v).text isEqualToString:@"X"])	  // stop "X" disappearing
			[v removeFromSuperview];	

	view.badgeView.image = nil;														   // get rid of badgeImage
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark compressed layout
//----------------------------------------------------------------------------------------------------------------------//
- (void)compressView
{
	NSLog(@"In compressView.");
	self.currentMode = compressedMode;	
	
	ThumbnailImageView *view = nil;
	NSArray *subviews = [self subviews];
	
	// put "stack icon" behind all pageheads
	for (view in subviews)
	{	
		if ([view isKindOfClass:[ThumbnailImageView class]]) 
		{
			if ([(ThumbnailImageView *)view positionIndex] > 0)
			{
				if (view.pageBreak== YES)
				{
					UIImage		*image		= [UIImage imageNamed:@"border.png"];		// make background look like stack
					UIImageView	*imageView	= [[UIImageView alloc] initWithImage:image];
					
					CGRect rect = imageView.frame;
					rect.size.height = kImageHeight+kImageGap;
					rect.size.width  = kImageWidth+kImageGap;
					imageView.frame  = rect;
					imageView.alpha  = 0.0;
					
					imageView.tag    = -1;			// KC: apparently a flag to indicate this imageview is on a pageBreak
									
					[view addSubview:imageView];
					[imageView release];
				}
			}
		}
	}
	
	// reposition all image subviews in groups, stacking up all images of a page with pagehead on top
	[UIView beginAnimations:@"compress" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1];										// 1 sec. seems too fast for all that movement
	
	// scroll to the top of page before it compresses
	[self setContentOffset:CGPointZero animated:YES];	
	[self layoutCompressedView];	
	
	[UIView commitAnimations];
	[self setContentOffset:CGPointZero animated:YES];						// scroll to top a 2nd time
	[self performSelector:@selector(hideNonpagebreakViews) withObject:nil afterDelay:1];  

	[self setContentOffset:CGPointZero animated:YES];						// scroll to top 3rd time
	
	NSLog(@"Exit compressView.");
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)layoutCompressedView  
{
	NSLog(@"In layoutCompressedView.");
	self.currentMode = compressedMode;	
	
	NSMutableArray	*unselecteds = [NSMutableArray array];
	
	// *** selecteds & unselecteds ***
	for (ThumbnailImageView	*view in [self subviews])
	{
		if ([view isKindOfClass:[ThumbnailImageView class]]) 
		{
			if ([view positionIndex] > 0)
			{
				CGRect frame = view.frame;
				if (view.pageNumber != -1)												// selected ones
				{
					NSUInteger row = (view.pageNumber-1) / 4;
					NSUInteger col = (view.pageNumber-1) % 4;
					frame.origin = CGPointMake(col*(kImageGap + kImageWidth), row *(kImageGap + kImageHeight));
					view.frame  = frame;
					
					if (view.pageBreak)
					{
						view.hidden = NO;
						
						//find the border image and change its alpha value to 1
						NSArray		*subviewsTemp = [view subviews];
						UIImageView *viewTemp = nil;
						
						for (viewTemp in subviewsTemp)
							if (viewTemp.tag == -1)
							{
								viewTemp.alpha = 1.0;
								break;
							}
					}
					
					if (view.pageBreak) {
						[[view superview] bringSubviewToFront:view];					// make sure page-head is on top
						[view bringSubviewToFront:view.badgeView];						// don't let badge be in background
					}
				}
				else																	// unselected ones
				{
					// *** put unselecteds into an array ***
					[unselecteds addObject:view];										// handled below in for-loop
				}
			}
		}
	}
	
	// *** unselecteds only ***
	int indexOfFirstUnselected = 10000;													// we're looking for the gray "X"
	for (ThumbnailImageView *view in unselecteds)										// gray "X" has the lowest posIndex
		if (view.positionIndex < indexOfFirstUnselected)
			indexOfFirstUnselected = view.positionIndex;
	
	NSUInteger numPages			  = datasource.currentPagination.pages.count;			// fix up locations of unselected
	NSUInteger compressedPosIndex = numPages;
	for (int i=indexOfFirstUnselected; i<=datasource.numberOfImages+1; i++)				// + 1 extra because of the "X"
	{
		ThumbnailImageView  *view = [self viewHavingPositionIndex:i];
				
		view.alpha     = 0.5;
		view.hidden	   = NO;	
		
		compressedPosIndex++;
		NSUInteger row = (compressedPosIndex-1) / 4 ;									 
		NSUInteger col = (compressedPosIndex-1) % 4;
		
		CGRect frame   = view.frame;		
		frame.origin   = CGPointMake(col*(kImageGap + kImageWidth), row *(kImageGap + kImageHeight));
		view.frame	   = frame;
		
		view.userInteractionEnabled = NO;		// ••• KC, 30apr09 - temporary, needs to be enabled for adding to a page
	}

	// make the scrollview height match the smaller number of photos in compressedView
	NSUInteger nonPageheads					  = indexOfFirstUnselected    - datasource.currentPagination.pages.count;
	NSUInteger numberOfImagesInCompressedMode = datasource.numberOfImages - nonPageheads;	
	[self setContentSize:CGSizeMake([self bounds].size.width, ((numberOfImagesInCompressedMode+1)/4 +2) * kImageHeight)];
	
	NSLog(@"Exit layoutCompressedView.");
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)hideNonpagebreakViews
{
	if (currentMode != compressedMode)
		return;
	
	NSArray *subviews = [self subviews];	
	for (ThumbnailImageView *view in subviews)
		if ([view isKindOfClass:[ThumbnailImageView class]] && [(ThumbnailImageView *)view positionIndex] > 0)
			if (view.pageNumber != -1) 
			{
				if (view.pageBreak == NO)
				{
					// selected but not pagehead or unselected, so hid it in compressed mode
					view.hidden = YES;
				}
				else
					view.hidden = NO;
			}
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)uncompressView
{
	NSLog(@"In uncompressView.");
	self.currentMode = normalMode;	
		
	// make the scrollview height right for the full imageset again 
	[self setContentSize:CGSizeMake([self bounds].size.width, ((datasource.numberOfImages+1)/4 +2)* kImageHeight)];
	
	// scroll to the top of page
	[self setContentOffset:CGPointZero animated:YES];
	
	[UIView beginAnimations:@"uncompress" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	[self uncompressLayout];	
	[UIView commitAnimations];
	
	[self setContentOffset:CGPointZero animated:YES];								// scroll to the top of page again

	NSLog(@"Exit uncompressView.");
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)uncompressLayout
{
	NSLog(@"In uncompressLayout."); 
	self.currentMode = normalMode;	

	// reposition all image subviews in a tile fashion
	NSArray *subviews = [self subviews];
	for (ThumbnailImageView *view in subviews)
	{
		if ([view isKindOfClass:[ThumbnailImageView class]])
			if ((ThumbnailImageView *)view.positionIndex > 0)
			{
				if (view.pageBreak == YES  &&  view.pageNumber > 0)					// pageheads
				{
					// find the border image and remove it
					NSArray		*subviewsTemp = [view subviews];
					for (UIImageView *viewTemp in subviewsTemp)
					{					
						if (viewTemp.tag == -1)
							[viewTemp removeFromSuperview];							// get rid of the stacked appearance
					}
				}

				view.hidden	   = NO;						
				view.transform = CGAffineTransformIdentity;							// stop highlighting photo

				CGRect frame   = view.frame;
				NSUInteger row = (view.positionIndex-1) / 4;
				NSUInteger col = (view.positionIndex-1) % 4;
				frame.origin   = CGPointMake(col*(kImageGap + kImageWidth), row *(kImageGap + kImageHeight));
				view.frame     = frame;
				view.userInteractionEnabled = YES;	

				if (view.pageNumber < 0)				
					view.alpha = 0.5;
				else
					view.alpha = 1.0;
			}
	}
	
	NSLog(@"Exit uncompressLayout.");
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark move an image
//----------------------------------------------------------------------------------------------------------------------//
- (void) movePhotoFrom:(ThumbnailImageView *)fromImage to:(ThumbnailImageView *)toImage
{
	// KC •• commented out to see if it still crashes -- no crash yet (08may09).
//	if (self.currentMode == compressedMode) 
//	{
//		NSLog(@"In movePhotoFrom:to:.  Exit at start if in compressedMode");							// KC, 30apr09
//		return;
//	}
	
	// invalid moves
	if (toImage == nil) {													// disallow move to past last unselected image
		return;
	}
	if (fromImage.pageBreak  &&  fromImage.pageNumber==-1) {				// disallow move from first unselected (gray)
		return;
	}
	if (fromImage.positionIndex  == toImage.positionIndex) {				// disallow moves on top of oneself
		return;
	}
	if (fromImage.pageNumber  == toImage.pageNumber) {						// disallow moves within a page: KC, 20apr09
		return;
	}
	
	BOOL  fromIsPageBreak = fromImage.pageBreak;
	
	NSUInteger fromPositionIndex = fromImage.positionIndex;					// view.positionIndex is 1 based
	NSUInteger toPositionIndex   = toImage.positionIndex;
	ThumbnailImageView	*originalFromImage = fromImage;						
//	ThumbnailImageView	*originalToImage   = toImage;
	
	NSLog(@"from:%d, to: %d", fromPositionIndex, toPositionIndex);					
	[self infoAboutImagesFrom:fromPositionIndex to:toPositionIndex];					
	
	[self adjustPageNums:			fromImage to:toImage];					// The moving is done here and
	[self adjustPositionIndexes:	fromImage to:toImage];					//     here.

	if (currentMode == compressedMode)
	{
		if (toImage.pageNumber == -1  &&  fromIsPageBreak)					// get rid of the stacked appearance
		{
			[self removeBadgeFromView:fromImage];							// get rid of the badge
																			// add badge to view to right of orig
//			ThumbnailImageView	*toTheRight = [self viewHavingPositionIndex:fromPositionIndex];
//			[self addBadgeToView:[self viewHavingPositionIndex:fromPositionIndex] pageNumber:toTheRight.pageNumber];	
			[self updateBadges];											// adjust pageNums again
			
			// find the border image and remove it
			NSArray		*subviewsTemp = [originalFromImage subviews];		// get rid of the stacked appearance
			for (UIImageView *viewTemp in subviewsTemp)
			{					
				if (viewTemp.tag == -1)										// is -1 valid at this point?
					[viewTemp removeFromSuperview];							 
			}
		}
	}
	
	[self updateCurPagination];			// moved to below, 08my09			// keep curPagination up-to-date: used by BRIC
	[self updateLayoutAnimated];											
//	[self updateCurPagination];												// keep curPagination up-to-date: used by BRIC
	
	[self infoAboutImagesFrom:fromPositionIndex to:toPositionIndex];					
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) makeNewPageFrom:(ThumbnailImageView *)tappedImage
{
	if (tappedImage.pageNumber <= 0)						 
	{
		[self makeNewPageFromUnselectedImage:tappedImage];					
		return;
	}
	
	NSUInteger	 startPosition	= tappedImage.positionIndex;
	NSUInteger	 end			= [self subviews].count;
	NSUInteger	 i;
	
	BOOL  noneOnLeft  = NO;			
	BOOL  noneOnRight = NO;		
	
	if (tappedImage.pageBreak)											// check left for members of this page
		noneOnLeft    = YES;
	if ([self viewHavingPositionIndex:startPosition+1].pageBreak)			// check right for members of this page
		noneOnRight   = YES;	
	
	// --------------------  handle singleton pages							
	if (noneOnLeft && noneOnRight)											// is singleton page, do nothing
		return;
	// --------------------  end singleton pages
	
	if (noneOnLeft) {											// moving head of non-empty page, so make A+1 be head;		
		ThumbnailImageView  *thumb = [self viewHavingPositionIndex:startPosition+1];	// put the badge on photo to right
		thumb.pageBreak = YES;
	}
	
	for (i=startPosition; ; i++) {								// move tappedImage to end of page
		ThumbnailImageView  *img = [self viewHavingPositionIndex:i+1];
		if (img.pageNumber > tappedImage.pageNumber  ||  img.pageNumber <= 0)
			break;
		img.positionIndex--;									// decrement previous positionIndexes (shove them left)
		tappedImage.positionIndex++;							// increment our positionIndex till we hit next page
	}
	
	tappedImage.pageBreak = YES;								// put on badge
	
	for (i=tappedImage.positionIndex; i<=end; i++)	{
		ThumbnailImageView  *img = [self viewHavingPositionIndex:i];
		if (img.pageNumber < 0)									// stop at "unselected" cluster
			break;
		img.pageNumber++;										// increment pageNums of images to our right until end
	}
	
	[self updateLayoutAnimated];		
	[self updateCurPagination];									// keep curPagination up-to-date: used by BRIC
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)makeNewPageFromUnselectedImage:(ThumbnailImageView *)fromImage
{
	NSLog(@"In makeNewPageFromUnselectedImage.  fromImage.pageNumber=%d", fromImage.pageNumber);							
	
	if (fromImage.pageNumber != -1  || fromImage.pageBreak)               // only unselected, except for gray "X"
		return;
	if (currentMode == compressedMode)										// normal mode only, KC 30apr09
		return;
	
	NSUInteger originalFrom = fromImage.positionIndex;
	
	ThumbnailImageView *view;
	NSUInteger i = originalFrom-1;											// find where selected begin
	for (i; i>0; i--) {
		view = [self viewHavingPositionIndex:i]; 
		if (view.pageNumber > 0)
			break;
	}
	
	ThumbnailImageView *toImage = view;
	
	NSLog(@"from:%d, to: %d", originalFrom, toImage.positionIndex);			
	[self infoAboutImagesFrom:originalFrom to:toImage.positionIndex];			
	
	fromImage.pageNumber    = toImage.pageNumber    + 1;	
	fromImage.pageBreak   = YES;											// put on badge
	
	NSUInteger  A = fromImage.positionIndex;
	NSUInteger  B = toImage.positionIndex;
	for (i=A; i>B; i--)														// adjust positionIndexes between FROM & TO
	{
		ThumbnailImageView *view = [self viewHavingPositionIndex:i];
		view.positionIndex++;
		fromImage.positionIndex--;
	}
	
	[self updateLayoutAnimated];
	[self updateCurPagination];												// keep curPagination up-to-date: used by BRIC
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) adjustPageNums:(ThumbnailImageView *)fromImage to:(ThumbnailImageView *)toImage
{
	NSArray		*subviews  = [self subviews];
	NSUInteger	start	   = fromImage.positionIndex;
	NSUInteger	i;	
	
	BOOL  noneOnLeft  = NO;										// did the move make A's page empty?
	BOOL  noneOnRight = NO;		
	if (fromImage.pageBreak)									// check left for members of this page
		noneOnLeft    = YES;
	if ([self viewHavingPositionIndex:start+1].pageBreak)		// check right for members of this page
		noneOnRight   = YES;
	
	if (noneOnLeft && noneOnRight)	{							// no others on A's page, so now that page disappears
		for (i=start+1; i<subviews.count; i++)	{
			ThumbnailImageView  *thumb = [self viewHavingPositionIndex:i];
			if (thumb.pageNumber < 0)							// stop at unselected
				break;
			thumb.pageNumber--;									// decrement pageNums of images to our right until end
		}
	}
	else if (noneOnLeft) {										// start page not empty, so just make A+1 be pageBreak;		
		ThumbnailImageView  *thumb = [self viewHavingPositionIndex:start+1];		// put the badge on photo to right
		thumb.pageBreak = YES;
	}
	
	fromImage.pageNumber = toImage.pageNumber;			
	fromImage.pageBreak  = NO;							
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) adjustPositionIndexes:(ThumbnailImageView *)fromImage to:(ThumbnailImageView *)toImage
{
	NSArray				*subviews = [self subviews];
	ThumbnailImageView	*thumb	  = nil;	
	for (thumb in subviews)													
	{
		if ([thumb isKindOfClass:[ThumbnailImageView class]]  &&  thumb.positionIndex > 0)  // exclude unselected (-1)
		{
			if (thumb.positionIndex > toImage.positionIndex)						// moving down, make room
				thumb.positionIndex++;
			
			if (thumb.positionIndex > fromImage.positionIndex)						// moving up, fill up gap
				thumb.positionIndex--;
		}
	}
	
	fromImage.positionIndex = toImage.positionIndex + 1;							// A's move is just to the right of B
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark move a page
//----------------------------------------------------------------------------------------------------------------------//
- (void)handlePageMoveInCompressedMode:(NSSet *)touches
{
	NSLog(@"In handlePageMoveInCompressedMode.");
	if (currentMode != compressedMode)
		return;

	UITouch *touch		 = [touches anyObject];		
	ThumbnailImageView *tappedView = (ThumbnailImageView*)touch.view;
	
	CGPoint whereDropped = [touch locationInView:self];								// pageNumWhereDropped is 1-based
	NSUInteger row = whereDropped.y / (kImageHeight + kImageGap);
	NSUInteger col = whereDropped.x / (kImageWidth  + kImageGap);	
	NSUInteger pageNumWhereDropped = row*4 + col + 1;								// Page.pageNum is 0-based
																					// ThumbView.pageNumber is 1-based
	NSUInteger numPages = self.datasource.currentPagination.pages.count;
	if (pageNumWhereDropped > numPages)									// dropped beyond last page (ie, in unselected)		 
		[self movePageToUnselected:tappedView.pageNumber];							// move page to unselected
	else
		[self exchangePage:tappedView.pageNumber withPage:pageNumWhereDropped];		// swap	
}	
//----------------------------------------------------------------------------------------------------------------------//
- (void)exchangePage:(NSInteger)pageNumA withPage:(NSInteger)pageNumB				// pageNum is 1-based
{
	NSLog(@"Enter exchangePage:%d  withPage:%d", pageNumA, pageNumB);
	
	if (pageNumA == pageNumB) {
		NSLog(@"pageNumA = pageNumB, so leaving.");
		[UIView beginAnimations:@"flying" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		
		[self layoutCompressedView];				
		[UIView commitAnimations];			
		return;
	}
	
	ThumbnailImageView	*thumbViewA			= [self pageheadForPage:pageNumA];
	ThumbnailImageView	*thumbViewB			= [self pageheadForPage:pageNumB];
	
	Page				*origPageA			= [self.datasource.currentPagination.pages objectAtIndex:pageNumA-1];
	Page				*origPageB			= [self.datasource.currentPagination.pages objectAtIndex:pageNumB-1];
	NSUInteger			numPhotosPageA		= origPageA.imageNums.count;
	NSUInteger			numPhotosPageB		= origPageB.imageNums.count;
	
	NSUInteger			origPositionIndexA	= thumbViewA.positionIndex;
	NSUInteger			origPositionIndexB	= thumbViewB.positionIndex;

	// Moving page downwards (ie, towards end)
	if (pageNumA < pageNumB) 
	{		
		NSUInteger  numPhotosDifference = numPhotosPageB - numPhotosPageA;
		
		NSMutableArray  *photosA		 = [NSMutableArray array];
		NSMutableArray  *photosB		 = [NSMutableArray array];
		NSMutableArray  *photosInbetween = [NSMutableArray array];
		
		for (int i=0; i<numPhotosPageA; i++)									// make array of pageA imageViews
		{
			ThumbnailImageView *thumb = [self viewHavingPositionIndex:origPositionIndexA + i];
			[photosA addObject:thumb];
		}		
		for (int i=0; i<numPhotosPageB; i++)									// make array of pageB imageViews
		{
			ThumbnailImageView *thumb = [self viewHavingPositionIndex:origPositionIndexB + i];
			[photosB addObject:thumb];
		}

		int startPosition = origPositionIndexA + numPhotosPageA;				// get inbetween imageViews
		int endPosition   = origPositionIndexB;				
		for (int i=startPosition; i<endPosition; i++)	
		{
			ThumbnailImageView  *thumb = [self viewHavingPositionIndex:i];
			[photosInbetween addObject:thumb];
		}
		
		for (int i=0; i<numPhotosPageB; i++)									// update B's pageNumber & positionIndexes
		{													
			ThumbnailImageView *thumb = [photosB objectAtIndex:i];
			thumb.positionIndex  = origPositionIndexA + i;			
			thumb.pageNumber	 = pageNumA;
			if (thumb.pageBreak)
				[self addBadgeToView:thumb pageNumber:thumb.pageNumber];	
		}
		
		for (int i=0; i<numPhotosPageA; i++)									// update A's pageNumber & positionIndexes
		{													
			ThumbnailImageView *thumb = [photosA objectAtIndex:i];
			thumb.positionIndex = origPositionIndexB + numPhotosDifference + i;			
			thumb.pageNumber	= pageNumB;
			if (thumb.pageBreak)
				[self addBadgeToView:thumb pageNumber:thumb.pageNumber];		
		}
		
		int count = endPosition-startPosition;									// update inbetween positionIndexes
		for (int i=0; i<count; i++)	
		{
			ThumbnailImageView  *thumb = [photosInbetween objectAtIndex:i];
			thumb.positionIndex = thumb.positionIndex + numPhotosDifference;	
		}		
	}


	// Moving page upwards (ie, towards beginnning)	
	if (pageNumB < pageNumA) 
	{		
		NSUInteger  numPhotosDifference = numPhotosPageA - numPhotosPageB;
		
		NSMutableArray  *photosB		 = [NSMutableArray array];
		NSMutableArray  *photosA		 = [NSMutableArray array];
		NSMutableArray  *photosInbetween = [NSMutableArray array];

		for (int i=0; i<numPhotosPageB; i++)									// get pageB imageViews
		{
			ThumbnailImageView *thumb = [self viewHavingPositionIndex:origPositionIndexB + i];
			[photosB addObject:thumb];
		}		
		for (int i=0; i<numPhotosPageA; i++)									// get pageA imageViews
		{
			ThumbnailImageView *thumb = [self viewHavingPositionIndex:origPositionIndexA + i];
			[photosA addObject:thumb];
		}
		
		int startPosition = origPositionIndexB + numPhotosPageB;				// get inbetween imageViews
		int endPosition   = origPositionIndexA;				
		for (int i=startPosition; i<endPosition; i++)	
		{
			ThumbnailImageView  *thumb = [self viewHavingPositionIndex:i];
			[photosInbetween addObject:thumb];
		}
		
		for (int i=0; i<numPhotosPageA; i++)									// update A's pageNumber & positionIndexes
		{													
			ThumbnailImageView *thumb = [photosA objectAtIndex:i];
			thumb.positionIndex  = origPositionIndexB + i;			
			thumb.pageNumber	 = pageNumB;
			if (thumb.pageBreak)
				[self addBadgeToView:thumb pageNumber:thumb.pageNumber];	
		}
		
		for (int i=0; i<numPhotosPageB; i++)									// update B's pageNumber & positionIndexes
		{													
			ThumbnailImageView *thumb = [photosB objectAtIndex:i];
			thumb.positionIndex = origPositionIndexA + numPhotosDifference + i;			
			thumb.pageNumber	= pageNumA;
			if (thumb.pageBreak)
				[self addBadgeToView:thumb pageNumber:thumb.pageNumber];	
		}
		
		int count = endPosition-startPosition;									// update inbetween positionIndexes
		for (int i=0; i<count; i++)	
		{
			ThumbnailImageView  *thumb = [photosInbetween objectAtIndex:i];			
			thumb.positionIndex = thumb.positionIndex + numPhotosDifference;	
		}
	}
	
	[self updateCurPagination];												// keep curPagination up-to-date: used by BRIC
	
	[UIView beginAnimations:@"flying" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];  

	[self layoutCompressedView];				
	[UIView commitAnimations];	

	NSLog(@"Exit  exchangePage");		
}	
//----------------------------------------------------------------------------------------------------------------------//
- (void)movePageToUnselected:(NSInteger)pageNumA
{
	NSLog(@"In movePageToUnselected: %d", pageNumA);
	
	ThumbnailImageView	*thumbViewA			= [self pageheadForPage:pageNumA];	
	Page				*origPageA			= [self.datasource.currentPagination.pages objectAtIndex:pageNumA-1];
	NSUInteger			numPhotosPageA		= origPageA.imageNums.count;	
	NSUInteger			origPositionIndexA	= thumbViewA.positionIndex;
	NSUInteger			positionIndexOfFirstUnselected;
	
	int i;																		// find start of Unselected;
	int end = self.datasource.numberOfImages + 1;								// add 1 to end for the "X"
	for (i=1; i<end; i++) {
		ThumbnailImageView *thumb = [self viewHavingPositionIndex:i];
		if (thumb.pageNumber < 0)												// stop at "unselected" beginning ("X")
			break;
	}
	positionIndexOfFirstUnselected = i;
			
	NSMutableArray  *thumbsOfA = [NSMutableArray array]; 
	for (int i=0; i<numPhotosPageA; i++)										// get the imageViews of pageA
	{
		ThumbnailImageView *thumb = [self viewHavingPositionIndex:origPositionIndexA + i];
		[thumbsOfA addObject:thumb];
	}		
		
	NSMutableArray  *thumbsAfterA = [NSMutableArray array];						// get the imageViews after pageA
	int start = origPositionIndexA + numPhotosPageA;		
	for (int i=start; i<=end; i++)											
	{
		ThumbnailImageView *thumb = [self viewHavingPositionIndex:i];
		[thumbsAfterA addObject:thumb];
	}		
													
	for (ThumbnailImageView *thumb in thumbsAfterA)								// update pages after orig A
	{
		if (thumb.pageNumber > 0) {
			thumb.pageNumber--;		
			thumb.positionIndex = thumb.positionIndex - numPhotosPageA;	
			if (thumb.pageBreak)
				[self addBadgeToView:thumb pageNumber:thumb.pageNumber];		
		}
		
		if (thumb.pageNumber < 0) {
			if (thumb.positionIndex == positionIndexOfFirstUnselected) {
				thumb.positionIndex = thumb.positionIndex - numPhotosPageA;		// after A's new positions, no change in posIndex
			}
		}
	}
	
	int j = 0;
	for (ThumbnailImageView *thumb in thumbsOfA)								// update imageViews of A
	{
		if (thumb.pageBreak == YES)
		{
			// find the border image and remove it
			NSArray		*subviewsTemp = [thumb subviews];
			for (UIImageView *viewTemp in subviewsTemp)
			{					
				if (viewTemp.tag == -1)
					[viewTemp removeFromSuperview];								// get rid of the stacked appearance
			}
		}

		thumb.pageBreak		= NO;
		thumb.pageNumber	= -1;
		thumb.positionIndex	= positionIndexOfFirstUnselected - numPhotosPageA + 1 + j;
		[self removeBadgeFromView:thumb];										// this line must be here, not above
		j++;
	}
			
	[self updateCurPagination];												// keep curPagination up-to-date: used by BRIC
	
	[UIView beginAnimations:@"flying again" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.5];
	
	[self layoutCompressedView];		
	[UIView commitAnimations];	

	NSLog(@"Exit  movePageToUnselected");												
}	
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark maintain currentPagination
//----------------------------------------------------------------------------------------------------------------------//
- (void)updateCurPagination															
{
	NSString  *paginationString = [self constructNewPaginationStringFromAlteredLayout];	// prepare new string for parser	

	[datasource updateCurrentPagination:paginationString];								// format = cluster-analysis output
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)getBRICinputStringForPage:(NSInteger)pageNum	
{	
	NSError	  *error;
	NSString  *filename = [NSString stringWithFormat:@"%@/BRICinputPage%d.txt", datasource.BRICinputFilesDirectoryPath, 
						   pageNum];		 	
	NSString  *inputString;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
		inputString = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&error];
		return inputString;
	}
	return nil;
}
//----------------------------------------------------------------------------------------------------------------------//		
- (NSString *)constructNewPaginationStringFromAlteredLayout
{					   // run through the images' positionIndexes & construct a string that mimics cluster-analysis output
	NSInteger count = datasource.numberOfImages;
	NSMutableString *stringToPrint	= [NSMutableString string];
	for (int position=1; position<=count; position++) {									// format = cluster-analysis output
		ThumbnailImageView  *thumb = [self viewHavingPositionIndex:position];
		if (thumb == nil) {
			continue;
		}
		if (thumb.pageNumber == -1)														// we hit "unselected" group, stop
			break;
		if (thumb.pageBreak == YES) 
			[stringToPrint appendString:@"|"];											// cluster-analysis page separator
		[stringToPrint appendString:[NSString stringWithFormat:@"%d,", thumb.photoID]]; // imageNum + image separator (',')
	}
	
	return stringToPrint;
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark action methods
//----------------------------------------------------------------------------------------------------------------------//
- (IBAction)handleLayoutButton:(id)sender
{
	if (self.bookLayoutViewController == nil)												// create just once but lazily
	{
		BookLayoutViewController *bvc = [[BookLayoutViewController alloc] init];
		self.bookLayoutViewController = bvc;
		[bvc release];
		bookLayoutViewController.title			  = @"Page 1";
	}
	
	bookLayoutViewController.thumbsDataSource = self.datasource;
	
	UINavigationController *navcon = [self appDelegate].navigationController;
	[navcon pushViewController:bookLayoutViewController animated:YES];					// display 1st layout page	
	
	// set up for next view
	UINavigationBar  *navBar	 = navcon.navigationBar;
	UINavigationItem *leftButton = navBar.backItem;	
	[leftButton setTitle: self.datasource.activeGallery.title];		
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) handleSingleTap:(ThumbnailImageView*) image
{
	
	if (image.pageNumber == -1  && image.pageBreak)									// only unselected, but not "X"
	{
		//[self takePhoto];
		return;
	}
	if (self.singleImageViewController == nil)												// create just once but lazily
		self.singleImageViewController = [[[SingleImageViewController alloc] init] autorelease];
	
	singleImageViewController.thumbsDataSource = self.datasource;
	singleImageViewController.imageNum = image.photoID;
	singleImageViewController.pageNum = image.pageNumber;
	
	UINavigationController *navcon = [self appDelegate].navigationController;
	[navcon pushViewController:singleImageViewController animated:YES];					// display fullview page	
	
	// set up for next view
	UINavigationBar  *navBar	 = navcon.navigationBar;
	UINavigationItem *leftButton = navBar.backItem;	
	[leftButton setTitle: self.datasource.activeGallery.title];							
}

//----------------------------------------------------------------------------------------------------------------------//
- (void) takePhoto
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:@"Only the iPhone has a camera, not the iPod Touch." 
							  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsImageEditing = NO;
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[[self navController] presentModalViewController:picker animated:YES];
	[picker release];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *) image 
			editingInfo:(NSDictionary *)editingInfo
{
	NSInteger currentNumber = datasource.numberOfImages + 1;
	NSString  *imageName = [NSString stringWithFormat:@"capture%d.jpg", currentNumber];
	float thumbW = 75;
	float thumbH = 100;
	float screenW = 360;
	float screenH = 480;
	float fullW = 600;
	float fullH = 800;
	
	if(image.size.width > image.size.height)
	{
		thumbH = 75;
		thumbW = 100;
		screenH = 360;
		screenW = 480;
		fullH = 600;
		fullW = 800;
	}
	
	UIGraphicsBeginImageContext(CGSizeMake(fullW, fullH));  
    [image drawInRect:CGRectMake(0, 0, fullW, fullH)];  
	UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	NSData *data = UIImageJPEGRepresentation(fullImage, 0.6f);
	
	//uploadPhotoSer.do?albumId=xxx&token=xxx&name=xxx
	NSURL *url = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@/uploadPhotoSer.do", [Env instance].serverURL]];
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL: url];
	[req setHTTPMethod: @"POST"];
	[req setHTTPBody: data];
	[req addValue: @"123" forHTTPHeaderField: @"token"];
	[req addValue: @"camera.jpg" forHTTPHeaderField: @"name"];
	[req addValue: self.datasource.activeGallery.uuid forHTTPHeaderField: @"aid"];
	[req setValue:@"application/octet-stream" forHTTPHeaderField: @"Content-Type"];
	NSURLResponse *resp = nil;
	NSData *d = [NSURLConnection sendSynchronousRequest: req returningResponse: &resp error: nil];
	NSString *ret = [[NSString alloc] initWithData: d encoding: NSUTF8StringEncoding];
	NSLog(@"%@", ret);
	NSRange split = [ret rangeOfString: @"|"];
	NSString *pid = nil;
	if (split.length > 0) {
		pid = [ret substringToIndex: split.location];
		NSString *url = [ret substringFromIndex: split.location + split.length];
		url = [url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString *fullURL = [NSString stringWithFormat:@"%@/%@", [Env instance].serverURL, url];
		NSDictionary *photo = [[NSDictionary alloc] initWithObjectsAndKeys: fullURL, @"turl",
							   [NSNumber numberWithFloat: fullImage.size.height], @"height",
							   [NSNumber numberWithFloat: fullImage.size.width], @"width",
							   @"camera.jpg", @"caption",
							   [NSNumber numberWithInt: 0], @"rotation",
							   pid, @"id",
							   nil];
		NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
		[self.datasource.activeGallery.filemap setValue: fullURL forKey: pid];
		[photoMap setValue: photo forKey: pid];
	}	
	[ret release];
	[url release];
	[req release];
	
	if (pid == nil) {
		return;
	}
	NSString	*imagePathThumb  = [[datasource thumbImageNames] valueForKey: pid];
	UIGraphicsBeginImageContext(CGSizeMake(thumbW, thumbH));  
    [image drawInRect:CGRectMake(0, 0, thumbW, thumbH)];  
	UIImage *thumnailImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	NSString *path = [URLLoader toResourePath: imagePathThumb];
	[UIImageJPEGRepresentation(thumnailImage, 0.6f) writeToFile: path atomically:NO];
	
	NSString	*imagePathScreen = [[datasource screenImageNames] valueForKey:pid];
	UIGraphicsBeginImageContext(CGSizeMake(screenW, screenH));  
    [image drawInRect:CGRectMake(0, 0, screenW, screenH)];  
	UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();  
	NSData *imageData = UIImageJPEGRepresentation(screenImage, 0.6f);
	path = [URLLoader toResourePath: imagePathScreen];
	[imageData writeToFile:path atomically:NO];
	
	NSString	*imagePathFull = [[datasource fullImageNames] valueForKey:pid];
	path = [URLLoader toResourePath: imagePathFull];
	[UIImageJPEGRepresentation(fullImage, 0.6f) writeToFile:path atomically:NO];

	[picker dismissModalViewControllerAnimated:YES];
	
	// find where selected begin
	NSUInteger i;	
	ThumbnailImageView *view;
	for (i=currentNumber; i>0; i--) 
	{
		view = [self viewHavingPositionIndex:i]; 
		if (view.pageNumber > 0)
			break;
		if(!view.pageBreak)
		{
			view.positionIndex ++;
		}
	}
	
	UIImageView *imageView	= [[UIImageView alloc] initWithImage:thumnailImage];		// place image in an imageView	
	[self setUpImageView:imageView forPageNum:-2  imageName:imageName			// -2 will convert to -1("unselected")
		  imageNameIndex:[pid intValue]
		  imagePageIndex:2
	 andImageScreenIndex:i+2];
	
	[imageView release];					
	
	[self setContentSize:CGSizeMake([self bounds].size.width, ((currentNumber+1)/4 +2)* kImageHeight)];
	datasource.numberOfImages   = currentNumber;
	[self updateCurPagination];												// keep curPagination up-to-date: used by BRIC
	if (currentMode == normalMode)
		[self updateLayoutAnimated];
	
//	UIImageWriteToSavedPhotosAlbum(thumnailImage, self, nil, nil); 
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) handleDoubleTap:(UITouch *)touch
{
	//  < put up an action sheet with choices: add photo, delete whole page, add page, add text to page >
	// for now just "add page"
	ThumbnailImageView  *tappedView = (ThumbnailImageView *)touch.view;
	
	if (tappedView.pageNumber == -1  && tappedView.pageBreak)					// only unselected , but not gray "X"
		return;	
	if (self.currentMode == compressedMode)	{									// no new page while in compressedMode
		NSLog(@"In handleDoubleTap.  But exiting because in compressedMode");
		return;
	}
			
	NSLog(@"In handleDoubleTap.  Calling makeNewPageFrom:");
	[self makeNewPageFrom:tappedView];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)handleLeftSwipe
{
	NSLog(@"In handleLeftSwipe.");
	
	self.currentMode = compressedMode;
	
	NSArray *subviews = [self subviews];
	for (ThumbnailImageView *view in subviews)
		if ([view isKindOfClass:[ThumbnailImageView class]]) 
			[view highlightTargetUndo];
	
	[self compressView];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)handleRightSwipe
{
	NSLog(@"In handleRightSwipe.");
	
	self.currentMode = normalMode;	
	
	NSArray *subviews = [self subviews];
	for (ThumbnailImageView *view in subviews)
		if ([view isKindOfClass:[ThumbnailImageView class]]) 
			[view highlightTargetUndo];
	
	[self uncompressView];																	// KC, 29apr09
}
//----------------------------------------------------------------------------------------------------------------------//
- (ThumbnailImageView *)viewHavingPositionIndex:(NSUInteger)position 
{	
	for (UIView *thumb in [self subviews])		
		if ([thumb isKindOfClass:[ThumbnailImageView class]]  &&  [(ThumbnailImageView *)thumb positionIndex] == position) 
			return (ThumbnailImageView *)thumb;
	
	return nil;
}
//----------------------------------------------------------------------------------------------------------------------//
- (ThumbnailImageView *)viewHavingPhotoID:(NSUInteger)photoID 
{	
	for (UIView *thumb in [self subviews])		
		if ([thumb isKindOfClass:[ThumbnailImageView class]]  &&  [(ThumbnailImageView *)thumb photoID] == photoID) 
			return (ThumbnailImageView *)thumb;
	
	return nil;
}
//----------------------------------------------------------------------------------------------------------------------//
- (ThumbnailImageView *)pageheadForPage:(NSInteger)pageNumber									// pageNumber is 1-based
{	
	for (UIView *thumb in [self subviews])		
		if ( [thumb isKindOfClass:[ThumbnailImageView class]]  &&  
			((ThumbnailImageView *)thumb).pageBreak         &&
			[(ThumbnailImageView *)thumb pageNumber ] == pageNumber) 
			return (ThumbnailImageView *)thumb;
	
	return nil;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)updateBadges
{	
	for (UIView *thumb in [self subviews])
		if ( [thumb isKindOfClass:[ThumbnailImageView class]]  &&  ((ThumbnailImageView *)thumb).pageBreak)
			[self addBadgeToView:(ThumbnailImageView *)thumb pageNumber:[(ThumbnailImageView *)thumb pageNumber]];				
		
	return;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) infoAboutImagesFrom:(NSUInteger)A to:(NSUInteger)B	   // print info on all images between to and from, for debug
{
	return;													   // preserve this debug method for later (we may need it).
	
	if (A < B)																						// moving image UP
		for (NSUInteger i=A; i<=B; i++)													
		{
			ThumbnailImageView	*thumb = [self viewHavingPositionIndex:i];
			NSLog(@"(A < B   posIndex=%02d  page=%02d  isPageBreak=%d", thumb.positionIndex, thumb.pageNumber, 
																									thumb.pageBreak);
		}
	else if (A > B)																					// moving image DOWN
		for (NSUInteger i=B; i<=A; i++)						
		{
			ThumbnailImageView	*thumb = [self viewHavingPositionIndex:i];
			NSLog(@"(A > B   posIndex=%02d  page=%02d  isPageBreak=%d", thumb.positionIndex, thumb.pageNumber, 
																									thumb.pageBreak);
		}
}
//----------------------------------------------------------------------------------------------------------------------//
- (iphotobookThumbnailAppDelegate *)appDelegate		
{
	return (iphotobookThumbnailAppDelegate *)[[UIApplication sharedApplication] delegate];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (UINavigationController *)navController		
{
	return (UINavigationController *)[self appDelegate].navigationController;	
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark touch events
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)touchesShouldCancelInContentView:(UIView *)view 
{
	return NO;
}
//----------------------------------------------------------------------------------------------------------------------//
@end
