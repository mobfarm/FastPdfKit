//
//  FastPDFKit_KioskAppDelegate.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Newsstandkit/NewsstandKit.h>
#import "MenuViewController_Kiosk.h"


@interface FastPDFKit_KioskAppDelegate : NSObject <UIApplicationDelegate,NSURLConnectionDownloadDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
    UIBackgroundTaskIdentifier bgTask;
    MenuViewController_Kiosk *menuVC_Kiosk;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic,retain ) MenuViewController_Kiosk *menuVC_Kiosk;

- (BOOL)handleFPKFile:(NSString *)namePdf;

@end
