//
//  SelectorInvokeQueue.h
//  iphotobookThumbnail
//
//  Created by Song on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseQueue.h"

@interface SelectorInvokeQueue : BaseQueue {
	SEL selector;
	SEL runSelector;
	id object;
	BOOL hasParam;
}

@property (nonatomic) BOOL hasParam;
@property (nonatomic) SEL selector;
@property (nonatomic) SEL runSelector;
@property (nonatomic, retain) id object;
@end
