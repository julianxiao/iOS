//
//  SettingsManager.m
//  NewUE
//
//  Created by Song on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"


@implementation SettingsManager

+ (NSUserDefaults *) loadUserSettings:(NSString *)aKey
{
    // Load user settings
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (![settings stringForKey:aKey])
    {
        // The settings haven't been initialized, so manually init them based
        // the contents of the the settings bundle
        NSString *bundle = [[[NSBundle mainBundle] bundlePath]
                            stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
        NSDictionary *plist = [[NSDictionary dictionaryWithContentsOfFile:bundle]
                               objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *defaults = [NSMutableDictionary new];
        
        // Loop through the bundle settings preferences and pull out the key/default pairs
        for (NSDictionary* setting in plist)
        {
            NSString *key = [setting objectForKey:@"Key"];
            if (key)
                [defaults setObject:[setting objectForKey:@"DefaultValue"] forKey:key];
        }
        
        // Persist the newly initialized default settings and reload them
        [settings setPersistentDomain:defaults forName:[[NSBundle mainBundle] bundleIdentifier]];
        settings = [NSUserDefaults standardUserDefaults];
    }
    return settings;
}

@end
