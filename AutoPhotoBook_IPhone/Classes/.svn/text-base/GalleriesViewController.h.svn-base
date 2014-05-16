//
//  GalleriesViewController.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 04/17/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iphotobookThumbnailViewController;
@class iphotobookThumbnailAppDelegate;

//----------------------------------------------------------------------------------------------------------------------//
@interface GalleriesViewController : UITableViewController {
	NSUInteger							indexOfCurrentGallery;						// set in "handleCellTap"
	NSArray								*galleries;									// array of Gallery
	IBOutlet iphotobookThumbnailViewController	*thumbnailViewController;					// the next page
}

@property (nonatomic, assign)  NSUInteger							indexOfCurrentGallery;
@property (nonatomic, retain)  NSArray								*galleries;
@property (nonatomic, retain)  iphotobookThumbnailViewController	*thumbnailViewController;

#pragma mark init
- (NSArray *)			getFilelistForNumphotosFromBundle:  (NSUInteger)  numPhotos;

#pragma mark action methods
- (IBAction)			handleCellTap:	(id)			sender;

#pragma mark handle edit buttons (for later activation, add & delete galleries)
- (void)				setEditing:		(BOOL)			edit		animated: (BOOL) amimate;
- (void)				rootEditAction:	(id)			sender;
- (void)				rootDoneAction:	(id)			sender;
- (void)				rootAddAction:	(id)			sender;

#pragma mark utility methods
- (iphotobookThumbnailAppDelegate *)  appDelegate;	
- (UINavigationController		  *)  navController;

@end
//----------------------------------------------------------------------------------------------------------------------//
