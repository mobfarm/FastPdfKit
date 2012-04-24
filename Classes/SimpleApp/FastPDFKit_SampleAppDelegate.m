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

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    // Load default settings
    
    NSString * bundlePath = [[NSBundle mainBundle]bundlePath];
    NSString * settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString * settingsPath = [NSBundle pathForResource:@"Root" ofType:@"plist" inDirectory:settingsBundlePath];
    
    NSLog(@"Settings %@", settingsPath);
    
    NSDictionary * settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:settingsDictionary];
    
    MenuViewController *aMenuViewController = nil;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			aMenuViewController = [[MenuViewController alloc]initWithNibName:@"MenuView_pad" bundle:[NSBundle mainBundle]];
	} else {
			aMenuViewController = [[MenuViewController alloc]initWithNibName:@"MenuView_phone" bundle:[NSBundle mainBundle]];
	}
	UINavigationController *aNavController = [[UINavigationController alloc]initWithRootViewController:aMenuViewController];
	[aNavController setNavigationBarHidden:YES];
	[self setNavigationController:aNavController];
	
	[window addSubview:[aNavController view]];
    [window makeKeyAndVisible];
	
	// Cleanup
	
	[aNavController release];
	[aMenuViewController release];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
	[navigationController release];
    [window release];
    [super dealloc];
}


@end
