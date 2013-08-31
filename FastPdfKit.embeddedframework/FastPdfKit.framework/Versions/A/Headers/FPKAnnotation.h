//
//  FPKAnnotation.h
//  FastPdfKitLibrary
//
//  Created by Nicolò Tosi on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface FPKAnnotation : NSObject {

    CGRect rect;
    
}

/**
 Rect of the annotation in page coordinates (origin at the bottom left).
 */
@property (nonatomic,readwrite) CGRect rect;

@end

