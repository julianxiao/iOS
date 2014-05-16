//
//  SingleImageCropViewController.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 4/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SingleImageCropViewController.h"
#import "ThumbsDataSource.h"
#import "URLLoader.h"
#import "SingleImageGetQueue.h"
#import "GetAutoCropQueue.h"
#import "SelectorInvokeQueue.h"
#import "DataLoaderQueue.h"
#import "JSON.h"
#import "Env.h"
#import "TapDetectingImageView.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@interface SingleImageCropViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation SingleImageCropViewController

@synthesize imageCanvas, imageScrollView, thumbsDataSource, imageNum, pageNum, imageScale, imageView;

- (void) onThumbResult{
	self.imageView = [[[TapDetectingImageView alloc] initWithImage:imageCanvas.image] autorelease];
    
	self.imageScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 420)] autorelease];
    [self.imageScrollView setBackgroundColor:[UIColor blackColor]];
    [self.imageScrollView setDelegate:self];
    [self.imageScrollView setBouncesZoom:YES];
	self.imageScrollView.alwaysBounceVertical = YES;
	self.imageScrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:self.imageScrollView];
	self.imageView.contentMode = UIViewContentModeCenter;
    [self.imageView setDelegate:self];
    [self.imageView setTag:ZOOM_VIEW_TAG];
    [self.imageScrollView setContentSize:self.imageView.frame.size];
    [self.imageScrollView addSubview:self.imageView];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = 320  / self.imageView.frame.size.width;
    [self.imageScrollView setMinimumZoomScale:minimumScale];
	[self.imageScrollView setMaximumZoomScale:(2 > minimumScale ? 2 : minimumScale)];
    [self.imageScrollView setZoomScale:minimumScale];
	[self resetImage: self.imageView inScrollView: imageScrollView];
}

- (void) onResult{
	UIImage	*image = imageCanvas.image;
	NSString *url = [[thumbsDataSource autocropResultsNames] valueForKey: [NSString stringWithFormat:@"%d", imageNum]];
	NSData *data = [URLLoader resourceFor: url];
	NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	SBJSON *json = [[SBJSON alloc] init];
	NSDictionary *dic = [json objectWithString: ret error: nil];
	[json release];
	[ret release];
	
	NSString *sx = [dic valueForKey: @"startX"];
	float fx = [sx floatValue];
	NSString *sy = [dic valueForKey: @"startY"];
	float fy = [sy floatValue];
	NSString *sw = [dic valueForKey: @"width"];
	float fw = [sw floatValue];
	NSString *sh = [dic valueForKey: @"height"];
	float fh = [sh floatValue];
	
	int px = fx * image.size.width;
	int py = fy * image.size.height;
	int pw = fw * image.size.width;
	int ph = fh * image.size.height;
	
	CGContextRef    context = NULL;  
	void *          bitmapData;  
	int             bitmapByteCount;  
	int             bitmapBytesPerRow;  
	
	int width = image.size.width;  
	int height = image.size.height;
	
	bitmapBytesPerRow   = (width * 4);  
	bitmapByteCount     = (bitmapBytesPerRow * height);  
	
	bitmapData = malloc( bitmapByteCount );  
	if (bitmapData == NULL)  
	{
		NSLog(@"unable to alloc memory for bitmapData");
		return;  
	}  
	memset(bitmapData, 0, bitmapByteCount);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();  
	context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,  
									 colorspace,kCGImageAlphaPremultipliedFirst); 
	CGColorSpaceRelease(colorspace);  
	
	if (context == NULL){
		NSLog(@"unable to create context");
		return;
	}
	
	//CGContextSetRGBFillColor (context, 1, 1, 1, 1);
    //CGContextFillRect (context, CGRectMake(0, 0, width, height));
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
	for (int i = 0; i < bitmapByteCount; i++) {
		int b = *((Byte *)bitmapData + i);
		*((Byte *)bitmapData + i) = b / 3;
	}
	
	CGImageRef resizedImage = CGImageCreateWithImageInRect([image CGImage], CGRectMake(px, py, pw, ph));
	CGContextDrawImage(context, CGRectMake(px, height - ph - py, pw, ph), resizedImage);
	CGImageRelease(resizedImage);
	CGImageRef finalImageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	free(bitmapData);
	
	UIImage *newImage = [[UIImage alloc] initWithCGImage: finalImageRef];
	CGImageRelease(finalImageRef);
	
	[self.imageView removeFromSuperview];
	self.imageView = [[[TapDetectingImageView alloc] initWithImage:newImage] autorelease];
	[newImage release];
	
	[self.imageScrollView removeFromSuperview];
	self.imageScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 420)] autorelease];
    [self.imageScrollView setBackgroundColor:[UIColor blackColor]];
    [self.imageScrollView setDelegate:self];
    [self.imageScrollView setBouncesZoom:YES];
	self.imageScrollView.alwaysBounceVertical = YES;
	self.imageScrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:self.imageScrollView];
	self.imageView.contentMode = UIViewContentModeCenter;
    [self.imageView setDelegate:self];
    [self.imageView setTag:ZOOM_VIEW_TAG];
    [self.imageScrollView setContentSize:self.imageView.frame.size];
    [self.imageScrollView addSubview:self.imageView];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = 320  / self.imageView.frame.size.width;
    [self.imageScrollView setMinimumZoomScale:minimumScale];
	[self.imageScrollView setMaximumZoomScale:(2 > minimumScale ? 2 : minimumScale)];
    [self.imageScrollView setZoomScale:minimumScale];
	[self resetImage: self.imageView inScrollView: imageScrollView];
}

