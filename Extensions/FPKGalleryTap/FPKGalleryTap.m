//
//  FastPdfKit Extension
//

#import "FPKGalleryTap.h"
#import "TransitionImageView.h"
#import "BorderImageView.h"
#import <FastPdfKit/MFDocumentManager.h>

@interface FPKGalleryTap (Private)
-(TransitionImageView *)mainImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;
-(UIView *)buttonImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;
-(void)changeImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;
@end

@implementation FPKGalleryTap

#pragma mark -
#pragma mark Initialization

// NSLog(@"FPKGalleryTap - ");

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init])  {
        
        [self setFrame:frame];
        _rect = frame;
        
        // Add Here your Extension code.
        
        CGRect origin = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        if ([[params objectForKey:@"params"] objectForKey:@"button"] && [[[params objectForKey:@"params"] objectForKey:@"button"] boolValue]) {
            // This is an annotation for a button
            
            if ([[params objectForKey:@"load"] boolValue]){
                // Whe should return the image to be rendered 
                [self addSubview:[self buttonImageWithParams:params andFrame:origin from:manager]];
            }
            else {
                // Need to check for the main image and change it's content
                [self changeImageWithParams:params andFrame:frame from:manager];
            }

        } else {
            // This should be the annotation for the big image
            if ([[params objectForKey:@"load"] boolValue]){
                
                UIImageView * image = [self mainImageWithParams:params andFrame:origin from:manager];
                
                if(image) {
                    [self addSubview:[self mainImageWithParams:params andFrame:origin from:manager]];
                }
            }
        }
    }
    return self;  
}

-(TransitionImageView *)mainImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    
    
    NSString * resourcePath = nil;
    
    if([manager respondsToSelector:@selector(documentViewController)]){
        resourcePath = [[[manager documentViewController] document] resourceFolder];
    } else {
        resourcePath = [manager performSelector:@selector(resourcePath)];
    }
    
    NSString * file = [NSString stringWithFormat:@"%@/%@",
                       resourcePath, 
                       [[params objectForKey:@"params"] objectForKey:@"resource"]];
                       
    UIImage *imageI = [UIImage imageWithContentsOfFile:
                            file
                       ];
    
    if (imageI) {
        
        TransitionImageView *image = [[TransitionImageView alloc] initWithImage:imageI];
        
        [image setContentMode:UIViewContentModeScaleAspectFill];
        image.multipleTouchEnabled = YES;
        image.userInteractionEnabled = YES;
        [image setAutoresizesSubviews:YES];
        [image setClipsToBounds:YES];
        
        if([[params objectForKey:@"params"] objectForKey:@"id"]){
            
            image.tag = [[[params objectForKey:@"params"] objectForKey:@"id"] intValue];
        
        } else {
//            NSLog(@"FPKGalleryTap - Parameter id not found, check the uri, it should be in the form: ");
//            NSLog(@"FPKGalleryTap - gallerytap://image.png?id=1");
        }
        
        [image setFrame:frame];
        [image setBackgroundColor:[UIColor clearColor]];
        // [overlays addObject:image];
        
        return image;
        
    } else {
//        NSLog(@"FPKGalleryTap - Image not found, check the uri, it should be one of: ");
//        NSLog(@"FPKGalleryTap - gallerytap://image.png or gallerytap://button");
        return nil;
    }
}

