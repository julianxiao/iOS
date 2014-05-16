//
//  PaginationParser.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/23/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Pagination;

//----------------------------------------------------------------------------------------------------------------------//
@interface PaginationParser : NSObject {
	NSString		*fileToParse;														// cluster analysis from server
	NSUInteger		numberOfImages;														// 
	NSMutableArray	*paginations;														// array of pagination
	NSArray			*suggestedCoverChoices;												// MUTABLE? array of imageNum
	NSUInteger		suggestedPaginationChoice;											// index to paginations
}

@property (nonatomic, retain)  NSString			*fileToParse;	
@property (nonatomic, assign)  NSUInteger		numberOfImages;	
@property (nonatomic, retain)  NSMutableArray	*paginations;	
@property (nonatomic, retain)  NSArray			*suggestedCoverChoices;
@property (nonatomic, assign)  NSUInteger		suggestedPaginationChoice;	

- (id)					init;	
- (void)				initializeWithFile:	   (NSString *)	  file;														
- (NSMutableArray *)	parsePaginationFile:   (NSString *)   filepath;
- (Pagination     *)	parseSingleLine:	   (NSString *)	  line		   lineNum:			    (NSInteger)lineNum;	
- (NSMutableArray *)	unselectedImages:	   (Pagination *) pagination   inPaginagtionsArray: (NSArray *)paginationArray;
- (void)				printPaginations;												// debug

//- (NSUInteger)			numberOfImages;													// custom getter

//----------------------------------------------------------------------------------------------------------------------//
@end
