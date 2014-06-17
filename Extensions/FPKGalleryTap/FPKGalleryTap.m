//
//  FastPdfKit Extension
//

#import "FPKGalleryTap.h"
#import "TransitionImageView.h"
#import "BorderImageView.h"
#import "MFDocumentManager.h"

@interface FPKGalleryTap (Private)
-(TransitionImageView *)mainImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;
-(UIView *)buttonImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;
-(void)changeImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;
@end

@implementation FPKGalleryTap

#pragma mark -
#pragma mark Initialization

// NSLog(@"FPKGalleryTap - ");

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager
{
    if (self = [super init])  {
        
        [self setFrame:frame];
        _rect = frame;
        
        // Add Here your Extension code.
        
        CGRect origin = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        
        NSDictionary * parameters = params[@"params"];
        
        id buttonObj = nil;
        
        NSString * resource = parameters[@"resource"];
        if ([resource caseInsensitiveCompare:@"button"] == 0)
        {
            // This is an annotation for a button
            if ([params[@"load"] boolValue])
            {
                // Whe should return the image to be rendered 
                [self addSubview:[self buttonImageWithParams:params andFrame:origin from:manager]];
            }
            else
            {
                // Need to check for the main image and change it's content
                [self changeImageWithParams:params andFrame:frame from:manager];
            }

        } else {
            // This should be the annotation for the big image
            if ([params[@"load"] boolValue]){
                
                UIImageView * image = [self mainImageWithParams:params andFrame:origin from:manager];
                
                if(image) {
                    [self addSubview:image];
                    // [self addSubview:[self mainImageWithParams:params andFrame:origin from:manager]];
                }
            }
        }
    }
    return self;  
}

