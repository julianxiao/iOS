//
//  ThumbsDataSource.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/25/09, rev 28apr09
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "ThumbsDataSource.h"
#import "iphotobookThumbnailAppDelegate.h"

#import "GalleriesViewController.h"
#import "Gallery.h"

#import "iphotobookThumbnailViewController.h"
#import "ThumbnailScrollView.h"
#import "ThumbnailImageView.h"
#import "Page.h"
#import "Pagination.h"
#import "PaginationParser.h"

#import "PageLayoutData.h"								
#import "pbook.h"		
#import "PageView.h"
#import "URLLoader.h"
#import "Utils.h"
#import "Env.h"
#import "JSON.h"
#import "DataLoaderQueue.h"
#import "GlobalController.h"

static NSString  *DATA_FILENAME	 = @"ThumbsDataSource.archive";											// use this later

extern const CGFloat	kImageWidth;
extern const CGFloat	kImageHeight;
extern const CGFloat	kImageGap;

//----------------------------------------------------------------------------------------------------------------------//
@implementation ThumbsDataSource

@synthesize activeCollectionNum;
@synthesize activeGallery;
@synthesize activeFilelist;
@synthesize keepPageChangedFalseWhileLoading;

@synthesize paginations;
@synthesize paginationStrings;

@synthesize paginationParser;
@synthesize numberOfImages;
@synthesize actualPaginationChoice;
@synthesize currentPagination;
@synthesize documentsDirectoryPath;

@synthesize clusterResultsPath;
@synthesize autocropResultsPath;
@synthesize updatedCurPaginationPath;
@synthesize BRICinputFilesDirectoryPath;
@synthesize storageFilePath;

