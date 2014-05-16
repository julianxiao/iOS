//
//  PageLayoutData.h
//  iphotobookThumbnail
//
//  Created by Kins Collins on 03/31/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Page;

//----------------------------------------------------------------------------------------------------------------------//
@interface PageLayoutData : NSObject {
	NSInteger		ourPageID;
	NSString		*BRICinput;
	NSString		*BRICoutput;
	NSArray			*photoPositions;													// array of PhotoPosition
}

@property (nonatomic, assign)  NSInteger	ourPageID;									// should this be int or NSString?
@property (nonatomic, retain)  NSString		*BRICinput;
@property (nonatomic, retain)  NSString		*BRICoutput;
@property (nonatomic, retain)  NSArray		*photoPositions;
	
- (id)		 initWithBRICinput: (NSString *) input	 BRICoutput: (NSString *) output   ourPageID: (NSInteger) pageID;
- (UIView *) layOutPage;

@end
//----------------------------------------------------------------------------------------------------------------------//
