//
//  FPKYouTube.m
//  FastPdfKit Extension
//

#import "FPKYouTube.h"

@implementation FPKYouTube

#pragma mark -
#pragma mark Initialization

static NSString * embedURLMask = @"http://youtube.com/v/%@";

+(NSString *)youtubeEmbedURLMask
{
    return embedURLMask;
}

+(void)setYoutubeEmbedURLMask:(NSString *)mask
{
    embedURLMask = [mask copy];
}

+(NSString *)guessYoutubeLinkWithPath:(NSString *)path
{
    NSRange location = NSMakeRange(0, 0);
    
    if((location=[path rangeOfString:@".com/watch?v="]).location!=NSNotFound)
    {
        return [path substringFromIndex:location.location + location.length];
    }
    else if ((location = [path rangeOfString:@".com/v/"]).location!=NSNotFound)
    {
        return [path substringFromIndex:location.location + location.length];
    }
    else if ((location = [path rangeOfString:@".com/embed/"]).location!=NSNotFound)
    {
        return [path substringFromIndex:location.location + location.length];
    }
    return path;
    
}

- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    
    if (self = [super initWithFrame:frame])
    {
        [self setFrame:frame];
        _rect = frame;
        
        /**
         * As we are an FPKWebView we can remove the background, otherwise a grayish borded will appear sometimes
         */
        [self removeBackground];
        
        self.autoresizesSubviews = YES;
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);

        NSString * prefix = params[@"prefix"];
        
        if([prefix isEqualToString:@"utube"])
        {
            
            NSString * path = params[@"path"];
            
            NSString * url = [FPKYouTube guessYoutubeLinkWithPath:path];
            
            NSString *youTubeVideoHTML = [NSString stringWithFormat:@"<html>"
                                          "<head>"
                                          "<style type=\"text/css\">body {background-color: transparent;color: blue;}</style>"
                                          "</head>"
                                          "<body style=\"margin:0\">"
                                          "<iframe width=\"%d\" height=\"%d\" src=\"http://www.youtube-nocookie.com/embed/%@\" frameborder=\"0\"></iframe>"
                                          "</body>"
                                          "</html>",
                                          (unsigned int)frame.size.width,
                                          (unsigned int)frame.size.height,
                                          url];
            
            [self loadHTMLString:youTubeVideoHTML baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
        }
        else if ([prefix isEqualToString:@"youtube"])
        {
            NSString * path = params[@"path"];
            
            NSString * url = [FPKYouTube guessYoutubeLinkWithPath:path];
            
            NSString *youTubeVideoHTML = [NSString stringWithFormat:@"<html>"
                                          "<head>"
                                          "<style type=\"text/css\">body {background-color: transparent;color: blue;}</style>"
                                          "</head>"
                                          "<body style=\"margin:0\">"
                                          "<iframe width=\"%d\" height=\"%d\" src=\"http://www.youtube-nocookie.com/embed/%@\" frameborder=\"0\"></iframe>"
                                          "</body>"
                                          "</html>",
                                          (unsigned int)frame.size.width,
                                          (unsigned int)frame.size.height,
                                          url];
            
            [self loadHTMLString:youTubeVideoHTML baseURL:[NSURL URLWithString:@"http://www.youtube.com"]];
        }
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes
{
    return [NSArray arrayWithObjects:@"utube", @"youtube", nil];
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