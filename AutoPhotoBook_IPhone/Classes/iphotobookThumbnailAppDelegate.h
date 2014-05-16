//
//  iphotobookThumbnailAppDelegate.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GalleriesViewController;
@class LoginController;
//----------------------------------------------------------------------------------------------------------------------//
@interface iphotobookThumbnailAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet  UIWindow							*window;
	IBOutlet  GalleriesViewController			*viewController;			
			  UINavigationController			*navigationController;
	IBOutlet  LoginController                   *loginController;
	IBOutlet  UILabel							*busyLabel;
	IBOutlet  UIActivityIndicatorView			*busy;
	IBOutlet  UIView							*busyBar;
	IBOutlet  UIProgressView					*busyProgress;
	IBOutlet  UIProgressView					*downloadProgress;
	IBOutlet  UIView							*body;
	IBOutlet  UIView							*cover;
}

@property (nonatomic, retain) IBOutlet UIWindow							 *window;
@property (nonatomic, retain) IBOutlet UIView							 *cover;
@property (nonatomic, retain) IBOutlet GalleriesViewController			 *viewController;	
@property (nonatomic, retain)		   UINavigationController			 *navigationController;
@property (nonatomic, retain) IBOutlet UILabel							 *busyLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView			 *busy;
@property (nonatomic, retain) IBOutlet UIView							 *busyBar;
@property (nonatomic, retain) IBOutlet UIProgressView					 *busyProgress;
@property (nonatomic, retain) IBOutlet UIProgressView					 *downloadProgress;

- (void) doOnLoginSuccess: (NSArray *) collections;

- (void) doOnLoginFail;

- (void) doOnOffLine;

@end
//----------------------------------------------------------------------------------------------------------------------//

