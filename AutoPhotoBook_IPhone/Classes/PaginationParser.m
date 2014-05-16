//
//  PaginationParser.m
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/23/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "PaginationParser.h"
#import "Pagination.h"
#import "Page.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation PaginationParser

@synthesize fileToParse;		
@synthesize numberOfImages;	
@synthesize paginations;						// array of Pagination
@synthesize suggestedCoverChoices;				// array of imageNum
@synthesize suggestedPaginationChoice;			

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (id)init {														
	if (self = [super init]) {
		;
	}
	
	return self;
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)initializeWithFile:(NSString *)file {														
	NSLog(@"\nIn PaginationParser.init, input file = %@", file);
	self.fileToParse				= file;													// cluster analysis output
	self.suggestedCoverChoices		= nil;
	self.suggestedPaginationChoice	= -1;	
	
	self.paginations				= [self parsePaginationFile:fileToParse];				// do the parsing now
	NSLog(@"#[self.paginations count]>>>>>>%d",[self.paginations count]);
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
	self.fileToParse = nil;
	self.paginations = nil;
	self.suggestedCoverChoices = nil;
		
	[super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//


#pragma mark do parsing
//----------------------------------------------------------------------------------------------------------------------//
- (NSMutableArray *)parsePaginationFile:(NSString *)filepath {
	/*  GUIDE TO IDENTIFIER MEANINGS
	 NSArray   *paginations			// array of Pagination
	 NSArray   *pagination;			// contains array of Page
	 NSArray   *page;				// contains array of imageNum (imageNum determined by the filename-to-imageNum mapping)
	*/
	
	NSMutableArray	*paginationArray = [NSMutableArray array];
	NSError			*error;	
	BOOL			atEnd   = NO;
	
	NSString  *fileAsString		 = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];		
	if (fileAsString.length == 0){
		NSLog(@"parsePaginationFile:  no file");
		return nil;
	}
	
	NSArray *imageLines = [fileAsString componentsSeparatedByString:@"\n"];
	numberOfImages = 0;
	for (NSString *imageLine in imageLines)
	{
		if ([imageLine isEqualToString:@"#"]) {												
			break;
		}
		numberOfImages ++;
	}
		
	 // skip till first #
	NSString  *paginationsPart   = [fileAsString substringFromIndex:[fileAsString rangeOfString:@"#"].location + 1];
	NSArray   *paginationLines	 = [paginationsPart componentsSeparatedByString:@"\n"];								   
	
	int   lineNum = -1;	
	for (NSString *line in paginationLines) {	
		lineNum++;
		if (lineNum == 0)																	// blank line, so skip it
			continue;
		if (lineNum == 1) {																		
			self.suggestedPaginationChoice = line.intValue;									// optimal NUMBER OF PAGES
			continue;
		}
		if (lineNum == 2)																	// second "#", so skip it
			continue;
		if ([line isEqualToString:@"#"]) {													// third "#", so set flag
			atEnd = YES;
			continue;
		}
		
		if (atEnd) {																		// past the paginations
			if (line.length <= 1) 
				continue;
			line = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
			NSString *line2 = [line substringToIndex:line.length-1];
			//NSString *line2 = [line substringToIndex:line.length-2];						// remove last char (',')
			NSMutableArray   *imageNums = [NSMutableArray arrayWithArray:[line2 componentsSeparatedByString:@","]];						
			self.suggestedCoverChoices = imageNums;
		}
		else {																				// parse the paginations
			[paginationArray addObject:[line retain]];
		}		
	}

	return [paginationArray retain];
}
//----------------------------------------------------------------------------------------------------------------------//
- (Pagination *)parseSingleLine:(NSString *)line lineNum:(NSInteger)lineNum
{	
	Pagination  *pagination = [[Pagination alloc] init];
	pagination.paginationID = lineNum;						
	pagination.pages	    = [NSMutableArray array];			
	pagination.unselected	= [NSMutableArray array];			
	
	NSArray   *pageStrings	= [line componentsSeparatedByString:@"|"];		
	NSInteger  pageIndex=0;
	for (NSString *pageString in pageStrings) {												// do 1 page
		if (pageString.length <= 1)															// skip empty lines or pages
			continue;
		
		Page			 *page		   = [[Page			  alloc] init];
		NSMutableArray   *imagesOfPage = [NSMutableArray arrayWithArray:[pageString componentsSeparatedByString:@","]];
		[imagesOfPage removeLastObject];													// empty results from extra ','
		NSMutableArray   *arr		   = [[NSMutableArray alloc] initWithArray:imagesOfPage];		
		NSMutableArray   *nums		   = [[NSMutableArray alloc] initWithArray:arr];		// KC: why use 3 arrays?
		page.imageNums = nums;
		page.pageNum   = pageIndex++;
		[pagination.pages addObject:page];

		[page  release];
		[arr   release];
		[nums  release];
	}
	
	return [pagination autorelease];
}
//----------------------------------------------------------------------------------------------------------------------//
- (NSMutableArray *)unselectedImages:(Pagination *)pagination inPaginagtionsArray:(NSArray *)paginationArray
{
	NSMutableSet   *pageImages = [NSMutableSet set];								// form union set of given pagination
	
	for (Page *page in pagination.pages)
		[pageImages addObjectsFromArray:page.imageNums];
	
	NSMutableSet   *allImages		= [NSMutableSet set];							// form union set of all pages
	Pagination	   *lastPagination  = paginationArray.lastObject;
	
	for (Page *page in lastPagination.pages)
		[allImages addObjectsFromArray:page.imageNums];
	
	[allImages minusSet:pageImages];												// complement of the instersection
	NSMutableArray *unselectedArray = [NSMutableArray arrayWithArray:[allImages allObjects]]; // NSSet --> NSMutableArray
	
	return unselectedArray;															// retain?
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)printPaginations												// debug, uses descriptions methods of components
{	
	if (self.paginations.count == 0) {
		NSLog(@"self.paginations.count == 0");		
		return;
	}	
		// agglutinate (thru appending) various items for printing
	NSMutableString *stringToPrint	  = [NSMutableString string];

		// print: numImages & paginationChoice & suggestedCoverChoices
	NSString		*totalNumImages   = [NSString stringWithFormat:
										@"\n\nnumber of images          = %d\n",			self.numberOfImages];
	NSString		*paginationChoice = [NSString stringWithFormat:
										@"suggestedPaginationChoice = pagination num %d\n", self.suggestedPaginationChoice];
	NSMutableString *coverChoices	  = [NSMutableString stringWithFormat:
										@"suggestedCoverChoices     = "];
	for (NSString *imageNum in self.suggestedCoverChoices) 
		[coverChoices appendString:[NSString stringWithFormat:@"%d  ", imageNum.intValue]];
	[coverChoices appendString:	@"\n\n"];	

	[stringToPrint appendString:totalNumImages	];
	[stringToPrint appendString:paginationChoice];
	[stringToPrint appendString:coverChoices	];

		// print the paginations
	for (Pagination *pagination in paginations) 
		[stringToPrint appendString:[pagination description]];

	NSLog(@"%@\n", stringToPrint);
}
//----------------------------------------------------------------------------------------------------------------------//
@end
