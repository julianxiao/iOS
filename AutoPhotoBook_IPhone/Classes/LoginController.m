//
//  LoginController.m
//  iphotobookThumbnail
//
//  Created by Song on 3/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "GalleriesViewController.h"
#import "LoginQueue.h"
#import "DataLoaderQueue.h"
#import "SettingsManager.h"
#import "Env.h"
#import "GlobalController.h"


@implementation LoginController

@synthesize galleriesViewController;

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewDidLoad{
	[super viewDidLoad];
	NSUserDefaults *uds = [SettingsManager loadUserSettings: @"acid_preference"];
	NSString *acid = [uds stringForKey: @"acid_preference"];
	NSString *acpwd = [uds stringForKey: @"acpwd_preference"];
	if ([acid length] > 0) username.text = [uds stringForKey: @"acid_preference"];
	if ([acpwd length] > 0) password.text = [uds stringForKey: @"acpwd_preference"];
}

- (void)dealloc {
	self.galleriesViewController = nil;
    [super dealloc];
}

- (IBAction) doLogin{
	[username resignFirstResponder];
	[password resignFirstResponder];

	NSUserDefaults *uds = [SettingsManager loadUserSettings: @"acid_preference"];
	[uds setObject: username.text forKey: @"acid_preference"];
	[uds setObject: password.text forKey: @"acpwd_preference"];
	[[GlobalController instance] doLogin: username.text withPassword: password.text];
}

- (IBAction) doSignup{
	[username resignFirstResponder];
	[password resignFirstResponder];
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/SignUp.do", [Env instance].serverURL]]];
}

- (IBAction) editDone {
	[username resignFirstResponder];
	[password resignFirstResponder];
}
@end
