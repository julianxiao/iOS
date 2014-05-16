//
//  ThumbsDataSource.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/25/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Pagination;
@class PaginationParser;
@class PageLayoutData;
@class ThumbnailImageView;
@class iphotobookThumbnailAppDelegate;
@class ThumbnailScrollView;
@class Gallery;
@class PageView;

//----------------------------------------------------------------------------------------------------------------------//
@interface ThumbsDataSource : NSObject {
	NSUInteger			activeCollectionNum;   // we COULD obtain this directly from rootVC.indexOfCurrentGallery
	Gallery				*activeGallery;		   // we COULD obtain this directly from rootVC.indexOfCurrentGallery
	NSDictionary		*activeFilelist;	   // needs saving, set by GalleryViewController on tap, determines basenames
	
	BOOL				keepPageChangedFalseWhileLoading;						// needs revision, à la Jun
	
	NSMutableArray		*paginations;
	NSArray				*paginationStrings;
	
	PaginationParser	*paginationParser;
	NSUInteger			numberOfImages;											
	NSUInteger			actualPaginationChoice;									
	Pagination			*currentPagination;
	NSString			*documentsDirectoryPath;	
	
	NSString			*clusterResultsPath;
	NSString			*autocropResultsPath;
	
	NSString			*updatedCurPaginationPath;
	NSString			*BRICinputFilesDirectoryPath;	
	NSString			*storageFilePath;									
	
	NSString			*BRICinputParamterGloble;
	NSString			*BRICoutputFileGloble;
	PageView			*pageViewHandle;
	NSInteger			pageNumberHandle;
	NSInteger			methodConstantHandle;		
	UIActivityIndicatorView		*activityIndicator;
}

@property (nonatomic, assign)   NSUInteger			activeCollectionNum;	
@property (nonatomic, retain)	Gallery				*activeGallery;	
@property (nonatomic, retain)	NSDictionary		*activeFilelist;
@property (nonatomic, assign)	BOOL				keepPageChangedFalseWhileLoading;

@property (nonatomic, retain)	NSMutableArray		*paginations;
@property (nonatomic, retain)	NSArray				*paginationStrings;

@property (nonatomic, retain)	PaginationParser	*paginationParser;
@property (nonatomic, assign)   NSUInteger			numberOfImages;	
@property (nonatomic, assign)	NSUInteger			actualPaginationChoice;
@property (nonatomic, retain)	Pagination			*currentPagination;
@property (nonatomic, retain)	NSString			*documentsDirectoryPath;									

@property (nonatomic, retain)	NSString			*clusterResultsPath;	
@property (nonatomic, retain)	NSString			*autocropResultsPath;

@property (nonatomic, retain)	NSString			*updatedCurPaginationPath;	
@property (nonatomic, retain)	NSString			*BRICinputFilesDirectoryPath;	
@property (nonatomic, retain)	NSString			*storageFilePath;									

@property (nonatomic, retain)	NSString			*BRICinputParamterGloble;
@property (nonatomic, retain)	NSString			*BRICoutputFileGloble;
@property (nonatomic, retain) 	PageView			*pageViewHandle;
@property (nonatomic, assign)	NSInteger			pageNumberHandle;
@property (nonatomic, assign)	NSInteger			methodConstantHandle;
@property (nonatomic, retain) 	UIActivityIndicatorView	 *activityIndicator;

#pragma mark init
- (id)				init;
- (BOOL)			initDatasource;
- (void)			resetAllAccessors;
- (void)			updateAlternative;
- (void)			initializeDatasourceForGallery:	(Gallery *)	gallery;

- (NSDictionary	  *)	fullImageNames;
- (NSDictionary	  *)	screenImageNames;
- (NSDictionary	  *)	thumbImageNames;
- (NSDictionary	  *)	autocropResultsNames;	

#pragma mark init images (now done in initializeDatasourceForGallery)
- (void)  initializeDatasourceForGallery:	(Gallery *)	 gallery;
- (BOOL)  copyFilesToDocuments:				(Gallery *)	 gallery;
- (BOOL)  createDirectoryIfNeeded:			(NSString *) path;

#pragma mark maintain currentPagination
- (void)			updateCurrentPagination:		 (NSString *) paginationString;
- (BOOL)			writeUpdatedCurPaginationString: (NSString *) paginationString;
- (Pagination *)	readUpdatedCurrentPaginationString;		

- (void)			addUnselectedImage:				 (NSInteger			  ) fromImageID      toPage:(NSInteger) toPage;
- (void)			movePhotoToUnselected:			 (NSInteger		      ) fromImageID;

#pragma mark BRIC methods
- (void)			writeBRICinputFiles;
- (BOOL)			writeBRICinputStringToDisk:		 (NSInteger)	pageNum;	
- (NSString   *)	prepareBRICinputStringForPage:	 (NSInteger)	pageNum;			
- (PageLayoutData *)getBRICresultsForPage:			 (NSInteger)    pageNum;
- (PageLayoutData *)getBRICresultsAlternativeForPage:(NSInteger)    pageNum;
- (PageLayoutData *)getBRICresultsSwapForPage:		 (NSInteger)	pageNum  image1:	(NSInteger)imageid1 
									   image2:	(NSInteger)imageid2;

- (void)			getBRICresultsForPageInThread:	 (NSInteger)	pageNum  forPage:	(PageView *)pageView 
							   forMethod:	(NSInteger)methodConstant;
#pragma mark storage
- (void)			saveData;																	// NSArchiver
- (void)			loadData;																	// NSArchiver

#pragma mark utility methods
- (iphotobookThumbnailAppDelegate *)	appDelegate;
- (ThumbnailScrollView			  *)	thumbsScrollView;									
- (NSMutableArray				  *)	unselectedImages:(Pagination *)pagination;				// new, 23apr09

@end
//----------------------------------------------------------------------------------------------------------------------//
