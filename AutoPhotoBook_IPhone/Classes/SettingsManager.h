//
//  SettingsManager.h
//  NewUE
//
//  Created by Song on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsManager : NSObject {

}

+ (NSUserDefaults *) loadUserSettings:(NSString *)aKey;
@end
