//
//  AutoCropQueue.h
//  iphotobookThumbnail
//
//  Created by Song on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseQueue.h"

@interface AutoCropQueue : BaseQueue {
	NSString *cropURL;
}

@property (nonatomic, retain) NSString *cropURL;
@end
