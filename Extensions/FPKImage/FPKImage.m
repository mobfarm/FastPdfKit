//
//  FPKImage.m
//  FastPdfKit Extension
//

#import "FPKImage.h"
#import "FPKTransitionImageView.h"

#import "MFDocumentManager.h"

@implementation FPKImage

#pragma mark -
#pragma mark Initialization

// NSLog(@"FPKImage - ");

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        NSLog(@"Init with parameters");
        [self setFrame:frame];
        _rect = frame;
        
        NSString * resource;
        if([manager respondsToSelector:@selector(documentViewController)]){
            resource = [[[manager documentViewController] document] resourceFolder];
        } else {
            resource = [manager performSelector:@selector(resourcePath)];
        }
                        
//        FPKTransitionImageView *image = [[FPKTransitionImageView alloc] initWithImage:
//                                        [UIImage imageWithContentsOfFile:
//                                                         [NSString stringWithFormat:@"%@/%@",
//                                                          resource, 
//                                                          [[params objectForKey:@"params"] objectForKey:@"resource"]]
//                                                         ]
//                                        ];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:
                                        [UIImage imageWithContentsOfFile:
                                                         [NSString stringWithFormat:@"%@/%@",
                                                          resource, 
                                                          [[params objectForKey:@"params"] objectForKey:@"resource"]]
                                                         ]
                                        ];
        
        [image setContentMode:UIViewContentModeScaleAspectFit];
        image.multipleTouchEnabled = YES;
        image.userInteractionEnabled = YES;
        [image setAutoresizesSubviews:YES];
        [image setClipsToBounds:YES];
        [image setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        // [image setStartPosition:image.center];
        // [image setDelegate:manager];
        [self addSubview:image];
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"image", nil];
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