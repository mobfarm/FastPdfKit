//
//  FastPdfKit Extension
//

#import "FPKWebPopup.h"

@implementation FPKWebPopup

#pragma mark -
#pragma mark Initialization

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;

        if (![[params objectForKey:@"load"] boolValue]){
            CGRect popRect;
            if([[params objectForKey:@"params"] objectForKey:@"w"] && [[params objectForKey:@"params"] objectForKey:@"h"]){
                popRect = CGRectMake(0., 0., [[[params objectForKey:@"params"] objectForKey:@"w"] floatValue], [[[params objectForKey:@"params"] objectForKey:@"h"] floatValue]);
            } else {
                // Parameters w and h are not present: defaulting to full screen
                UIWindow* window = [UIApplication sharedApplication].keyWindow;
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    popRect = CGRectMake(0., 0., window.frame.size.height-40.0, window.frame.size.width - 40.0);
                } else {
                    popRect = CGRectMake(0., 0., window.frame.size.width-40.0, window.frame.size.height - 40.0);
                }
            }
            CGRect innerRect = CGRectMake(0.0, 0.0, popRect.size.width-42.0, popRect.size.height - 71.0);
            DDSocialDialog *blankDialog = [[DDSocialDialog alloc] initWithFrame:popRect andOriginalFrame:frame theme:DDSocialDialogThemeTwitter];
            blankDialog.dialogDelegate = self;
            blankDialog.titleLabel.text = [params objectForKey:@"path"];
            UIWebView *web = [[UIWebView alloc] initWithFrame:innerRect];
            NSString *prefix = @"http";
            if([[params objectForKey:@"prefix"] isEqualToString:@"popwebs"])
                prefix = @"https";
            NSURL * _url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", prefix, [params objectForKey:@"path"]]];
            NSURLRequest * request = nil;
            request = [[NSURLRequest alloc]initWithURL:_url];
            [web loadRequest:request];
            
            [blankDialog.contentView addSubview:web];
            [blankDialog show];
            
        } else {
            CGRect origin = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
            UIView* view = [[UIView alloc] initWithFrame:origin]; 
            UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fpkwebpopup-safari.png"]];        
            [image setFrame:CGRectMake(view.frame.size.width/2.0-image.frame.size.width/2.0, view.frame.size.height/2.0-image.frame.size.height/2.0, image.frame.size.width, image.frame.size.height)];
            [view addSubview:image];
            [view setAutoresizesSubviews:YES];
            
            [self addSubview:view];
            
        }
    }
    return self;  
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"webpopup", @"webpopups", nil];
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