@synthesize BRICinputParamterGloble, BRICoutputFileGloble, pageViewHandle, pageNumberHandle, methodConstantHandle;
@synthesize activityIndicator;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (id)init {	
	self = [super init];
	NSLog(@"\n\n **** In ThumbsDataSource.init ****");
	
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)initDatasource 
{	
	// This method is called AFTER self.activeFilelist & self.activeCollectionNum have been set (by ThumbsViewController)
	NSLog(@"\n\n **** In ThumbsDataSource.initDatasource ****");
		
	[self resetAllAccessors];
	
	UIActivityIndicatorView *uiv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
	self.activityIndicator = uiv;
	[uiv setCenter:CGPointMake(160.0f, 240.f)];
	[uiv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[uiv release];
	
	UIWindow *window = [self appDelegate].window;
	for (UIView *view in [window subviews])
	{
		//		view.alpha = 0.3;
		[view addSubview: self.activityIndicator];
		break;
	}
	
	self.keepPageChangedFalseWhileLoading = YES;							// fixes bug, but needs revision, à la Jun
//	NSLog(@"keepPageChangedFalseWhileLoading set to YES");

	GalleriesViewController	 *rootViewController = [self appDelegate].viewController;	
	NSUInteger currentGalleryNum  = rootViewController.indexOfCurrentGallery;
	Gallery    *galleryTapped	  = [rootViewController.galleries objectAtIndex:currentGalleryNum];
	self.activeGallery = galleryTapped;
	
	[self initializeDatasourceForGallery:self.activeGallery];								// chief load action here
	
	NSLog(@"In initDatasource.  currentPagination = %@", [self.currentPagination description]);	
	
	if (self.currentPagination != nil)	{							
		NSLog(@"In initDatasource.  Parsed zero lines.  currentPagination not nil.");				
		return NO;
	}
	
	PaginationParser  *parser = [[PaginationParser alloc] init];
	self.paginationParser				= parser;
	[parser release];																		// was memleak, KC fixed 06may 
	
	[self.paginationParser initializeWithFile:self.clusterResultsPath];
	self.paginationStrings				= paginationParser.paginations;
	self.numberOfImages					= paginationParser.numberOfImages;
	NSInteger lineNumber				= paginationParser.suggestedPaginationChoice - 1;
	if (lineNumber < 0) {
		lineNumber = 0;
	}
	self.currentPagination				= [self.paginationParser parseSingleLine: [self.paginationStrings 
																			objectAtIndex:lineNumber] lineNum:lineNumber]; 	
	self.currentPagination.unselected	= [self unselectedImages:currentPagination];
	self.actualPaginationChoice			= paginationParser.suggestedPaginationChoice;		// start with parser's choice			
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:self.updatedCurPaginationPath] && [[fm attributesOfItemAtPath: self.updatedCurPaginationPath error: nil] fileSize] > 0) {
		NSLog(@"In initDatasource.  Using old updatedCurPagination from file.");
		
		self.numberOfImages				  = self.activeFilelist.count;			
		self.currentPagination			  = [self readUpdatedCurrentPaginationString];				
		self.currentPagination.unselected = [self unselectedImages:currentPagination];		// new,23apr09		
		NSLog(@"In initDatasource.  Parsed one line only.  currentPagination = %@", [self.currentPagination description]);		
	}
	return YES;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)resetAllAccessors
{
	self.currentPagination = nil;
	self.documentsDirectoryPath = nil;
	self.clusterResultsPath = nil;
	self.autocropResultsPath = nil;
	self.updatedCurPaginationPath = nil;
	self.BRICinputFilesDirectoryPath = nil;
	self.storageFilePath = nil;

	NSArray  *paths				 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];			
	self.documentsDirectoryPath  = documentsDirectory;

	NSString *collectionPath  = [self.documentsDirectoryPath stringByAppendingPathComponent:self.activeGallery.uuid];		
	NSString *resultDirPath	  = [collectionPath stringByAppendingPathComponent:@"result"];

	NSString *resultFilepath  = [resultDirPath	stringByAppendingPathComponent:
								 [@"clusterAnalysis" stringByAppendingPathExtension:@"txt"]];	
	self.clusterResultsPath	  = resultFilepath;								
	
	resultFilepath  = [resultDirPath	stringByAppendingPathComponent:
					   [@"autocrop" stringByAppendingPathExtension:@"txt"]];	
	self.autocropResultsPath	   = resultFilepath;								
	
	NSString *filename		  = [resultDirPath	stringByAppendingPathComponent:
								 [@"updatedCurPagination" stringByAppendingPathExtension:@"txt"]];	
	self.updatedCurPaginationPath  = filename;					
	
	NSString *BRICdirPath		= [collectionPath stringByAppendingPathComponent:@"BRICinputAndOutput"];
	self.BRICinputFilesDirectoryPath = BRICdirPath;					
	
	NSString  *storageDir = [self.documentsDirectoryPath stringByAppendingPathComponent:DATA_FILENAME];		
	self.storageFilePath		  = storageDir;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) updateAlternative
{
	NSInteger lineNumber;
	
	if ([self.paginationStrings count] > 30)
	{
		lineNumber= arc4random() % 15 + 15;
		//number of pages between 15 and 30;
	}
	else
	{
		lineNumber = arc4random() % numberOfImages / 2 + numberOfImages/4;
	}
	NSString *line = [self.paginationStrings objectAtIndex:lineNumber];
	
	NSArray   *lines	= [line componentsSeparatedByString:@"|"];	
	NSMutableArray *pageStrings = [[NSMutableArray alloc] initWithArray:lines];
	[pageStrings removeObjectAtIndex:0];
	NSInteger numberOfPages = [pageStrings count];
	
	//shuffle pages	
	NSInteger pageSeq[numberOfPages];
	int i;
	for (i=0; i< numberOfPages; i++)
	{
		pageSeq[i] = i;
	}
	
	for (i=0; i< numberOfPages; i++)
	{
		int m = arc4random() % numberOfPages;  
		int n = arc4random () % numberOfPages;  
		
		int p1 = pageSeq[m];
		int p2 =  pageSeq[n];
		int temp = p1;
		pageSeq[m] = p2;
		pageSeq[n] = temp;
	}
	
	NSMutableString *newLine = [NSMutableString stringWithString: @""];
	for (i=0; i< numberOfPages; i++)
	{
		[newLine appendString:@"|"];
		NSLog(@"page %d: %@",i, [pageStrings objectAtIndex:i]);
		[newLine appendString:[pageStrings objectAtIndex:pageSeq[i]]];
	}
	
	self.currentPagination	 = [self.paginationParser parseSingleLine: newLine lineNum:lineNumber]; 					
	self.currentPagination.unselected = [self unselectedImages:currentPagination];
	[pageStrings release];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)initializeDatasourceForGallery:(Gallery *)gallery
{	
	if ([self copyFilesToDocuments:gallery])
		NSLog(@"copyFilesToDocuments succeeded for Gallery = %@\n", gallery.title);		
	else 
		NSLog(@"Error.  copyFilesToDocuments failed    for Gallery = %@\n",	gallery.title);		
}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)copyFilesToDocuments:(Gallery *)gallery
{	
	BOOL  rtnVal = YES;
	
	NSString *collectionPath		 = [self.documentsDirectoryPath stringByAppendingPathComponent:gallery.uuid	];
	NSString *resultPath			 = [collectionPath			stringByAppendingPathComponent:@"result"			];	
	NSString *BRICinputAndOutputPath = [collectionPath			stringByAppendingPathComponent:@"BRICinputAndOutput"];	

	// ** Create directories **
	if (![self createDirectoryIfNeeded:collectionPath		 ])   return rtnVal=NO;
	if (![self createDirectoryIfNeeded:resultPath			 ])   return rtnVal=NO;
	if (![self createDirectoryIfNeeded:BRICinputAndOutputPath])   return rtnVal=NO;

	NSString  *path = @"clusterAnalysis";
	NSString  *destFilepath  = [resultPath stringByAppendingPathComponent:[path stringByAppendingPathExtension:@"txt"]];	
	[gallery.pagination writeToFile: destFilepath atomically: YES encoding:NSUTF8StringEncoding error: nil];
	
	return rtnVal=YES;
}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)createDirectoryIfNeeded:(NSString *)path
{
	NSError			*error		 = nil;
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	BOOL			isDirectory  = NO;
	
	if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
		if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
			NSLog(@"\nFailed to create fullImagesDirectory:%@\n error=%@ \n",  path, [error description]);	
			return NO;
		}
	}	
	
	return YES;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.BRICoutputFileGloble = nil;
	self.BRICinputParamterGloble = nil;
	self.activeGallery = nil;
	self.activeFilelist = nil;
	self.paginations = nil;
	self.paginationStrings = nil;
	self.paginationParser = nil;
	self.currentPagination = nil;
	self.documentsDirectoryPath = nil;
	self.clusterResultsPath = nil;
	self.updatedCurPaginationPath = nil;
	self.BRICinputFilesDirectoryPath = nil;
	self.storageFilePath = nil;
	self.BRICinputParamterGloble = nil;
	self.BRICoutputFileGloble = nil;
	self.pageViewHandle = nil;
	[self.activityIndicator removeFromSuperview];
	self.activityIndicator = nil;
	self.autocropResultsPath = nil;
	[super dealloc];
}

