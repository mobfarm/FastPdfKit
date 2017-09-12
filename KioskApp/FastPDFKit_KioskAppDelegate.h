//
//  FastPDFKit_KioskAppDelegate.h
//  FastPdfKit
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Newsstandkit/NewsstandKit.h>
#import "MenuViewController_Kiosk.h"


@interface FastPDFKit_KioskAppDelegate : NSObject <UIApplicationDelegate,NSURLConnectionDownloadDelegate> {
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (BOOL)handleFPKFile:(NSString *)namePdf;

@end