- (void)viewWillAppear:(BOOL)animated								
{
	// Update the view with current data before it is displayed
	[super viewWillAppear:animated];
	
	self.imageCanvas = [[[UIImageView alloc] init] autorelease];
	
	NSString *key = [NSString stringWithFormat:@"%d", imageNum];
	NSString *imageName = [[thumbsDataSource fullImageNames] valueForKey: key];
	NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
	NSDictionary *photo = [photoMap valueForKey: key];
	self.title = [photo valueForKey: @"caption"];
	
	SingleImageGetQueue *queue = [SingleImageGetQueue queue];
	queue.target = imageCanvas;
	queue.url = [[thumbsDataSource thumbImageNames] valueForKey: key];
	[queue runDelegate];
	[queue applyDelegate];
	[queue stopQueue];
	//[[DataLoaderQueue instance] addQueue: queue withCategory: @"single_image_view"];
	
	/*SelectorInvokeQueue *siq = [SelectorInvokeQueue queue];
	siq.target = self;
	siq.selector = @selector(onThumbResult);
	[[DataLoaderQueue instance] addQueue: siq withCategory: @"single_image_view"];*/
	[self onThumbResult];
	
	queue = [SingleImageGetQueue queue];
	queue.target = imageCanvas;
	queue.url = imageName;
	[[DataLoaderQueue instance] addQueue: queue withCategory: @"single_image_view"];
	
	
	NSString	*url  = [[thumbsDataSource autocropResultsNames] valueForKey: [NSString stringWithFormat:@"%d", imageNum]];
	GetAutoCropQueue *gaq = [GetAutoCropQueue queue];
	gaq.autocropURL = url;
	[[DataLoaderQueue instance] addQueue: gaq withCategory: @"single_image_view"];
	
	SelectorInvokeQueue *siq = [SelectorInvokeQueue queue];
	siq.target = self;
	siq.selector = @selector(onResult);
	[[DataLoaderQueue instance] addQueue: siq withCategory: @"single_image_view"];
}

- (void) resetImage: (UIView *)image inScrollView: (UIScrollView *)scrollView{
	CGRect innerFrame = image.frame;
	CGRect scrollerBounds = scrollView.bounds;
	
	if ( ( innerFrame.size.width < scrollerBounds.size.width ) || ( innerFrame.size.height < scrollerBounds.size.height ) )
	{
		CGFloat tempx = image.center.x - ( scrollerBounds.size.width / 2 );
		CGFloat tempy = image.center.y - ( scrollerBounds.size.height / 2 );
		CGPoint myScrollViewOffset = CGPointMake( tempx, tempy);
		scrollView.contentOffset = myScrollViewOffset;
	}
	
	UIEdgeInsets anEdgeInset = { 0, 0, 0, 0};
	if ( scrollerBounds.size.width > innerFrame.size.width )
	{
		anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
		anEdgeInset.right = -anEdgeInset.left;  // I don't know why this needs to be negative, but that's what works
	}
	if ( scrollerBounds.size.height > innerFrame.size.height )
	{
		anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
		anEdgeInset.bottom = -anEdgeInset.top;  // I don't know why this needs to be negative, but that's what works
	}
	scrollView.contentInset = anEdgeInset;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)uiview atScale:(float)scale {
	[self resetImage: uiview inScrollView: scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // single tap does nothing for now
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)viewDidDisappear:(BOOL)animated{
	self.imageCanvas.image = nil;
	[self.imageView removeFromSuperview];
	self.imageView = nil;
	[self.imageScrollView removeFromSuperview];
	self.imageScrollView = nil;
	[super viewDidDisappear: animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	self.imageCanvas = nil;
	self.imageScrollView = nil;
	self.thumbsDataSource = nil;
	[cropCanvas release];
    [super dealloc];
}


@end
