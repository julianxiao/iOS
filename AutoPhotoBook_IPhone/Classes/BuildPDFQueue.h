//
//  BuildPDFQueue.h
//  iphotobookThumbnail
//
//  Created by Song on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseQueue.h"

@interface BuildPDFQueue : BaseQueue {
	NSString *pdfURL;
	NSString *json;
}

@property (nonatomic, retain) NSString *pdfURL;
@property (nonatomic, retain) NSString *json;
@end
