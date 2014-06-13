//
//  FPKGalleryFade.m
//  FastPdfKit Extension
//

#import "FPKGalleryFade.h"
#import "TransitionGalleryView.h"
#import <FastPdfKit/MFDocumentManager.h>

@implementation FPKGalleryFade

#pragma mark -
#pragma mark Initialization

// NSLog(@"FPKGalleryFade - ");

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;
        
        NSString * resource;
        if([manager respondsToSelector:@selector(documentViewController)]){
            resource = [[[manager documentViewController] document] resourceFolder];
        } else {
            resource = [manager performSelector:@selector(resourcePath)];
        }
        
        NSMutableArray *items = [NSMutableArray array];
        NSArray *images = [[[params objectForKey:@"params"] objectForKey:@"images"] componentsSeparatedByString:@","];
        if([images count] == 0){
//            NSLog(@"FPKGalleryFade - No images provided. Please use an url with format:");
//            NSLog(@"FPKGalleryFade - galleryfade://?images=img1.png,img2.png");
        }
        
        for(NSString *image in images){
            
            UIImage *imageI = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",resource, image]];
            
            if (imageI) {
                [items addObject:imageI];
            } else {
//                NSLog(@"FPKGalleryFade - Image named %@ not found at the path you specified.", image);
            }
        }
        if ([items count] > 0) {   
            TransitionGalleryView * gallery = [[TransitionGalleryView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
            [gallery setBackgroundColor:[UIColor clearColor]];
            if([[params objectForKey:@"params"] objectForKey:@"time"])
                [gallery setDuration:[[[params objectForKey:@"params"] objectForKey:@"time"] floatValue]];
            
            [gallery setImage:[items objectAtIndex:0]];
            [gallery setImages:items];
            // [images release];
            [gallery startFadeAnimation];
            
            [self addSubview:gallery];
            
        } else {
//            NSLog(@"FPKGalleryFade - Images not found at path that you specified:");
//            NSLog(@"FPKGalleryFade - %@", resource);
        }
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"galleryfade", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix{
    if([prefix isEqualToString:@"galleryfade"])
        return YES;
    else 
        return NO;
}

- (CGRect)rect{
    return _rect;
}

- (void)setRect:(CGRect)aRect{
    [self setFrame:aRect];
    _rect = aRect;
}

#pragma mark -
#pragma mark Cleanup

@end