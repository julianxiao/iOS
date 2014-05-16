//
//  BookLayoutViewController.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 03/31/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "BookLayoutViewController.h"
#import "iphotobookThumbnailAppDelegate.h"
#import "LayoutScrollView.h"
#import "PageLayoutData.h"
#import "PageView.h"
#import "ThumbsDataSource.h"
#import "Pagination.h"
#import "Env.h"
#import "Utils.h"
#import "BuildPDFQueue.h"
#import "DataLoaderQueue.h"

#import "PhotoStripView.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation BookLayoutViewController

@synthesize layoutScrollView;											// single UIView that is shared by each pageView
//@synthesize pageViews;													// array of UIViews, each representing one page
@synthesize currentPageNum;
@synthesize thumbsDataSource;
@synthesize activityIndicator;
@synthesize returnString, request;


#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (void)viewWillAppear:(BOOL)animated								
{
	// Update the view with current data before it is displayed
	[super viewWillAppear:animated];
	
	[layoutScrollView setupPhotoStrip:self];
	if(layoutScrollView.pageView.superview != nil){
		[layoutScrollView.pageView removeFromSuperview];
	}
	layoutScrollView.pageView = [[[PageView alloc] initWithViewController:self] autorelease];
	
	UIBarButtonItem *layoutButton = [[UIBarButtonItem alloc]
									 initWithTitle:@"Done" style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(handleDoneButton)];
	
	UINavigationItem *item = [self navigationItem];	
	[item setRightBarButtonItem:layoutButton];
	[layoutButton release];
	[layoutScrollView.pageView layOutPage];	
	[layoutScrollView addSubview:layoutScrollView.pageView];
	NSString *title = [NSString stringWithFormat:@"Page %d/%d", currentPageNum+1, thumbsDataSource.currentPagination.pages.count];
	self.title			  = title;
	
}


- (void) handleDoneButton
{
	UIActionSheet * actionSheet = [[UIActionSheet alloc] 
								   initWithTitle:nil
					delegate:self cancelButtonTitle:@"Cancel"
	//				destructiveButtonTitle:@"Save" otherButtonTitles:@"Build PDF", nil];
					destructiveButtonTitle:@"Save as PDF" otherButtonTitles: nil]; //@"Print", @"Share",
	[actionSheet showInView:self.view];
	[actionSheet release];
	
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(buttonIndex == [actionSheet cancelButtonIndex]){
		return;
	}
	switch (buttonIndex) {
		//case 1:
		case 0:	
		{
			NSString *str = [self.layoutScrollView.pageView buildLayout];
			BuildPDFQueue *queue = [BuildPDFQueue queue];
			queue.json = str;
			[[DataLoaderQueue instance] addQueue: queue withCategory: @"buildpdf"];
		}
			break;
		default:
		{
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:nil
								  message:@"This feature is for AutoPhotobook Premium only!" 
								  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			[alert show	  ];
			[alert release];
			break;
		};
	}
	/*if(buttonIndex!= [actionSheet cancelButtonIndex])
	{
		
		NSString *urlString = @"http://192.168.1.100:8080/mbpp";
		
		// setting up the request object now
		self.request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:urlString]];
		[self.request setHTTPMethod:@"POST"];
		
		NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
		[self.request addValue:contentType forHTTPHeaderField: @"Content-Type"];

		NSMutableData *body = [NSMutableData data];
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];		
		[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"command\"  \r\n\r\niphonepdf"] dataUsingEncoding:NSUTF8StringEncoding]];	
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		NSString  *filePath = [NSString stringWithFormat:@"%@", thumbsDataSource.autocropResultsPath];		 
		NSRange textRange;
		textRange =[filePath rangeOfString:@"Sample 1"];
		if(textRange.location != NSNotFound)
		{
			[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"cname\"  \r\n\r\nSample 1"] dataUsingEncoding:NSUTF8StringEncoding]];			
		}
		else
		{
			[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"cname\"  \r\n\r\nSample 2"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];		
		[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"username\"  \r\n\r\nJun"] dataUsingEncoding:NSUTF8StringEncoding]];

		
//		NSString  *filePath = [NSString stringWithFormat:@"%@", thumbsDataSource.autocropResultsPath];		 				
		NSString	*variableName = [NSString stringWithString:@"autocropfile"];
		NSString	*fileName = [NSString stringWithString:@"autocrop.txt"];
		NSFileManager *fileManager	= [NSFileManager defaultManager];		
		if ([fileManager fileExistsAtPath:filePath]) {
			NSLog(@"send file: %@, %@\n", fileName, filePath);
			[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];		
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", variableName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithString:@"Content-Type: text/plain\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			NSData *stateData = [NSData dataWithContentsOfFile:filePath];
			[body appendData:[NSData dataWithData:stateData]];
		}

		
		NSInteger i = 0;
		NSInteger n =  thumbsDataSource.currentPagination.pages.count;
		for (i = 0; i < n; i++)
		{
			NSString  *filePath = [NSString stringWithFormat:@"%@/BRICoutputPage%d", thumbsDataSource.BRICinputFilesDirectoryPath, i];		 				
			NSString	*variableName = [NSString stringWithFormat:@"statefile%.2d", i];
			NSString	*fileName = [NSString stringWithFormat:@"BRICoutputPage%d", i];
			
			if ([fileManager fileExistsAtPath:filePath]) {
				NSLog(@"send file: %@, %@\n", fileName, filePath);
				[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];		
				[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", variableName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[[NSString stringWithString:@"Content-Type: text/plain\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				NSData *stateData = [NSData dataWithContentsOfFile:filePath];
				[body appendData:[NSData dataWithData:stateData]];
			}
		}
		
		NSArray *allPaths = [thumbsDataSource.screenImageNames allValues];
		n = [allPaths count];
		NSInteger j=0;
		for(i=0; i<n; i++)
		{
			NSString	*imageName		= [allPaths objectAtIndex: i];
			textRange =[imageName rangeOfString:@"capture"];//TODO:
			if(textRange.location != NSNotFound)
			{
				j++;
				NSString	*variableName = [NSString stringWithFormat:@"addedfile%.2d", j];
				NSString	*imagePath		= [thumbsDataSource.screenImagesDirectoryPath stringByAppendingPathComponent:imageName];
				[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];		
				[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", variableName, imageName] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
				[body appendData:[NSData dataWithData:imageData]];
			}
		}
				
		
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

//		NSString *logString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//		NSLog(@"sending request: %@\n", logString);			
		
		UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
		self.activityIndicator = aiv;
		[aiv setCenter:CGPointMake(160.0f, 240.f)];
		[aiv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];		
		iphotobookThumbnailAppDelegate *mydelegate = [[UIApplication sharedApplication]  delegate];
		UIWindow *window = mydelegate.window;
		[window addSubview: aiv];
		[aiv startAnimating];
		[aiv release];

		[self.request setHTTPBody:body];
		
		[NSThread detachNewThreadSelector:@selector(sendToServer) toTarget:self withObject:nil];

	}	*/
}

