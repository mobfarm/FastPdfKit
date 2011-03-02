//
//  FastPDFKit_KioskAppDelegate.m
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 25/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FastPDFKit_KioskAppDelegate.h"
#import "MenuViewController.h"
#import "MenuViewController_Kiosk.h"


@implementation FastPDFKit_KioskAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    
    MenuViewController_Kiosk *aMenuViewController = nil;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			aMenuViewController = [[MenuViewController_Kiosk alloc]initWithNibName:@"Kiosk_ipad" bundle:[NSBundle mainBundle]];
	} else {
			aMenuViewController = [[MenuViewController_Kiosk alloc]initWithNibName:@"Kiosk_phone" bundle:[NSBundle mainBundle]];
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

@end