-(void)changeImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{

    NSString * resource;

    if([manager respondsToSelector:@selector(documentViewController)]){
        resource = [[[manager documentViewController] document] resourceFolder];
    } else {
        resource = [manager performSelector:@selector(resourcePath)];
    }
    
    TransitionImageView *view = (TransitionImageView *)[manager overlayViewWithTag:[[[params objectForKey:@"params"] objectForKey:@"target_id"] intValue]];
    BOOL animating = YES;
    if([[params objectForKey:@"params"] objectForKey:@"animate"])
        animating = [[[params objectForKey:@"params"] objectForKey:@"animate"] boolValue];
    float time = 1.0;
    if([[params objectForKey:@"params"] objectForKey:@"time"])
        time = [[[params objectForKey:@"params"] objectForKey:@"time"] floatValue];
    
    [view setImage:[UIImage imageWithContentsOfFile:
                        [NSString stringWithFormat:@"%@/%@",
                            resource, 
                            [[params objectForKey:@"params"] objectForKey:@"resource"]
                         ]
                    ] 
        withTransitionAnimation:animating 
        withDuration:time];
    
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    if([[params objectForKey:@"params"] objectForKey:@"color"]){
        
        NSArray * arrayColor = [[[params objectForKey:@"params"] objectForKey:@"color"] componentsSeparatedByString:@"-"];
        if ([arrayColor count] == 4) {
            color = [UIColor colorWithRed:[[arrayColor objectAtIndex:0] floatValue] green:[[arrayColor objectAtIndex:1] floatValue] blue:[[arrayColor objectAtIndex:2] floatValue] alpha:[[arrayColor objectAtIndex:3] floatValue]];
        }
        [(BorderImageView *)[manager overlayViewWithTag:[[[params objectForKey:@"params"] objectForKey:@"id"] intValue]] setSelected:YES withColor:color];   
        
    } else if([[params objectForKey:@"params"] objectForKey:@"r"] && [[params objectForKey:@"params"] objectForKey:@"g"] && [[params objectForKey:@"params"] objectForKey:@"b"]){
        [(BorderImageView *)[manager overlayViewWithTag:[[[params objectForKey:@"params"] objectForKey:@"id"] intValue]] setSelected:YES withColor:
            [UIColor colorWithRed:[[[params objectForKey:@"params"] objectForKey:@"r"] floatValue]/255.0
                         green:[[[params objectForKey:@"params"] objectForKey:@"g"] floatValue]/255.0
                          blue:[[[params objectForKey:@"params"] objectForKey:@"b"] floatValue]/255.0
                         alpha:1.0
             ]
         ];   
    } else{
        // rgb parameters not present, defaulting to red
        [(BorderImageView *)[manager overlayViewWithTag:[[[params objectForKey:@"params"] objectForKey:@"id"] intValue]] setSelected:YES withColor:[UIColor redColor]]; 
    
    }
    
    // Removing the border from the other buttons
    if([[params objectForKey:@"params"] objectForKey:@"others"]){
        NSArray *tags = [[[params objectForKey:@"params"] objectForKey:@"others"] componentsSeparatedByString:@","];;
        if([tags count] > 0){
            for (NSString *tag in tags) {
                [(BorderImageView *)[manager overlayViewWithTag:[tag intValue]] setSelected:NO withColor:[UIColor clearColor]];                                    
            }
        }
    }
}



-(UIView *)buttonImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    
    NSString * resourcePath = nil;
    
    if([manager respondsToSelector:@selector(documentViewController)]){
        resourcePath = [[[manager documentViewController] document] resourceFolder];
    } else {
        resourcePath = [manager performSelector:@selector(resourcePath)];
    }
    
    UIView* view = [[UIView alloc] initWithFrame:frame]; 
    
    [view setBackgroundColor:[UIColor clearColor]];
    if([[params objectForKey:@"params"] objectForKey:@"self"]){
        
        BorderImageView *inner = [[BorderImageView alloc] initWithFrame:frame];
        
        NSString * file = [NSString stringWithFormat:@"%@/%@",
                           resourcePath, 
                           [[params objectForKey:@"params"] objectForKey:@"self"]];
        
        [inner setImage:[UIImage imageWithContentsOfFile:file
                            
                            ]
                        ];
        
        NSLog(@"Buttons");
        
        [inner setContentMode:UIViewContentModeScaleAspectFill];
        [inner setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [inner setClipsToBounds:YES];
        
        if([[params objectForKey:@"params"] objectForKey:@"id"]){
            [inner setTag:[[[params objectForKey:@"params"] objectForKey:@"id"] intValue]];
        } else {
//            NSLog(@"FPKGalleryTap - Parameter id not found, check the uri, it should be in the form: ");
//            NSLog(@"FPKGalleryTap - gallerytap://button?id=1");
        }
        
        
        UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        if([[params objectForKey:@"params"] objectForKey:@"color"]){
            NSArray * arrayColor = [[[params objectForKey:@"params"] objectForKey:@"color"] componentsSeparatedByString:@"-"];
            if ([arrayColor count] == 4) {
                color = [UIColor colorWithRed:[[arrayColor objectAtIndex:0] floatValue] green:[[arrayColor objectAtIndex:1] floatValue] blue:[[arrayColor objectAtIndex:2] floatValue] alpha:[[arrayColor objectAtIndex:3] floatValue]];
            }
           [inner setSelected:NO withColor:color];
        } else if([[params objectForKey:@"params"] objectForKey:@"r"] && [[params objectForKey:@"params"] objectForKey:@"g"] && [[params objectForKey:@"params"] objectForKey:@"b"]){
            [inner setSelected:YES withColor:
             [UIColor colorWithRed:[[[params objectForKey:@"params"] objectForKey:@"r"] floatValue]/255.0
                             green:[[[params objectForKey:@"params"] objectForKey:@"g"] floatValue]/255.0
                              blue:[[[params objectForKey:@"params"] objectForKey:@"b"] floatValue]/255.0
                             alpha:1.0
              ]
             ];   
        } else{
            // rgb parameters not present, defaulting to red
            [inner setSelected:NO withColor:[UIColor whiteColor]];   
        }
        [view setClipsToBounds:YES];
        [view setAutoresizesSubviews:YES];
        [view addSubview:inner];
        
    }
    
    return view;
}


+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"gallerytap", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix{
    if([prefix isEqualToString:@"gallerytap"])
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