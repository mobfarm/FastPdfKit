//
//  FPKSearchMatchItem.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' on 21/04/15.
//
//

#import <UIKit/UIKit.h>
#import "MFTextItem.h"

@interface FPKSearchMatchItem : NSObject <MFOverlayDrawable>

/**
 * The base MFTextItem.
 */
@property (nonatomic, strong) MFTextItem * textItem;

/**
 * The highlight view.
 */
@property (nonatomic,readonly,weak) UIView * highlightView;

@property (nonatomic,readonly) CGRect boundingBox;

@property (nonatomic,strong) UIColor * highlightColor;

/**
 * Red color with 0.25 opacity.
 */
+(UIColor *)highlightRedColor;

/**
 * Yellow color with 0.25 opacity.
 */
+(UIColor *)highlightYellowColor;

/**
 * Blue color with 0.25 opacity.
 */
+(UIColor *)highlightBlueColor;

/**
 * Factory method that will return an FPKSearchItem with the specific MFTextItem.
 */
+(FPKSearchMatchItem *)searchMatchItemWithTextItem:(MFTextItem *)item;

/**
 * Utility method that will create an array of FPKSearchItem from an array of MFTextItem.
 */
+(NSArray *)searchMatchItemsWithTextItems:(NSArray *)items;

@end
