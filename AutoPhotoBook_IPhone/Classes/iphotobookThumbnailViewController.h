//
//  iphotobookThumbnailViewController.h
//  iphotobookThumbnail
//
//  Created by Jun Xiao on 3/11/09.
//  Copyright 2009 HP Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbnailScrollView;

//----------------------------------------------------------------------------------------------------------------------//
@interface iphotobookThumbnailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	IBOutlet ThumbnailScrollView *thumbnailScrollView;
}

@property (nonatomic, retain) ThumbnailScrollView *thumbnailScrollView;

@end
//----------------------------------------------------------------------------------------------------------------------//

