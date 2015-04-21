//
//  FPKSearchMatchItem.m
//  FastPdfKitLibrary
//
//  Created by Nicolo' on 21/04/15.
//
//

#import "FPKSearchMatchItem.h"

@interface FPKSearchMatchItem()

@property (nonatomic, readwrite, weak) UIView * highlightView;
@property (nonatomic, readwrite) CGRect boundingBox;
@end

@implementation FPKSearchMatchItem

+(NSArray *)searchMatchItemsWithTextItems:(NSArray *)items {
    NSMutableArray * matches = [NSMutableArray new];
    for(MFTextItem * item in items) {
        FPKSearchMatchItem * match = [FPKSearchMatchItem searchMatchItemWithTextItem:item];
        [matches addObject:match];
    }
    return [NSArray arrayWithArray:matches];
}

-(UIView *)highlightView {
    
    if(!_highlightView) {
        UIView * view = [[UIView alloc]initWithFrame:self.boundingBox];
        view.backgroundColor = self.highlightColor;
        _highlightView = view;
        return view;
    }
    
    return _highlightView;
}

+(FPKSearchMatchItem *)searchMatchItemWithTextItem:(MFTextItem *)item {
    FPKSearchMatchItem * retval = [[FPKSearchMatchItem alloc]init];
    retval.textItem = item;
    retval.boundingBox = CGPathGetBoundingBox(item.highlightPath);
    retval.highlightColor = [FPKSearchMatchItem highlightRedColor];
    return retval;
}

+(UIColor *)highlightRedColor {
    
    static UIColor * color = NULL;
    
    if(!color) {
        
        color = [[UIColor alloc]initWithRed:1.0 green:0.0 blue:0.0 alpha:0.25];
    }
    
    return color;
}

+(UIColor *)highlightBlueColor {
    
    static UIColor * color = NULL;
    
    if(!color) {
        
        color = [[UIColor alloc]initWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
    }
    
    return color;
}

+(UIColor *)highlightYellowColor {
    static UIColor * color = NULL;
    
    if(!color) {
        
        color = [[UIColor alloc]initWithRed:1.0 green:1.0 blue:0.0 alpha:0.25];
    }
    
    return color;
}

-(void)drawInContext:(CGContextRef)context {
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, self.highlightColor.CGColor);
    CGContextBeginPath(context);
    CGContextAddPath(context, self.textItem.highlightPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

@end
