//
//  FPKAppDelegate.h
//  Extended
//
//  Created by Matteo Gavagnin on 1/4/12.
//  Copyright (c) 2012 MobFarm s.a.s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FPKMainViewController;

@interface FPKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FPKMainViewController *viewController;

@end
