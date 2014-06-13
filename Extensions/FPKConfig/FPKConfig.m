//
//  FastPdfKit Extension
//

#import "FPKConfig.h"

@implementation FPKConfig

#pragma mark -
#pragma mark Initialization

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;
        
        if([[params objectForKey:@"params"] objectForKey:@"zoom"]){
            NSNumber *pZoom = [NSNumber numberWithFloat:[[[params objectForKey:@"params"] objectForKey:@"zoom"] floatValue]];
            if([manager respondsToSelector:@selector(documentViewController)]){
                [[manager documentViewController] setMaximumZoomScale:pZoom];
            }
        }    
        if([[params objectForKey:@"params"] objectForKey:@"sides"]){
            float pSides = [[[params objectForKey:@"params"] objectForKey:@"sides"] floatValue];
            if([manager respondsToSelector:@selector(documentViewController)]){
                [[manager documentViewController] setEdgeFlipWidth:pSides];
            }
        }
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"config", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix {
    if([prefix isEqualToString:@"config"])
        return YES;
    else 
        return NO;
}

- (CGRect)rect {
    return _rect;
}

- (void)setRect:(CGRect)aRect{
    [self setFrame:aRect];
    _rect = aRect;
}

#pragma mark -
#pragma mark Cleanup

@end