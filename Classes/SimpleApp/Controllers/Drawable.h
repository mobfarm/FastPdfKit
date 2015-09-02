//
//  Drawable.h
//  FastPdfKit
//
//  Created by Matteo Gavagnin on 8/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FastPdfKit/MFOverlayDrawable.h>
#import <CoreText/CoreText.h>

@interface Drawable : NSObject <MFOverlayDrawable> {
    CFDictionaryRef _fontAttributes;
    CTLineRef _firstLine;
    CTLineRef _secondLine;
}

@end