- (NSDictionary *)fullImageNames									// okay, 27apr09
{
	Gallery *gallery = self.activeGallery;
	NSDictionary *dic = gallery.filemap;
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity: [dic count]];
	NSArray *allKeys = [dic allKeys];
	for (int i = 0; i < [allKeys count]; i++) {
		NSString *key = [allKeys objectAtIndex: i];
		[ret setValue: [NSString stringWithFormat:@"%@&width=480&height=480", [dic valueForKey: key]] forKey: key];
	}
	return ret;
}

//----------------------------------------------------------------------------------------------------------------------//
- (NSDictionary *)screenImageNames									// okay, 27apr09
{
	Gallery *gallery = self.activeGallery;
	NSDictionary *dic = gallery.filemap;
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity: [dic count]];
	NSArray *allKeys = [dic allKeys];
	for (int i = 0; i < [allKeys count]; i++) {
		NSString *key = [allKeys objectAtIndex: i];
		[ret setValue: [NSString stringWithFormat:@"%@&width=480&height=480", [dic valueForKey: key]] forKey: key];
	}
	return ret;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSDictionary *)thumbImageNames									// okay, 27apr09
{
	Gallery *gallery = self.activeGallery;
	NSDictionary *dic = gallery.filemap;
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity: [dic count]];
	NSArray *allKeys = [dic allKeys];
	for (int i = 0; i < [allKeys count]; i++) {
		NSString *key = [allKeys objectAtIndex: i];
		[ret setValue: [NSString stringWithFormat:@"%@&width=100&height=100", [dic valueForKey: key]] forKey: key];
	}
	
	return ret;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSDictionary *)autocropResultsNames								// okay, 30apr09
{
	Gallery *gallery = self.activeGallery;
	NSDictionary *dic = gallery.filemap;
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity: [dic count]];
	NSArray *allKeys = [dic allKeys];
	for (int i = 0; i < [allKeys count]; i++) {
		NSString *key = [allKeys objectAtIndex: i];
		[ret setValue: [NSString stringWithFormat:@"%@/getBestPartSer.do?pid=%@&picUrl=%@", [Env instance].serverURL, key, [dic valueForKey: key]] forKey: key];
	}
	
	return ret;
}

