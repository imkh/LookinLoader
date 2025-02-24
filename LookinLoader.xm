//
//  RHRevealLoader.xm
//  RHRevealLoader
//
//  Created by Richard Heard on 21/03/2014.
//  Copyright (c) 2014 Richard Heard. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <dlfcn.h>

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //NSDictionary *prefs = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.x.lookinloader.plist"] retain];
    NSString *libraryPath = @"/var/jb/Library/LookinLoader/LookinServer";

    @try {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if (!bundleIdentifier) {
            NSLog(@"[LookinLoader] Error: Unable to get bundle identifier");
            [pool drain];
            return;
        }

        // Skip loading the tweak if the current process is SpringBoard
        if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
            NSLog(@"[LookinLoader] Skipping LookinLoader for SpringBoard");
            [pool drain];
            return;
        }

        //if([[prefs objectForKey:[NSString stringWithFormat:@"LookinEnabled-%@", bundleIdentifier]] boolValue]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:libraryPath]) {
            NSLog(@"[LookinLoader] Error: LookinServer not found at path: %@", libraryPath);
            [pool drain];
            return;
        }

        void *handle = dlopen([libraryPath UTF8String], RTLD_NOW);
        if (!handle) {
            const char *error = dlerror();
            NSLog(@"[LookinLoader] Error loading library: %s", error ? error : "Unknown error");
            [pool drain];
            return;
        }

        NSLog(@"[LookinLoader] Successfully loaded %@ for %@", libraryPath, bundleIdentifier);
        //}
    } @catch (NSException *exception) {
        NSLog(@"[LookinLoader] Exception occurred: %@", exception);
    }
    
    [pool drain];
}
