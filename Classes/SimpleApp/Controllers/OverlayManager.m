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

- (NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page{
    NSArray *array;
    if(page == 1){
        array = [NSArray arrayWithObject:[[Drawable alloc] init]];
    } else
        array = [NSArray array];
    return array;
}

@end