#pragma mark maintain currentPagination
//----------------------------------------------------------------------------------------------------------------------//
- (void)updateCurrentPagination:(NSString *)paginationString	
{
	if (![self writeUpdatedCurPaginationString:paginationString])							// write it
		return;
	
	Pagination *updated  = [self readUpdatedCurrentPaginationString];						// read it back, it's needed
	self.currentPagination = updated;														// KC: redundant NOT
	
	// BRIC 
	[self writeBRICinputFiles];	
	
//	PageLayoutData *oneLayout = [self getBRICresultsForPage:0];	   // be ready for a transition to LayoutPage-0
//	NSLog(@"oneLayout = %@\n", oneLayout);
//	[oneLayout release];									// getBRICresultsForPage maybe should autorelease, not retain
}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)writeUpdatedCurPaginationString:(NSString *)paginationString				
{
	NSError   *error;
	NSString  *filename		    = self.updatedCurPaginationPath;	
	
	// write paginationString to disk
	if ([paginationString writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
		NSLog(@"Wrote updatedCurPagination to file.");
		return YES;
	}
	else {
		NSLog(@"Failed to write updatedCurPagination to file  Error=%@", [error description]);
		NSLog(@"We should exit right now");
		return NO;
	}	
}
//----------------------------------------------------------------------------------------------------------------------//
- (Pagination *)readUpdatedCurrentPaginationString 										
{	
	NSError   *error;
	NSString  *filename  = self.updatedCurPaginationPath;	
	
	// call parser to parse the paginationString on disk
	NSString		 *stringFromFile = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding 
															  error:&error];
	PaginationParser *parser		 = self.paginationParser;		
	Pagination       *updated		 = [parser parseSingleLine:stringFromFile lineNum:actualPaginationChoice]; 	
	
	NSMutableArray	 *theUnselected  = [self unselectedImages:updated];								// fixed bug, 24apr09	
	updated.unselected = theUnselected;
	
//	NSLog(@"In readUpdatedCurrentPaginationString.  updated.unselected = %@", [updated.unselected description]);	
	
	return updated;											// retain?
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)addUnselectedImage:(NSInteger)fromImageID toPage:(NSInteger)toPage
{
	// commented out to see if it crashes -- hasn't crashed yet (08may09)
//	if ([self thumbsScrollView].currentMode == compressedMode) {
//		NSLog(@"In addUnselectedImage:toPage: exit because in compressedMode");				// KC, 30apr09
//		return;
//	}
	
	ThumbnailScrollView  *thumbsView = [self thumbsScrollView];
	thumbsView.hidden = YES;
	
	ThumbnailImageView   *fromImage  = [thumbsView viewHavingPhotoID:fromImageID];
	NSLog(@"In addUnselectedImage:toPage:.  fromImageID=%d  fromImage.pageNumber=%d  toPage=%d", 
		  fromImageID, fromImage.pageNumber, toPage);
	if (fromImage.pageNumber != -1)
	{
		NSLog(@"error: from image is not unselected\n");
		return;
	}
	
	if (toPage < 0)
		[thumbsView makeNewPageFromUnselectedImage:fromImage];
	
	int  i = 1;
	for (i; i>0; i++)
	{
		ThumbnailImageView *view = [thumbsView viewHavingPositionIndex:i];					// find last image of toPage
		if (view.pageNumber > toPage+1  || view.pageNumber < 0)
			break;
	}	

	int  toPosition = i-1;	
	[thumbsView movePhotoFrom:fromImage to:[thumbsView viewHavingPositionIndex:toPosition]]; // move to there, ie, just beyond	
	
	thumbsView.hidden = NO;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)movePhotoToUnselected:(NSInteger)fromImageID
{
	// commented out to see if things are okay now -- hasn't crashed yet (08may09).
//	if ([self thumbsScrollView].currentMode == compressedMode) 
//	{
//		NSLog(@"In movePhotoToUnselected.  But exit if in compressedMode");				// KC, 30apr09
//		return;
//	}
			
	ThumbnailScrollView  *thumbsView = [self thumbsScrollView];
	thumbsView.hidden = YES;
	
	ThumbnailImageView   *fromImage  = [thumbsView viewHavingPhotoID:fromImageID];
	NSLog(@"In movePhotoToUnselected:.  fromImageID=%d  fromImage.pageNumber=%d",fromImageID, fromImage.pageNumber);			
	
	if (fromImage.pageNumber < 0)														// photo must be in some page
		return;
	
	int  i = fromImage.positionIndex;	
	for (i; i>0; i++) {																	// find beginning of unselecteds
		ThumbnailImageView *view = [thumbsView viewHavingPositionIndex:i];
		if (view.pageNumber <= 0)
			break;
	}
	int originalTo   = i;
	int originalFrom = fromImage.positionIndex;
	NSLog(@"from:%d, to: %d", originalFrom, originalTo);			
	NSLog(@"Before changes");												
	[thumbsView infoAboutImagesFrom:originalFrom to:originalTo+1];			
	
	[thumbsView movePhotoFrom:fromImage to:[thumbsView viewHavingPositionIndex:originalTo]]; // move to there, ie, just beyond
	
	NSLog(@"from:%d, to: %d", originalFrom, originalTo);			
	NSLog(@"After changes");												
	[thumbsView infoAboutImagesFrom:originalFrom to:originalTo+1];			
	
	thumbsView.hidden = NO;
}
//----------------------------------------------------------------------------------------------------------------------//

