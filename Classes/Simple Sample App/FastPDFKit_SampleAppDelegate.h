//
//  FastPDFKit_SampleAppDelegate.h
//  FastPDFKit Sample
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright MobFarm S.r.l. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FastPDFKit_SampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

