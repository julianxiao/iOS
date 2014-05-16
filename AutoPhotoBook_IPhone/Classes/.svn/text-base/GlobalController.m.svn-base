//
//  GlobalController.m
//  OnlinePhotoSlideShow
//
//  Created by Song on 09-11-4.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GlobalController.h"
#import "iphotobookThumbnailAppDelegate.h"
#import "LoginQueue.h"
#import "DataLoaderQueue.h"

@implementation GlobalController
@synthesize appDelegate;

static     GlobalController *controller;

+(GlobalController *) instance{
    if(controller == nil){
        @synchronized(self){
            if(controller == nil){
                controller = [[GlobalController alloc] init];
            }
        }
    }
    return controller;
}

- (id) init{
    if((self = [super init]) != nil){
        busyCount = 0;
    }
    return self;
}

- (void) refreshBusy{
	if(totalBusy == 1)
	{
		appDelegate.busyLabel.text = [NSString stringWithFormat:@"waiting for response"];
		//appDelegate.busyProgress.hidden = YES;
	}else {
		appDelegate.busyLabel.text = [NSString stringWithFormat:@"processing %d%%", (int)((totalBusy - busyCount) * 100/totalBusy)];
		//appDelegate.busyProgress.hidden = NO;
	}

	/*
	else if(totalBusy < 10){
        appDelegate.busyLabel.text = [NSString stringWithFormat:@"%d%%", totalBusy - busyCount, totalBusy];
    }else if(totalBusy < 100){
        appDelegate.busyLabel.text = [NSString stringWithFormat:@"%02d/%02d", totalBusy - busyCount, totalBusy];
    }else if(totalBusy < 1000){
        appDelegate.busyLabel.text = [NSString stringWithFormat:@"%03d/%03d", totalBusy - busyCount, totalBusy];
    }*/
    appDelegate.busyProgress.progress = (float)(totalBusy - busyCount) / totalBusy;
}

- (void) addBusy{
    busyCount++;
    totalBusy++;
    if(busyCount > 0){
        [appDelegate.busy startAnimating];
    }
    if(busyCount == 1){
        [UIView beginAnimations: @"center" context: nil];
        [UIView beginAnimations: @"alpha" context: nil];
        appDelegate.busyBar.center = CGPointMake(160, 460);
		appDelegate.cover.alpha = 1;
        [UIView commitAnimations];
        [UIView commitAnimations];
    }
    [self refreshBusy];
}

- (void) removeBusy{
    busyCount--;
    if(busyCount <= 0){
        [appDelegate.busy stopAnimating];
    }
    if(busyCount == 0){
        [UIView beginAnimations: @"center" context: nil];
		[UIView beginAnimations: @"alpha" context: nil];
        appDelegate.busyBar.center = CGPointMake(160, 500);
 		appDelegate.cover.alpha = 0;
        [UIView commitAnimations];
		[UIView commitAnimations];
    }
    [self refreshBusy];
}

- (void) updateDownloadProgress: (int) percentage{
	BOOL showPer = (percentage < 100 && percentage > 0);
	if (showPer) {
		if (appDelegate.downloadProgress.alpha == 0) {
			[UIView beginAnimations: @"center" context: nil];
			[UIView beginAnimations: @"alpha" context: nil];
			appDelegate.downloadProgress.alpha = 1;
			//animate
			appDelegate.busyProgress.center = CGPointMake(123, 12);
			appDelegate.busyLabel.center = CGPointMake(260, 12);
			[UIView commitAnimations];
			[UIView commitAnimations];
		}
		//update
		appDelegate.downloadProgress.progress = (float)percentage / 100;
	}else {
		if (appDelegate.downloadProgress.alpha != 0) {
			[UIView beginAnimations: @"center" context: nil];
			[UIView beginAnimations: @"alpha" context: nil];
			appDelegate.downloadProgress.alpha = 0;
			//animate
			appDelegate.busyProgress.center = CGPointMake(123, 20);
			appDelegate.busyLabel.center = CGPointMake(260, 20);
			[UIView commitAnimations];
			[UIView commitAnimations];
		}
	}
}

- (void) resetTotalBusy{
	if (busyCount > 0) {
		return;
	}
    totalBusy = busyCount;
}

- (void) doLogin:(NSString *) acid withPassword: (NSString *) pwd{
	LoginQueue *queue = [LoginQueue queue];
	queue.username = acid;
	queue.password = pwd;
	[[DataLoaderQueue instance] addQueue: queue withCategory: @"Default"];
}

@end
