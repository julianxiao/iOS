//
//  GalleriesViewController.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 04/17/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "GalleriesViewController.h"
#import "Gallery.h"
#import "iphotobookThumbnailAppDelegate.h"
#import "iphotobookThumbnailViewController.h"
#import "ThumbnailScrollView.h"
#import "ThumbsDataSource.h"
#import "Env.h"
#import "URLLoader.h"
#import "JSON.h"
#import "ThumbnailGetQueue.h"
#import "DataLoaderQueue.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation GalleriesViewController

@synthesize indexOfCurrentGallery;
@synthesize galleries;
@synthesize thumbnailViewController;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (void)viewDidLoad {
    [super viewDidLoad];

	self.indexOfCurrentGallery = 0;
	self.title = @"Photo Albums";	
	
	/*UIBarButtonItem *importButton = [[UIBarButtonItem alloc]
									 initWithTitle:@"Import" style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(handleImportButton)];
	self.navigationItem.rightBarButtonItem = importButton;
	[importButton release];*/
	
	self.tableView.rowHeight = 100;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) handleImportButton
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:nil
						  message:@"To import photos, please purchase AutoPhotobook Premium!" 
						  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show	  ];
	[alert release];
	
	
//	NSString *stringUrl = @"http://192.168.1.100:8080";
//	NSString *output;
//	
//	NSURL *url = [NSURL URLWithString:stringUrl];
//	NSMutableURLRequest *urlRequest = [NSMutableURLRequest
//									   requestWithURL:url];
//	
//    if (!urlRequest){
//		output = @"Sorry, we can't create a tinyURL because there was an error in the URL";
//		NSLog(output);
//		return;
//	}
//	
//	NSError *error;
//	NSURLResponse *response;
//	NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
//	
//    if (!result){
//		output= @"Sorry, there was a tinyURL server error.";
//		NSLog(output);
//		return;
//	}
//    
//	output = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
//	NSLog(output);
	
}

//----------------------------------------------------------------------------------------------------------------------//
- (NSArray *)getFilelistForNumphotosFromBundle:(NSUInteger)numPhotos
{
	NSError   *error;
	
	NSString  *filename		= [NSString stringWithFormat:@"fullFilelist%d", numPhotos];					// our convention
	NSString  *srceFilepath = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];	
	NSString  *fileAsString = [NSString stringWithContentsOfFile:srceFilepath encoding:NSUTF8StringEncoding error:&error];
	NSArray   *theBasenames	= [fileAsString componentsSeparatedByString:@"\n"];		
	
	return [theBasenames retain];																		
}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;						// was (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)didReceiveMemoryWarning {
	NSLog(@"In GalleriesViewController.didReceiveMemoryWarning.  Currently doing nothing");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	[galleries				 release];
	[thumbnailViewController release]; 
	 
    [super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark Table view methods
//----------------------------------------------------------------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return self.galleries.count;
}
//----------------------------------------------------------------------------------------------------------------------//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.imageView.image = [UIImage imageNamed: @"bigalbum.png"];
	}
    
	Gallery  *aGallery = [self.galleries objectAtIndex:indexPath.row];
	cell.textLabel.text = aGallery.title;
	ThumbnailGetQueue *queue = [ThumbnailGetQueue queue];
	queue.target = cell.imageView;
	queue.url = [NSString stringWithFormat:@"%@&width=82&height=57", aGallery.icon];
	[[DataLoaderQueue instance] addQueue: queue withCategory: @"album_icons_get"];

    return cell;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[self handleCellTap:indexPath];												// does the "push"
	
	NSLog(@"In didSelectRowAtIndexPath.  Responding to cellTap.  \nactiveCollectionNum = %d  \nactiveFilelist      = \n%@\n\n", 
		  self.thumbnailViewController.thumbnailScrollView.datasource.activeCollectionNum,
		  self.thumbnailViewController.thumbnailScrollView.datasource.activeFilelist);
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark action methods
//----------------------------------------------------------------------------------------------------------------------//
- (IBAction)handleCellTap:(id)sender
{
	NSIndexPath *index			= (NSIndexPath *)sender;
	NSUInteger  row				= index.row;
	self.indexOfCurrentGallery	= row;											// index of tablecell tapped
	
	// make Collection1 or Collection2 reign
	Gallery  *gallery = [self.galleries objectAtIndex:row];	
	
// Next line is redundant when thumbnailVC is being created for the first time, since 'initializeThumbnailController' (?)
//	   has already set the datasource.activeFilelist, but on subsequent excursions thru this method, it is essential.
	//[self.thumbnailViewController initWithNibName: @"iphotobookThumbnailViewController" bundle: nil];
	[self.thumbnailViewController.thumbnailScrollView initThumbnailView: gallery];
	self.thumbnailViewController.thumbnailScrollView.datasource.activeCollectionNum = row;
	self.thumbnailViewController.thumbnailScrollView.datasource.activeFilelist		= gallery.filemap;		// key to all
	
	UINavigationController *navcon = [self navController];
	[navcon pushViewController:self.thumbnailViewController animated:YES];		// display thumbs page	
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark handle edit buttons (for later activation, add & delete galleries)
//----------------------------------------------------------------------------------------------------------------------//
- (void)setEditing:(BOOL)edit animated:(BOOL)amimate
{
	NSLog(@"In setEditing:animated:");
	
	[super setEditing:edit animated:amimate];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)rootEditAction:(id)sender												// not used yet, but should be later
{
	NSLog(@"In rootEditAction:");
	
	// This code should be activated and completed after the demo.  Code from Kins, commented out by Kins.
	
	[self setEditing:YES animated:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(rootDoneAction:)];	
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	UIBarButtonItem *addButton  = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(rootAddAction:)];	
	self.navigationItem.leftBarButtonItem = addButton;
	[addButton release];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)rootDoneAction:(id)sender
{
	NSLog(@"In rootDoneAction:");
	[self setEditing:NO animated:YES];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(rootEditAction:)];	
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	
	self.navigationItem.leftBarButtonItem = nil;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)rootAddAction:(id)sender
{
	NSLog(@"In rootAddAction:");
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark utility methods
//----------------------------------------------------------------------------------------------------------------------//
- (iphotobookThumbnailAppDelegate *)appDelegate		
{
	return (iphotobookThumbnailAppDelegate *)[[UIApplication sharedApplication] delegate];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (UINavigationController *)navController		
{
	iphotobookThumbnailAppDelegate *delegate = [self appDelegate];	
	return delegate.navigationController;	
}
//----------------------------------------------------------------------------------------------------------------------//
@end

