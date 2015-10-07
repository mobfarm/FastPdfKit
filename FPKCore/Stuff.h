/*
 *  Stuff.h
 *  OffscreenRendererTest
 *
 *  Created by Nicolò Tosi on 4/21/10.
 *  Copyright 2010 MobFarm S.r.l. All rights reserved.
 *
 */

#define ORIENTATION_PORTRAIT 0
#define ORIENTATION_LANDSCAPE 1

#define DETAIL_POPIN_DELAY 0.15

#define MF_C_FREE(x)\
if((x)!=NULL) {		\
free((x)),(x)=NULL; \
}					\

#define MF_BUNDLED_BUNDLE(x) [NSBundle bundleWithPath:[[NSBundle mainBundle]pathForResource:(x) ofType:@"bundle"]]
#define MF_BUNDLED_RESOURCE(x,k,z) [(MF_BUNDLED_BUNDLE(x))pathForResource:(k) ofType:(z)]

#define FPK_READER_BUNDLE @"FPKReaderBundle"
#define FPK_BUNDLED_IMAGE_FORMAT @"png"
#define FPK_BUNDLED_IMAGE(img_name) [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(FPK_READER_BUNDLE,(img_name),FPK_BUNDLED_IMAGE_FORMAT)]


#define PRINT_TRANSFORM(c,t) NSLog(@"%@ - [%.3f %.3f %.3f %.3f %.3f %.3f]",(c),(t).a,(t).b,(t).c,(t).d,(t).tx,(t).ty)
#define PRINT_RECT(c,r) NSLog(@"%@ - (%.3f, %.3f)[%.3f x %.3f]",(c),(r).origin.x,(r).origin.y,(r).size.width,(r).size.height)
#define PRINT_SIZE(c,s) NSLog(@"%@ - (%.3f, %.3f)",(c),(s).width,(s).height)

/**
 * Cached image format.
 * FPKCacheImageFormatStandard - Same size on retina a non retina devices, faster. 
 * FPKCacheImageFormatTrueToPixels - True to pixel, better quality.
 * FPKCacheImageFormatAnamorphic - True to pixel on vertical axis, middleground.
 */
enum FPKImageCacheScale
{
    FPKImageCacheScaleStandard = 0,
    FPKImageCacheScaleTrueToPixels,
    FPKImageCacheScaleAnamorphic
};
typedef NSUInteger FPKImageCacheScale;

/**
 * Force tiles.
 * FPKForceTilesNever - Never use highly detailed tiles at 1x.
 * FPKForceTilesAlways - Always show highly detailed tiles at 1x.
 * FPKForceTilesOverflowOnly - Use tiles at 1x only when in overflow mode.
 */
enum FPKForceTiles
{
    FPKForceTilesNever = 0,
    FPKForceTilesAlways,
    FPKForceTilesOverflowOnly    
};
typedef NSUInteger FPKForceTiles;

/**
 Search mode for MFDocumentManager search methods.
 FPKSearchModeHard - if you search for term 'à' it will only match 'à'.
 FPKSearchModeSoft - if you search for term 'à' it will match 'a' and 'à'.
 FPKSearchModeSmart - if you search for term 'a' it will match both 'a' and 'à', but if you search for 'à' it will only match 'à'.
 */
enum FPKSearchMode {
    FPKSearchModeHard = 1,
    FPKSearchModeSoft = 2,
    FPKSearchModeSmart = 0
};
typedef unsigned int FPKSearchMode;

/**
 When the lead property of the MFDocumentViewController is set to MFDocumentLeadLeft, the odd numbered page is shown
 on the left side of the view. MFDocumentLeadRight move the odd page on the right, and this should be the default behaviour
 when dealing with books or magazines.
 */
enum MFDocumentLead {
	MFDocumentLeadLeft = 0,
	MFDocumentLeadRight = 1
};
typedef NSUInteger MFDocumentLead;

/**
 Pretty much self explanatory: when the mode property of the MFDocumentViewController is set to MFDocumentModeSingle, a single
 page is drawn on the view. MFDocumentModeDouble display two pages side-by-side.
 */
enum MFDocumentMode {
	MFDocumentModeSingle = 0,
	MFDocumentModeDouble,
    MFDocumentModeOverflow
};
typedef NSUInteger MFDocumentMode;

/**
 Set the default mode to automatically adopt upon rotation.
 */
enum MFDocumentAutoMode {
    MFDocumentAutoModeNone = 0,
    MFDocumentAutoModeSingle = 1,
    MFDocumentAutoModeDouble = 2,
    MFDocumentAutoModeOverflow = 3
};
typedef NSUInteger MFDocumentAutoMode;

/**
 MFDocumentDirectionL2R is the standard for western magazine and books. Set the direction property of MFDocumentViewController
 to MFDocumentDirectionR2L if you want to display document likes manga.
 */
enum MFDocumentDirection {
	MFDocumentDirectionL2R = 0,
	MFDocumentDirectionR2L = 1
};
typedef NSUInteger MFDocumentDirection;

/**
 Supported orientation.
 */
enum FPKSupportedOrientation {
    FPKSupportedOrientationNone = 0,
    FPKSupportedOrientationPortrait = 1,
    FPKSupportedOrientationPortraitUpsideDown = 2,
    FPKSupportedOrientationLandscapeRight = 4,
    FPKSupportedOrientationLandscapeLeft = 8,
    FPKSupportedOrientationPortaitBoth = FPKSupportedOrientationPortrait|FPKSupportedOrientationPortraitUpsideDown,
    FPKSupportedOrientationLandscape = FPKSupportedOrientationLandscapeLeft|FPKSupportedOrientationLandscapeRight,
    FPKSupportedOrientationAll = FPKSupportedOrientationLandscape|FPKSupportedOrientationPortaitBoth
};
typedef NSUInteger FPKSupportedOrientation;


static BOOL isOrientationSupported(NSUInteger orientation, NSUInteger orientations) {
    
    NSUInteger zeroOrNotZero;
    zeroOrNotZero = (orientation & orientations);
    
    if(zeroOrNotZero) {
        return YES;
    }
    
    return NO;
}

#define IS_DEVICE_PAD ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
