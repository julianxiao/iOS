//
//  iphotobookThumbnailViewController.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "iphotobookThumbnailViewController.h"
#import "ThumbnailScrollView.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation iphotobookThumbnailViewController

@synthesize thumbnailScrollView;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (void)viewWillAppear:(BOOL)animated								
{
	// Update the view with current data before it is displayed
	[super viewWillAppear:animated];
	
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = thumbnailScrollView;
	accelerometer.updateInterval = 1.0f/6.0f;

}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;									// was (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)didReceiveMemoryWarning {
	NSLog(@"In iphotobookThumbnailViewController.didReceiveMemoryWarning.  currently doing nothing");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.thumbnailScrollView = nil;

    [super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark UINavigationControllerDelegate methods
//----------------------------------------------------------------------------------------------------------------------//
 - (void)navigationController:(UINavigationController *)navigationController 
									willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSLog(@"in willShowViewController.");
	if ([viewController isEqual:self]) {
		NSLog(@"in willShowViewController.  and inside conditional, so turning hidden off.");
		self.thumbnailScrollView.hidden = NO;		
	}
}
//----------------------------------------------------------------------------------------------------------------------//
@end
