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

@property (nonatomic,readwrite) CGRect rect;

@end

