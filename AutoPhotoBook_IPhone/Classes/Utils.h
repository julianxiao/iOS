//
//  Utils.h
//  iphotobookThumbnail
//
//  Created by Song on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {

}

+ (NSString *) md5: (NSString *) data;
+(CGImageRef)scaleCGImage: (CGImageRef) image withPrefix: (CGSize) size;

@end
