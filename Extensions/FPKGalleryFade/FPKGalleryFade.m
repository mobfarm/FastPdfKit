//
//  FPKGalleryFade.m
//  FastPdfKit Extension
//

#import "FPKGalleryFade.h"
#import "TransitionGalleryView.h"
#import "MFDocumentManager.h"

@implementation FPKGalleryFade

#pragma mark -
#pragma mark Initialization

// NSLog(@"FPKGalleryFade - ");

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager {
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
        
        NSString * prefix = params[@"prefix"];
        
        if([prefix caseInsensitiveCompare:@"galleryfade"] == 0)
        {
            NSDictionary * parameters = params[@"params"];
            
            NSMutableArray *items = [NSMutableArray array];
            NSArray *images = [parameters[@"images"] componentsSeparatedByString:@","];
            if([images count] == 0){
                //            NSLog(@"FPKGalleryFade - No images provided. Please use an url with format:");
                //            NSLog(@"FPKGalleryFade - galleryfade://?images=img1.png,img2.png");
            }
            
            for(NSString *image in images)
            {
                UIImage *imageI = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",resource, image]];
                if (imageI)
                {
                    [items addObject:imageI];
                }
            }
            
            if ([items count] > 0)
            {
                TransitionGalleryView * gallery = [[TransitionGalleryView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
                [gallery setBackgroundColor:[UIColor clearColor]];
                id timeValue = parameters[@"time"];
                if(timeValue)
                {
                    [gallery setDuration:[timeValue floatValue]];
                }
                
                [gallery setImage:[items objectAtIndex:0]];
                [gallery setImages:items];
                [gallery startFadeAnimation];
                
                [self addSubview:gallery];
            }
        }
        else if ([prefix caseInsensitiveCompare:@"images"] == 0)
        {
            
            NSDictionary * parameters = params[@"params"];
            
            NSMutableArray *items = [NSMutableArray array];
            NSArray *images = [parameters[@"resource"] componentsSeparatedByString:@";"];
            if([images count] == 0){
                //            NSLog(@"FPKGalleryFade - No images provided. Please use an url with format:");
                //            NSLog(@"FPKGalleryFade - galleryfade://?images=img1.png,img2.png");
            }
            
            for(NSString *image in images)
            {
                UIImage *imageI = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",resource, image]];
                if (imageI)
                {
                    [items addObject:imageI];
                }
            }
            
            if ([items count] > 0)
            {
                TransitionGalleryView * gallery = [[TransitionGalleryView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
                [gallery setBackgroundColor:[UIColor clearColor]];
                id timeValue = parameters[@"time"];
                if(timeValue)
                {
                    [gallery setDuration:[timeValue floatValue]];
                }
                
                [gallery setImage:[items objectAtIndex:0]];
                [gallery setImages:items];
                [gallery startFadeAnimation];
                
                [self addSubview:gallery];
                
            }
        }
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes
{
    return [NSArray arrayWithObjects:@"galleryfade",@"images", nil];
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

- (void)setRect:(CGRect)aRect
{
    [self setFrame:aRect];
    _rect = aRect;
}

#pragma mark -
#pragma mark Cleanup

@end