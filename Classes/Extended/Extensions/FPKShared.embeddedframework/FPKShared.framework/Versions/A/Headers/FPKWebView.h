//
//  MFWebView.h
//  Overlay
//
//  Created by Matteo Gavagnin on 10/22/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIWebView subclass that can be used to place web content without the typical gray background.
 */

@interface FPKWebView : UIWebView
/**
 Simple method to remove the gray background of the standard **UIWebView**.
 */
-(void)removeBackground;
@end