- (void)sendToServer
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[self backgroundSending];										
	
	[self performSelectorOnMainThread:@selector(sendComplete) withObject:nil waitUntilDone:YES];
	[pool release];	
}

-(void)backgroundSending
{
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *ret = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	self.returnString = ret;
	[ret release];
	//		NSLog(returnString);
}

-(void)sendComplete
{
	[self.activityIndicator stopAnimating];
	[self.activityIndicator removeFromSuperview];
	
	if(self.returnString == nil || [self.returnString isEqualToString:@""])
	{
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:@"Please purchase \n AutoPhotobook premium version!" 
							  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:[NSString stringWithFormat:@"%@", returnString] 
							  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	self.returnString = nil;
	self.request = nil;
}

//----------------------------------------------------------------------------------------------------------------------//
/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */
//----------------------------------------------------------------------------------------------------------------------//
 // Override to allow orientations other than the default portrait orientation.


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval) duration
{
	if ((orientation == UIInterfaceOrientationLandscapeLeft)||(orientation == UIInterfaceOrientationLandscapeRight))
	{
		[[UIApplication sharedApplication]  setStatusBarHidden:YES animated:YES];	
		iphotobookThumbnailAppDelegate *mydelegate = [[UIApplication sharedApplication]  delegate];
		UINavigationController *navcon = mydelegate.navigationController;
		[UIView beginAnimations:@"removebar" context:nil];
		UINavigationBar  *navBar	 = navcon.navigationBar;
		navBar.hidden = YES;		
		[UIView commitAnimations];

//		self.view.transform = CGAffineTransformIdentity;
//		self.view.transform = CGAffineTransformMakeRotation(1.6);
//		self.bounds = CGRectMake(0.0, 0.0, 480, 320);
		
		layoutScrollView.pageView.landscapeView = YES;
		layoutScrollView.frame = CGRectMake(0, 0, 480, 320);
		self.view.frame = CGRectMake(0.0, 0.0, 480, 320);
		layoutScrollView.pageView.frame = CGRectMake(0, 0, 480, 320);
		[layoutScrollView hidePhotoStrip];
	
		[layoutScrollView.pageView updateLayoutAnimated: YES];
	}
	else
	{
		[[UIApplication sharedApplication]  setStatusBarHidden:NO animated:YES];
		iphotobookThumbnailAppDelegate *mydelegate = [[UIApplication sharedApplication]  delegate];
		UINavigationController *navcon = mydelegate.navigationController;
		
		UINavigationBar  *navBar	 = navcon.navigationBar;
		navBar.hidden = NO;		
		
		layoutScrollView.pageView.landscapeView = NO;
		self.view.frame = CGRectMake(0.0, 0, 320, 480);
		// don't know why but rotation screw up the position
		layoutScrollView.frame = CGRectMake(0, -10, 320, 480);
		layoutScrollView.pageView.frame = CGRectMake(0, 0, 320, 480);
		[layoutScrollView.pageView updateLayoutAnimated];	
	}
		
}

 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return YES;
 }
 
//----------------------------------------------------------------------------------------------------------------------//
- (void)didReceiveMemoryWarning {
	NSLog(@"In BookLayoutViewController.didReceiveMemoryWarning.  currently doing nothing");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.layoutScrollView = nil;
	self.thumbsDataSource = nil;
	self.activityIndicator = nil;
	self.returnString = nil;
	self.request = nil;
	
    [super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//
@end

