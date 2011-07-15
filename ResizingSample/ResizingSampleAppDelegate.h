//
//  ResizingSampleAppDelegate.h
//  ResizingSample
//
//  Created by Nicolò Tosi on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoveViewController;
@interface ResizingSampleAppDelegate : NSObject <UIApplicationDelegate> {
    MoveViewController * moveViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MoveViewController * moveViewController;

@end
