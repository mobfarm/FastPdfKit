//
//  FPKSharedSettings.h
//  FastPdfKitLibrary
//
//  Created by Nicolò Tosi on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Stuff.h"

@class MFDocumentViewController;
@class MFDocumentManager;

@interface FPKSharedSettings : NSObject

/**
 * Wether to show a shadow under the pages.
 */
@property (readwrite, nonatomic) BOOL showShadow;

/**
 * Page padding, clipped between 0 and 100.
 */
@property (readwrite, nonatomic) CGFloat padding;

/**
 * Use JPEG instead of PNG as the image cache format.
 */
@property (readwrite, nonatomic) BOOL useJPEG;

/**
 * JPEG compression level, clipped between 0 and 1.0
 */
@property (readwrite, nonatomic) CGFloat compressionLevel;

/**
 * Image cache scaling.
 */
@property (readwrite, nonatomic) FPKImageCacheScale cacheImageScale;

/**
 * Force high-res tiles on 1x zoom level.
 */
@property (readwrite, nonatomic) FPKForceTiles forceTiles;

/**
 * If true, high-res images are enabled. Default true.
 */
@property (readwrite, nonatomic) BOOL foregroundEnabled;

@end
