//
//  iphotobookThumbnailAppDelegate.m
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import "iphotobookThumbnailAppDelegate.h"
#import "GalleriesViewController.h"
#import "LoginController.h"
#import "GlobalController.h"
#import "MagicBorder.h"
#import "SettingsManager.h"
#import "URLLoader.h"
#import "Env.h"
#import "InitResourceQueue.h"
#import "DataLoaderQueue.h"

//----------------------------------------------------------------------------------------------------------------------//
@implementation iphotobookThumbnailAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;

@synthesize busy;
@synthesize busyLabel;
@synthesize busyBar;
@synthesize busyProgress;
@synthesize downloadProgress;
@synthesize cover;

#pragma mark init
//----------------------------------------------------------------------------------------------------------------------//
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	if ([Env instance].firstTime) {
		InitResourceQueue *queue = [InitResourceQueue queue];
		[[DataLoaderQueue instance] addQueue: queue withCategory: @"Default"];
	}

	navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[GlobalController instance].appDelegate = self;
	[[GlobalController instance] updateDownloadProgress: -1];
	// Configure and show the window
	[body addSubview:[navigationController view]];
	NSUserDefaults *uds = [SettingsManager loadUserSettings: @"acid_preference"];
	NSString *acid = [uds stringForKey: @"acid_preference"];
	NSString *acpwd = [uds stringForKey: @"acpwd_preference"];
	[URLLoader setOffline: YES];
	if ([acid length] > 0 && [acpwd length] > 0) {
		[[GlobalController instance] doLogin: acid withPassword: acpwd];
	}
	[navigationController presentModalViewController: loginController animated: NO];

	NSMutableArray *borders = [[Env instance].storage valueForKey: @"borders"];
	
	//if (borders == nil) {
		//@"01_ornaments.xml", @"02_largeframe.xml", @"03_starcard.xml", @"04_table.xml", @"05_joycard.xml"
	//		borders = [NSMutableArray arrayWithObjects: @"02_largeframe.xml", @"04_table.xml", nil];
	borders = [NSMutableArray arrayWithObjects: @"04_table.xml", nil];
		[[Env instance].storage setValue: borders forKey: @"borders"];
	//}
	
    [window makeKeyAndVisible];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)applicationWillTerminate:(UIApplication *)application						// clean up is just for Demo safety
{
}
//----------------------------------------------------------------------------------------------------------------------//
- (void)dealloc {
    [window				  release];
    [viewController		  release];
	[navigationController release];
	
    [super dealloc];
}
//----------------------------------------------------------------------------------------------------------------------//
- (void) doOnLoginSuccess: (NSArray *) collections{
	viewController.galleries = collections;
	[viewController.tableView reloadData];
	[navigationController dismissModalViewControllerAnimated: YES];
	[[Env instance].storage setValue: [NSNumber numberWithBool: YES] forKey: @"loginInited"];
	[[Env instance] save];
}

- (void) doOnLoginFail{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:nil
						  message:@"Login Failed, please double check your username and password!" 
						  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) doOnOffLine{
	if ([URLLoader isOffline]) {
		[URLLoader setOffline: NO];
		return;
	}
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:nil
						  message:@"Unable to connect to the server!" 
						  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	if ([[[Env instance].storage valueForKey: @"loginInited"] boolValue]) {
		[URLLoader setOffline: YES];
		NSUserDefaults *uds = [SettingsManager loadUserSettings: @"acid_preference"];
		NSString *acid = [uds stringForKey: @"acid_preference"];
		NSString *acpwd = [uds stringForKey: @"acpwd_preference"];
		if ([acid length] > 0 && [acpwd length] > 0) {
			[[GlobalController instance] doLogin: acid withPassword: acpwd];
		}
	}
}
@end
