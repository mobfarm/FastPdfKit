//
//  MFOverlayTouchable.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/22/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MFOverlayTouchable

/**
 Implement this method to perform a hit test. The CGPoint coordinates are defined in document user space.
 */
-(BOOL)containsPoint:(CGPoint)point;

@end
