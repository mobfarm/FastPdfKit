//
//  OverlayManager.m
//  FastPdfKit
//
//  Created by Matteo Gavagnin on 8/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OverlayManager.h"
#import "Drawable.h"

@implementation OverlayManager

/**
 * Return a single Drawable object for the first page.
 */
- (NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page{
    if(page == 1){
        return @[[Drawable new]];
    } else {
        return @[];
    }
}

@end
