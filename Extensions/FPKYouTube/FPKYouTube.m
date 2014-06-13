//
//  FPKYouTube.m
//  FastPdfKit Extension
//

#import "FPKYouTube.h"

@implementation FPKYouTube

#pragma mark -
#pragma mark Initialization

- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    
    if (self = [super initWithFrame:frame]) {        
        
        [self setFrame:frame];
        _rect = frame;
        
        /**
         As we are an FPKWebView we can remove the background, otherwise a grayish borded will appear sometimes
         */
        [self removeBackground];
        
        self.autoresizesSubviews = YES;
        self.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

        NSString * url = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", [params objectForKey:@"path"]];
        
        NSString *youTubeVideoHTML = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head><body style=\"background:000000;margin-top:0px;margin-left:0px\"><div><object width=\"%0.0f\" height=\"%0.0f\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed></object></div></body></html>", frame.size.height, frame.size.width, frame.size.height, url, url, frame.size.width, frame.size.height];
        [self loadHTMLString:youTubeVideoHTML baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];                
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"utube", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix{
    if([prefix isEqualToString:@"utube"])
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

@end