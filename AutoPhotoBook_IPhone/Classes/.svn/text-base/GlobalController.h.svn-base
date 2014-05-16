//
//  GlobalController.h
//  OnlinePhotoSlideShow
//
//  Created by Song on 09-11-4.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iphotobookThumbnailAppDelegate;

@interface GlobalController : NSObject {
    iphotobookThumbnailAppDelegate *appDelegate;
    int busyCount;
    int totalBusy;
}

+(GlobalController *) instance;

- (void) addBusy;
- (void) removeBusy;
- (void) updateDownloadProgress: (int) percentage;
- (void) resetTotalBusy;
- (void) doLogin:(NSString *) acid withPassword: (NSString *) pwd;

@property (nonatomic, retain) iphotobookThumbnailAppDelegate *appDelegate;
@end
