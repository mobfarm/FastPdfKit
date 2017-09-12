//
//  FastPDFKit_SampleAppDelegate.m
//  FastPDFKit Sample
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright MobFarm S.r.l. 2010. All rights reserved.
//

#import "FastPDFKit_SampleAppDelegate.h"
#import "MenuViewController.h"

@implementation FastPDFKit_SampleAppDelegate

#pragma mark -
#pragma mark Application lifecycle

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    // Load default settings
    NSString * bundlePath = [[NSBundle mainBundle]bundlePath];
    NSString * settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString * settingsPath = [NSBundle pathForResource:@"Root" ofType:@"plist" inDirectory:settingsBundlePath];
    
    NSLog(@"Settings %@", settingsPath);
    
    NSDictionary * settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:settingsDictionary];
    
	return YES;
}

@end
