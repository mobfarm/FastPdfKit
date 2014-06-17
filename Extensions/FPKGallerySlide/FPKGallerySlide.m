//
//  FastPdfKit Extension
//

#import "FPKGallerySlide.h"
#import "UIImagesScrollView.h"
#import "MFDocumentManager.h"

@implementation FPKGallerySlide

#pragma mark -
#pragma mark Initialization

// NSLog(@"FPKGallerySlide - ");

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;
        
        if ([[params objectForKey:@"load"] boolValue]){
            CGRect origin = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
            int loop;
            if ([[params objectForKey:@"params"] objectForKey:@"loop"]){
                loop = [[[params objectForKey:@"params"] objectForKey:@"loop"] intValue];
            } else {
                // Defaulting to 0
                loop = 0;
            }
            
            NSString * resource;
            if([manager isKindOfClass:NSClassFromString(@"FPKOverlayManager")]){
                resource = [[[manager documentViewController] document] resourceFolder];
            } else {
                resource = [manager performSelector:@selector(resourcePath)];
            }
                
            NSArray * images = [[[params objectForKey:@"params"] objectForKey:@"images"] componentsSeparatedByString:@","];
            
            if ([images count] > 0){
                NSMutableArray * uiImages = [[NSMutableArray alloc] init];
                
                for(NSString *image in images){
                    UIImage *imageI = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",resource , image]];
                    // NSLog(@"%@", [NSString stringWithFormat:@"%@/%@",resource , image]);
                    if (imageI) {
                        [uiImages addObject:imageI];
                    } else {
//                        NSLog(@"FPKGallerySlide - Image named %@ not found at the path you specified.", image);
                    }
                }
                
                _pagingViewController = (id)[[UIImagesScrollView alloc] initWithFrame:origin
                                                                                         andArrayImg:uiImages
                                                                                             andLoop:loop
                                                            ];

                
                [self addSubview:(UIImagesScrollView *)_pagingViewController];
                
            } else {
//                NSLog(@"FPKGallerySlide - Parameter images not found or empty, check the uri, it should be in the form: ");
//                NSLog(@"FPKGallerySlide - galleryslide://?images=img1.png,img2.png,img3.png");
            }
        }
    }
    return self;  
}

- (void)willRemoveOverlayView:(FPKOverlayManager *)manager{
    [(UIImagesScrollView *)_pagingViewController invalidateTimer];
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"galleryslide", nil];
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

@end