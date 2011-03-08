//
//  FastPDFKit_KioskAppDelegate.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "FastPDFKit_KioskAppDelegate.h"
#import "MenuViewController.h"
#import "MenuViewController_Kiosk.h"


@implementation FastPDFKit_KioskAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    
    MenuViewController_Kiosk *aMenuViewController = nil;
	
	BOOL isPad = NO;
	
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	
	if(isPad) {
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

-(void)dealloc {

	[super dealloc];
}

@end