- (void) updateProgress: (NSNumber *) percentage{
	[[GlobalController instance] updateDownloadProgress: [percentage intValue]];
}

#pragma mark BRIC methods
//----------------------------------------------------------------------------------------------------------------------//
- (void)writeBRICinputFiles
{
	float i = [self.currentPagination.pages count];
	int count = 0;
	for (Page *page in self.currentPagination.pages) {
		BOOL success = [self writeBRICinputStringToDisk:page.pageNum];
		[self performSelectorOnMainThread:@selector(updateProgress:)
													  withObject: [NSNumber numberWithInt:(++count * 100 / i)]
													  waitUntilDone: YES];
		if (!success)
			NSLog(@"In writeBRICinputFiles.  Write of BRIC input string failed");
	}
}
//----------------------------------------------------------------------------------------------------------------------//
- (BOOL)writeBRICinputStringToDisk:(NSInteger)pageNum	
{
	NSError   *error;																				// pageNum is 0-based		
	NSString  *filename = [NSString stringWithFormat:@"%@/BRICinputPage%d.txt", self.BRICinputFilesDirectoryPath, pageNum];		 
	
	// write string to disk
	NSString  *theBRICinputString = [self prepareBRICinputStringForPage:pageNum];
	
	if ([theBRICinputString writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
		return YES;
	}
	else {
		NSLog(@"Failed to write theBRICinputString to file.  string = %@   Error=%@", theBRICinputString, 
			  [error description]);
		NSLog(@"We should exit right now");
		return NO;
	}		
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSString *)prepareBRICinputStringForPage:(NSInteger)pageNum										// pageNum is 0-based
{
	NSMutableString *stringToPrint	= [NSMutableString string];
	Page			*page			= [currentPagination.pages objectAtIndex:pageNum];
	
	//	NSLog(@"Compensating for a bug in BRIC's input, we temporarily reverse width & height, and scale rendering.");	
	NSMutableDictionary *photoMap = [[Env instance].storage valueForKey: @"photoMap"];
	
	for (NSString *imageNum in page.imageNums) 
	{
		NSString *url = [self.autocropResultsNames valueForKey: imageNum];
		NSData *data = [URLLoader resourceFor: url];
		NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		if ([ret rangeOfString: @"{"].length == 0) {
			[ret release];
			data = [URLLoader resourceFor: url withCache: NO];
			ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		}
		SBJSON *json = [[SBJSON alloc] init];
		NSDictionary *dic = [json objectWithString: ret error: nil];
		[json release];
		[ret release];
		
		NSString *sw = [dic valueForKey: @"width"];
		float pw = [sw floatValue];
		if (pw <= 0) {
			pw = 1;
		}
		NSString *sh = [dic valueForKey: @"height"];
		float ph = [sh floatValue];
		if(ph <= 0){
			ph = 1;
		}
		
		float width = [[[photoMap valueForKey: imageNum] valueForKey: @"width"] floatValue];
		float height = [[[photoMap valueForKey: imageNum] valueForKey: @"height"] floatValue];
		NSString *pageString = [NSString stringWithFormat:@"%@;%d;%d;", imageNum, (int)(pw * width), (int)(ph * height)];//(int)(pw * image.size.width), (int)(ph * image.size.height)
		//[image release];
		[stringToPrint appendString:pageString];
	}
	
	return stringToPrint;
}
//----------------------------------------------------------------------------------------------------------------------//
- (PageLayoutData *)getBRICresultsForPage:(NSInteger)pageNum										// pageNum is 0-based
{	
	NSError		  *error;	
	NSFileManager *fileManager	= [NSFileManager defaultManager];
	NSUInteger	  encodingUsed;
	NSString	  *filename1 = [NSString stringWithFormat:@"%@/BRICinputPage%d.txt", self.BRICinputFilesDirectoryPath, 
								pageNum];		 
	// read input string for BRIC from disk
	NSString *BRICinputString = [NSString stringWithContentsOfFile:filename1 usedEncoding:&encodingUsed error:&error];
	if (BRICinputString == nil) {
		NSLog(@"Error reading BRIC input file (%@), error=%@", filename1, error);
		return nil;
	}
	
	// prepare input string for BRIC call
	char inputParamter[255];
	strcpy(inputParamter, [BRICinputString UTF8String]);	
	
	// set up outputfile name for BRIC call
	NSString *BRICoutfileName = [NSString stringWithFormat:@"%@/BRICoutputPage%d", self.BRICinputFilesDirectoryPath, pageNum];
	char outputFile[255];
	strcpy(outputFile, [BRICoutfileName UTF8String]);	
	
	NSString		*BRICoutfileTxtName = [BRICoutfileName stringByAppendingString:@".txt"];
	NSString		*BRICoutputString;
	PageLayoutData	*aPageLayout;
	
	// already have layout?
	if ([fileManager fileExistsAtPath:BRICoutfileTxtName]  && ([self.currentPagination.pages count] > pageNum && !((Page *)[self.currentPagination.pages objectAtIndex:pageNum]).pageChanged)) {
		BRICoutputString  = [NSString stringWithContentsOfFile:BRICoutfileTxtName encoding:NSUTF8StringEncoding error: nil];	
		aPageLayout		  = [[PageLayoutData alloc] initWithBRICinput:BRICinputString 
														BRICoutput:BRICoutputString ourPageID:pageNum];
//		return [aPageLayout retain];		// ••• retain is wrong (I believe)	   
		return [aPageLayout autorelease];					// I believe this is now correct, but I'm still a little uncertain •••		   
	}
	
	printf("-------------- BRIC reports -----------------------------------------------------------------------------------------------------\n");
	_BRIC_newpage(inputParamter, outputFile);														// <-- call BRIC
	printf("---------------------------------------------------------------------------------------------------------------------------------\n\n");
	
	// make PageLayoutData object from BRIC output
	if ([fileManager fileExistsAtPath:BRICoutfileTxtName]) {
		BRICoutputString  = [NSString stringWithContentsOfFile:BRICoutfileTxtName encoding:NSUTF8StringEncoding error: nil];	
		aPageLayout		  = [[PageLayoutData alloc] initWithBRICinput:BRICinputString 
														BRICoutput:BRICoutputString ourPageID:pageNum];
	}
	else 
		NSLog(@"Error.  In getBRICresultsForPage.  outputFile does not exist: %@.", BRICoutfileTxtName);
	
	if ([self.currentPagination.pages count] > pageNum) {
		((Page *)[self.currentPagination.pages objectAtIndex:pageNum]).pageChanged = NO;
	}
	
//	return [aPageLayout retain];		// ••• retain is wrong (I believe)
	return [aPageLayout autorelease];					// I believe this is now correct, but I'm still a little uncertain •••		   
}
//----------------------------------------------------------------------------------------------------------------------//
- (PageLayoutData *)getBRICresultsAlternativeForPage:(NSInteger)pageNum								// pageNum is 0-based
{
	NSFileManager *fileManager	= [NSFileManager defaultManager];	
	
	// set up outputfile name for BRIC call
	NSString *BRICoutfileName = [NSString stringWithFormat:@"%@/BRICoutputPage%d", self.BRICinputFilesDirectoryPath, pageNum];
	char outputFile[255];
	strcpy(outputFile, [BRICoutfileName UTF8String]);	
	
	printf("-------------- BRIC reports -----------------------------------------------------------------------------------------------------\n");
	_BRIC_alternative(outputFile);																	// <-- call BRIC
	printf("---------------------------------------------------------------------------------------------------------------------------------\n\n");
	
	// make PageLayoutData object from BRIC output
	NSString		*BRICoutfileTxtName = [BRICoutfileName stringByAppendingString:@".txt"];
	NSString		*BRICoutputString;
	PageLayoutData	*aPageLayout;
	if ([fileManager fileExistsAtPath:BRICoutfileTxtName]) {
		BRICoutputString  = [NSString stringWithContentsOfFile:BRICoutfileTxtName encoding:NSUTF8StringEncoding error: nil];	
		aPageLayout		  = [[PageLayoutData alloc] initWithBRICinput:nil 
														BRICoutput:BRICoutputString ourPageID:pageNum];
	}
	else 
		NSLog(@"Error. In getBRICresultsAlternativeForPage.  outputFile does not exist: %@.", BRICoutfileTxtName);
	
//	return [aPageLayout retain];		// retain is wrong!	(I believe)   
	return aPageLayout;					// I believe this is now correct, but I'm still a little uncertain ••		   
}
//----------------------------------------------------------------------------------------------------------------------//
- (PageLayoutData *)getBRICresultsSwapForPage:(NSInteger)pageNum image1: (NSInteger)imageid1 image2: (NSInteger)imageid2
{
	NSFileManager *fileManager	= [NSFileManager defaultManager];	
	
	// set up outputfile name for BRIC call
	NSString *BRICoutfileName = [NSString stringWithFormat:@"%@/BRICoutputPage%d", self.BRICinputFilesDirectoryPath, pageNum];
	char outputFile[255];
	strcpy(outputFile, [BRICoutfileName UTF8String]);	
	int id1 = imageid1;
	int id2 = imageid2;
	
	printf("-------------- BRIC reports -----------------------------------------------------------------------------------------------------\n");
	_BRIC_swap(outputFile, id1, id2);																// <-- call BRIC
	printf("---------------------------------------------------------------------------------------------------------------------------------\n\n");
	
	// make PageLayoutData object from BRIC output
	NSString		*BRICoutfileTxtName = [BRICoutfileName stringByAppendingString:@".txt"];
	NSString		*BRICoutputString;
	PageLayoutData	*aPageLayout;
	if ([fileManager fileExistsAtPath:BRICoutfileTxtName]) {
		BRICoutputString  = [NSString stringWithContentsOfFile:BRICoutfileTxtName encoding:NSUTF8StringEncoding error: nil];	
		aPageLayout		  = [[PageLayoutData alloc] initWithBRICinput:nil 
														BRICoutput:BRICoutputString ourPageID:pageNum];
	}
	else 
		NSLog(@"Error. In getBRICresultsSwapForPage.  outputFile does not exist: %@.", BRICoutfileTxtName);
	
//	return [aPageLayout retain];		// retain is wrong!		   
	return aPageLayout;					// I believe this is now correct, but I'm still a little uncertain ••		   
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) BRICThreadNewPage
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	// prepare input string for BRIC call
	char inputParamter[255];
	strcpy(inputParamter, [BRICinputParamterGloble UTF8String]);	
	
	char outputFile[255];
	strcpy(outputFile, [BRICoutputFileGloble UTF8String]);	
		
	printf("-------------- BRIC reports -----------------------------------------------------------------------------------------------------\n");
	_BRIC_newpage(inputParamter, outputFile);														// <-- call BRIC
	printf("---------------BRIC reports ends------------------------------------------------------------------------------------------------------\n\n");	

	[self performSelectorOnMainThread:@selector(BRICThreadNewPageComplete) withObject:nil waitUntilDone:YES];
	self.BRICinputParamterGloble = nil;
	self.BRICoutputFileGloble = nil;
	
	[pool release];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) BRICThreadNewPageComplete
{	
	[self.activityIndicator stopAnimating];
	
	//	[activityIndicator removeFromSuperview];
	NSError		  *error;	
	NSUInteger	  encodingUsed;
	NSString	  *filename1 = [NSString stringWithFormat:@"%@/BRICinputPage%d.txt", self.BRICinputFilesDirectoryPath, 
								pageNumberHandle];		 
	
	NSFileManager *fileManager	= [NSFileManager defaultManager];
	NSString *BRICoutfileName = [NSString stringWithFormat:@"%@/BRICoutputPage%d", self.BRICinputFilesDirectoryPath, 
								 pageNumberHandle];
	NSString *BRICinputString = [NSString stringWithContentsOfFile:filename1 usedEncoding:&encodingUsed error:&error];
	
	NSString		*BRICoutfileTxtName = [BRICoutfileName stringByAppendingString:@".txt"];
	NSString		*BRICoutputString;
	PageLayoutData	*aPageLayout;
	
	// make PageLayoutData object from BRIC output
	if ([fileManager fileExistsAtPath:BRICoutfileTxtName]) {
		BRICoutputString  = [NSString stringWithContentsOfFile:BRICoutfileTxtName encoding:NSUTF8StringEncoding error: nil];	
		aPageLayout		  = [[PageLayoutData alloc] initWithBRICinput:BRICinputString 
														BRICoutput:BRICoutputString ourPageID:pageNumberHandle];
	}
	else 
		NSLog(@"In getBRICresultsForPage.  outputFile does not exist: %@.", BRICoutfileTxtName);
	
	if(methodConstantHandle == 1)
		[pageViewHandle callbacKFromBRICForAdd:aPageLayout];
	
	if(methodConstantHandle == 2)
		[pageViewHandle callbacKFromBRICForRemove:aPageLayout];
	[aPageLayout release];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) getBRICresultsForPageInThread:(NSInteger)pageNum forPage:(PageView *)pageView forMethod:(NSInteger)methodConstant
{
	
	NSError		  *error;	
	NSUInteger	  encodingUsed;
	NSString	  *filename1 = [NSString stringWithFormat:@"%@/BRICinputPage%d.txt", self.BRICinputFilesDirectoryPath, pageNum];		 
	
	// read input string for BRIC from disk
	NSString *BRICinputString = [NSString stringWithContentsOfFile:filename1 usedEncoding:&encodingUsed error:&error];
	if (BRICinputString == nil) {
		NSLog(@"Error reading BRIC input file (%@), error=%@", filename1, error);
		return ;
	}
		
	pageViewHandle = pageView;
	pageNumberHandle = pageNum;
	methodConstantHandle = methodConstant;
	
	[self.activityIndicator startAnimating];
	NSLog(@"start activity indicator\n");
	
	// set up outputfile name for BRIC call	
	NSString *BRICoutfileName = [NSString stringWithFormat:@"%@/BRICoutputPage%d", self.BRICinputFilesDirectoryPath, pageNum];

	self.BRICinputParamterGloble = [NSString stringWithString:BRICinputString];
	self.BRICoutputFileGloble = [NSString stringWithString:BRICoutfileName];	
	
	// ••• KC changed the 4 lines below; replaced with 2 below
//	BRICinputParamterGloble = [NSString stringWithString:BRICinputString];
//	BRICoutputFileGloble = [NSString stringWithString:BRICoutfileName];
//	[BRICinputParamterGloble retain];
//	[BRICoutputFileGloble retain];

	// •••   "stringWithString" (a convenience constructor) makes the returned string autoreleased.   
	// •••   If we specify "self." BRICinputParamterGloble will be retained, but only then. (It is releassed in "dealloc".)
	// ••• KC 08may09.  So, better would be this ("self." and no retain) -->
//	self.BRICinputParamterGloble = [NSString stringWithString:BRICinputString];
//	self.BRICoutputFileGloble    = [NSString stringWithString:BRICoutfileName];	
	
	[NSThread detachNewThreadSelector:@selector(BRICThreadNewPage) toTarget:self withObject:nil];	
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark Storage
//----------------------------------------------------------------------------------------------------------------------//
- (void)saveData																			// not used yet, should be
{
 	NSLog(@"Enter ThumbsDataSource:saveData to disk.");
	[NSKeyedArchiver archiveRootObject:paginations		 toFile:self.storageFilePath];	
	[NSKeyedArchiver archiveRootObject:currentPagination toFile:self.storageFilePath];		
 	NSLog(@"Leave ThumbsDataSource:saveData to disk.");
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)loadData 
{
	NSLog(@"Enter ThumbsDataSource:loadData from disk.");
	paginations		  = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storageFilePath];
	currentPagination = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storageFilePath];
	NSLog(@"Leave ThumbsDataSource:saveData from disk.");
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark utility methods
//----------------------------------------------------------------------------------------------------------------------//
- (iphotobookThumbnailAppDelegate *)appDelegate		
{
	return (iphotobookThumbnailAppDelegate *)[[UIApplication sharedApplication] delegate];	
}
//----------------------------------------------------------------------------------------------------------------------//
- (ThumbnailScrollView *)thumbsScrollView
{
	GalleriesViewController			   *viewController1 = (GalleriesViewController *)[self appDelegate].viewController;
	iphotobookThumbnailViewController  *viewController2 = viewController1.thumbnailViewController;
	return viewController2.thumbnailScrollView;
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSMutableArray *)unselectedImages:(Pagination *)pagination					
{
	NSMutableSet  *allImages  = [NSMutableSet set];								// make set of all image numbers
	NSArray *allKeys = [self.activeGallery.filemap allKeys];
	[allImages addObjectsFromArray: allKeys];
	
	NSMutableSet  *pageImages = [NSMutableSet set];								// form union set of given pagination
	for (Page *page in pagination.pages)
		[pageImages addObjectsFromArray:page.imageNums];
	
	[allImages minusSet:pageImages];											// complement of the intersection
	NSMutableArray *unselectedArray = [NSMutableArray arrayWithArray:[allImages allObjects]]; // NSSet --> NSMutableArray
	
	return unselectedArray;											// retain?
}
//----------------------------------------------------------------------------------------------------------------------//
@end
