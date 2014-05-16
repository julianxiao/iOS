//
//  LoginController.h
//  iphotobookThumbnail
//
//  Created by Song on 3/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GalleriesViewController;

@interface LoginController : UIViewController {
	IBOutlet UITextField *username;
	IBOutlet UITextField *password;
	IBOutlet GalleriesViewController *galleriesViewController;
}

@property (nonatomic, retain) GalleriesViewController *galleriesViewController;

- (IBAction) doLogin;
- (IBAction) doSignup;

- (IBAction) editDone;
@end