-(TransitionImageView *)mainImageWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager
{
    NSString * resourcePath = nil;
    
    if([manager respondsToSelector:@selector(documentViewController)]){
        resourcePath = [[[manager documentViewController] document] resourceFolder];
    } else {
        resourcePath = [manager performSelector:@selector(resourcePath)];
    }
    
    NSDictionary * parameters = params[@"params"];
    
    NSString * file = [NSString stringWithFormat:@"%@/%@",
                       resourcePath, 
                       parameters[@"resource"]];
                       
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
        
        id tagValue = nil;
        if((tagValue = parameters[@"id"]))
        {
            NSUInteger tag = [tagValue integerValue];
            image.tag = tag;
        }
        else
        {
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

    NSString * resource = nil;

    if([manager respondsToSelector:@selector(documentViewController)]){
        resource = [[[manager documentViewController] document] resourceFolder];
    } else {
        resource = [manager performSelector:@selector(resourcePath)];
    }
    
    NSDictionary * parameters = params[@"params"];
    
    id targetTagValue = parameters[@"target_id"];
    NSUInteger targetTag = [targetTagValue integerValue];
    
    TransitionImageView *view = (TransitionImageView *)[manager overlayViewWithTag:targetTag];
    BOOL animating = YES;
    
    id animate;
    if((animate = parameters[@"animate"]))
    {
        animating = [animate boolValue];
    }
    
    float time = 1.0;
    id timeValue;
    if((timeValue = parameters[@"time"]))
    {
        time = [timeValue floatValue];
    }
    
    [view setImage:[UIImage imageWithContentsOfFile:
                    [NSString stringWithFormat:@"%@/%@",
                     resource,
                     [parameters objectForKey:@"src"]
                     ]
                    ]
withTransitionAnimation:animating
      withDuration:time];
    
    NSString * colorString = nil;
    
    NSUInteger tag = [parameters[@"id"] integerValue];
    BorderImageView * target = (BorderImageView *)[manager overlayViewWithTag:tag];
    
    if(target)
    {
        if((colorString = parameters[@"color"])) {
            
            NSArray * arrayColor = [colorString componentsSeparatedByString:@"-"];
            if ([arrayColor count] == 4) {
                UIColor * color = [UIColor colorWithRed:[[arrayColor objectAtIndex:0] floatValue] green:[[arrayColor objectAtIndex:1] floatValue] blue:[[arrayColor objectAtIndex:2] floatValue] alpha:[[arrayColor objectAtIndex:3] floatValue]];
                [target setSelected:YES withColor:color];
            }
            else
            {
                [target setSelected:YES withColor:[UIColor whiteColor]];
            }
            
            
        } else
        {
            id red = parameters[@"r"];
            id green = parameters[@"g"];
            id blue = parameters[@"b"];
            
            if(red && green && blue){
                
                UIColor * color = [UIColor colorWithRed:[red floatValue]/255.0
                                green:[green floatValue]/255.0
                                 blue:[blue floatValue]/255.0
                                alpha:1.0
                 ];
                [target setSelected:YES withColor:color];
        } else{
            
            [target setSelected:YES withColor:[UIColor redColor]];
        }
        }
        
        // Removing the border from the other buttons
        
        NSString * othersString = nil;
        if((othersString  = parameters[@"others"]))
        {
            NSArray *tags = [othersString componentsSeparatedByString:@","];;
            if([tags count] > 0){
                for (NSString * tagString in tags) {
                    NSUInteger tag = [tagString integerValue];
                    BorderImageView * target = (BorderImageView *)[manager overlayViewWithTag:tag];
                    [target setSelected:NO withColor:[UIColor clearColor]];
                }
            }
        }
    }
}

-(UIView *)buttonImageWithParams:(NSDictionary *)params
                        andFrame:(CGRect)frame
                            from:(FPKOverlayManager *)manager
{
    
    NSString * resourcePath = nil;
    
    if([manager respondsToSelector:@selector(documentViewController)]){
        resourcePath = [[[manager documentViewController] document] resourceFolder];
    } else {
        resourcePath = [manager performSelector:@selector(resourcePath)];
    }
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary * parameters = params[@"params"];
    
    NSString * filename = nil;
    
    if((filename = parameters[@"self"]))
    {
        
        BorderImageView *inner = [[BorderImageView alloc] initWithFrame:frame];
        
        NSString * file = [NSString stringWithFormat:@"%@/%@",
                           resourcePath,
                           filename];
        
        [inner setImage:[UIImage imageWithContentsOfFile:file]];
        
        [inner setContentMode:UIViewContentModeScaleAspectFill];
        [inner setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [inner setClipsToBounds:YES];
        
        id tagValue = nil;
        if((tagValue = parameters[@"id"]))
        {
            NSUInteger tag = [tagValue integerValue];
            inner.tag = tag;
            
        } else {
            //            NSLog(@"FPKGalleryTap - Parameter id not found, check the uri, it should be in the form: ");
            //            NSLog(@"FPKGalleryTap - gallerytap://button?id=1");
        }
        
        NSString * colorString = nil;
        if((colorString = parameters[@"color"]))
        {
            NSArray * colorComponents = [colorString componentsSeparatedByString:@"-"];
            if (colorComponents.count == 4)
            {
                float red = [colorComponents[0] floatValue];
                float green = [colorComponents[1] floatValue];
                float blue = [colorComponents[2] floatValue];
                float alpha = [colorComponents[3] floatValue];
                
                UIColor * color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                [inner setSelected:NO withColor:color];
            }
            else
            {
                [inner setSelected:NO withColor:[UIColor whiteColor]];
            }
        }
        else {
            
            id red = parameters[@"r"];
            id green = parameters[@"g"];
            id blue = parameters[@"b"];
            
            if(red && green && blue)
            {
                UIColor * color = [UIColor colorWithRed:([red floatValue]/255.0)
                                                  green:([green floatValue]/255.0)
                                                   blue:([blue floatValue]/255.0)
                                                  alpha:1.0];
                [inner setSelected:YES withColor:color];
                
            }
            else
            {
                [inner setSelected:NO withColor:[UIColor whiteColor]];
            }
        }
        
        [view setClipsToBounds:YES];
        [view setAutoresizesSubviews:YES];
        [view addSubview:inner];
    }
    
    return view;
}

+ (NSArray *)acceptedPrefixes
{
    return [NSArray arrayWithObjects:@"gallerytap", nil];
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