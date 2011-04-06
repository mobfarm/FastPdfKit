//
//  MFOverlayDrawable.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

@protocol MFOverlayDrawable

/**
 Implement this method to perform drawing in an overlay over the document view. The context coordinate system is aligend
 to the user space of the document displayed.
 */
-(void)drawInContext:(CGContextRef)context;

@end
