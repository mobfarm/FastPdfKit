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

+(BOOL)matchesURI:(NSString *)uri
{
    NSArray * prefixes = self.acceptedPrefixes;
    for(NSString * prefix in prefixes)
    {
        if([uri hasPrefix:prefix])
            return YES;
    }
    return NO;
}

+ (BOOL)respondsToPrefix:(NSString *)prefix
{
    
    NSArray * prefixes = self.acceptedPrefixes;
    for(NSString * supportedPrefix in prefixes)
    {
        if([prefix caseInsensitiveCompare:supportedPrefix] == 0)
        {
            return YES;
        }
    }
    return NO;
}

- (void)setRect:(CGRect)aRect{
    [self setFrame:aRect];
    _rect = aRect;
}

#pragma mark -
#pragma mark Cleanup

@end