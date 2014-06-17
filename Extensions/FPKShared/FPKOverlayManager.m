//
//  FPKOverlayManager.m
//  FPKShared
//

#import "FPKOverlayManager.h"
#import "FPKURIAnnotation.h"
#import "MFDocumentManager.h"
#import "FPKView.h"
#import "Stuff.h"

@implementation FPKOverlayManager
@synthesize documentViewController;

- (FPKOverlayManager *)initWithExtensions:(NSArray *)ext
{
	self = [super init];
	if (self != nil)
    {
        [self setExtensions:ext];
	}
    
	return self;
}

- (void)setExtensions:(NSArray *)ext{
    
    // Set the supported extension list. If the list is different than the
    // previous one clean up the overlays'array and prepare a fresh one.
    
    if(_extensions!=ext)
    {
        _extensions = ext;
        if(!_overlays)
        {
            _overlays = [[NSMutableArray alloc] init];
        }
        else
        {
            [_overlays removeAllObjects];
        }
    }
}

- (void)setScrollLock:(BOOL)lock
{
    [documentViewController setScrollEnabled:!lock];
    [documentViewController setGesturesDisabled:lock];
}

-(void)documentViewController:(MFDocumentViewController *)dvc willRemoveOverlayView:(UIView *)view
{
    for(UIView <FPKView> *view in _overlays)
    {
        if([view respondsToSelector:@selector(willRemoveOverlayView:)])
        {
            [view willRemoveOverlayView:self];
        }
    }
}

- (void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnAnnotationRect:(CGRect)rect withUri:(NSString *)uri onPage:(NSUInteger)page
{
    /** We are registered as delegate for the documentViewController, so we can 
     receive tap on annotations */
    [self showAnnotationForOverlay:NO withRect:rect andUri:uri onPage:page];
}

-(UIView *)overlayViewWithTag:(int)tag
{
    return [documentViewController.view viewWithTag:tag];
}

+(NSDictionary *)paramsForAltURI:(NSString *)uri
{
    NSMutableDictionary * parameters = [NSMutableDictionary new];
    
    NSScanner * scanner = [NSScanner scannerWithString:uri];
    scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    
    if([uri rangeOfString:@"["].location!=NSNotFound)
    {
        NSString * __autoreleasing params = nil;
        [scanner scanUpToString:@"]" intoString:&params];
        
        NSArray * paramsComponents = [params componentsSeparatedByCharactersInSet:[self alternateParametersSeparatorsCharacterSet]];
        if(paramsComponents.count % 2 == 0)
        {
            for(int i = 0; i < paramsComponents.count; i += 2)
            {
                parameters[paramsComponents[i]] = paramsComponents[i+1];
            }
        }
    }
    
    // Resource
    NSString * __autoreleasing resource = nil;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&resource];
    parameters[@"resource"] = resource;
    
    return parameters;
}

+(NSMutableDictionary *)alternateParamsDictionaryWithURI:(NSString *)uri
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    NSArray *uriComponents = [uri componentsSeparatedByString:@"://"];
    
	if(uriComponents.count > 0)
    {
        NSString *prefix = [uriComponents objectAtIndex:0];
        
        // 1. Prefix
        dic[@"prefix"] = prefix;
        
        if(uriComponents.count > 1)
        {
            NSString * otherThanPrefixString = uriComponents[1];
            
            parameters[@"load"] = @YES; // By default the annotations are loaded at startup
            
            NSScanner * scanner = [NSScanner scannerWithString:otherThanPrefixString];
            scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
            
            NSString * __autoreleasing paramString = nil;
            [scanner scanUpToString:@"]" intoString:&paramString];
            
            NSCharacterSet * parametersSeparators = [FPKOverlayManager alternateParametersSeparatorsCharacterSet];
            NSArray * paramComponents = [paramString componentsSeparatedByCharactersInSet:parametersSeparators];
            
            if(paramComponents.count % 2 == 0)
            {
                for(int i = 0; i < paramComponents.count; i+=2)
                {
                    NSString * paramName = paramComponents[i];
                    NSString * paramValue = paramComponents[i+1];
                    parameters[paramName] = paramValue;
                }
            }
            
            NSString * __autoreleasing path = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&path];
            dic[@"path"] = path;
            
            NSArray * pathComponents = [path componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]];
            
            if(pathComponents.count > 0)
            {
                NSString * resource = pathComponents[0];
                parameters[@"resource"] = resource;
            }
            
            dic[@"params"] = parameters;
        }
    }
    
    return dic;
}

+(NSMutableDictionary *)paramsDictionaryWithURI:(NSString *)uri
{
    /*
     Let's take the following annotation URI
    map://maps.google.com/maps?ll=41.889811,12.492088&spn=0.009073,0.01031&padding=2.0
    as example. */
    if([uri rangeOfString:@"://[" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return [self alternateParamsDictionaryWithURI:uri];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSMutableDictionary *parameters = [NSMutableDictionary new];

    /*
     1. We split the uri in prefix and path. Prefix is going to be 'map' while
     'maps.google.com/maps...' is the path.
     */
    NSArray *uriComponents = [uri componentsSeparatedByString:@"://"];
	if(uriComponents.count > 0)
    {
        /*
         2. Store the 'map' prefix.
        */
        NSString *uriType = uriComponents[0];
        dic[@"prefix"] = uriType;
        if(uriComponents.count > 1)
        {
            
            /* 
             3. Store the whole path, including the parameters. The path might
             include parameter required by the remote service to work. It will
             ignore our custom params.
            */
            
            NSString *path = uriComponents[1];
            dic[@"path"] = path;
            parameters[@"load"] = @YES; // By default the annotations are loaded at startup
            
            /*
             4. Separate the parameters from the resource ('map.google.com/maps').
             Store the resource and then process the parameters.
            */
            
            NSArray * pathComponents = [path componentsSeparatedByString:@"?"];
            if(pathComponents.count > 0)
            {
                parameters[@"resource"] = pathComponents[0];
            }
            
            if(pathComponents.count == 2)
            {
                /*
                 5. Parameters are <name>=<value> pairs separated by commas, so 
                 split the params using '=' and ',' as separators.
                 */
                NSCharacterSet * parametersSeparators = [FPKOverlayManager defaultParametersSeparatorsCharacterSet];
                NSArray * paramComponents = [pathComponents[1] componentsSeparatedByCharactersInSet:parametersSeparators];
                if(paramComponents.count % 2 == 0) // We should get an even number of components.
                {
                    for(int i = 0; i < paramComponents.count; i+=2)
                    {
                        NSString * paramName = paramComponents[i];
                        NSString * paramValue = paramComponents[i+1];
                        parameters[paramName] = paramValue;
                    }
                }
            }
            
            dic[@"params"] = parameters;
        }
    }
    
    return dic;
}

+(NSCharacterSet *)defaultParametersSeparatorsCharacterSet
{
    static NSCharacterSet * set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSCharacterSet characterSetWithCharactersInString:@"=&"];
    });
    return set;
}

+(NSCharacterSet *)alternateParametersSeparatorsCharacterSet
{
    static NSCharacterSet * set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSCharacterSet characterSetWithCharactersInString:@":,;"];
    });
    return set;
}

- (UIView *)showAnnotationForOverlay:(BOOL)load
                            withRect:(CGRect)rect
                              andUri:(NSString *)uri
                              onPage:(NSUInteger)page
{
    NSMutableDictionary * dic = [FPKOverlayManager paramsDictionaryWithURI:uri];
    
    dic[@"load"] = @(load);
    
    /**
     Set the supported extensions array when you instantiate your FPKOverlayManager subclass
     [self setExtensions:[[NSArray alloc] initWithObjects:@"FPKYouTube", nil]];
     */
    if(!_extensions)
    {
        [self setExtensions:[NSArray new]];
    }
    
    NSString * uriType = dic[@"prefix"];
    
    NSString *class = nil;
    
    if(_extensions && [_extensions count] > 0)
    {
        for(NSString *extension in _extensions)
        {
            Class classType = NSClassFromString(extension);
            
            if ([classType respondsToPrefix:uriType])
            {
                class = extension;
            }
        }
    }
    
    NSDictionary * parameters = dic[@"params"];
    
    BOOL loadByParam = [parameters[@"load"] boolValue];
    
    if (parameters[@"padding"])
    {
        CGFloat padding = [parameters[@"padding"] floatValue];
        CGFloat doublePadding = padding * 2;
        
        rect = CGRectMake(rect.origin.x + padding, rect.origin.y + padding, rect.size.width - doublePadding, rect.size.height - doublePadding);
    }
    
    UIView * retVal = nil;
    
    if (class && ((load && loadByParam) || !load))
    {
        UIView *aView = [(UIView <FPKView> *)[NSClassFromString(class) alloc] initWithParams:dic andFrame:[documentViewController convertRect:rect toViewFromPage:page] from:self];
        retVal = aView;
    }
    else
    {
        NSLog(@"FPKOverlayManager - No Extension found that supports %@", uriType);
    }
    
    return retVal;
}

#pragma -
#pragma FPKOverlayViewDataSource


- (NSArray *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page{
    // NSLog(@"overlayViewsForPage: Method Framework %i", page);
    
    [_overlays removeAllObjects];
    NSArray *annotations = [[documentViewController document] uriAnnotationsForPageNumber:page];
    
    for (FPKURIAnnotation *ann in annotations) {
        
        UIView *view = [self showAnnotationForOverlay:YES withRect:[ann rect] andUri:[ann uri] onPage:page];
        
        if(view != nil){
            [view setFrame:[documentViewController convertRect:view.frame fromOverlayToPage:page]];
            [(UIView <FPKView> *)view setRect:view.frame];
            [_overlays addObject:view];
        }
    }
    
    return [NSArray arrayWithArray:_overlays];
}

- (CGRect)documentViewController:(MFDocumentViewController *)dvc rectForOverlayView:(UIView *)view onPage:(NSUInteger)page{    
    return [(UIView <FPKView> *)view rect];
}

- (void)setGlobalParametersFromAnnotation
{
    NSString *uri = nil;
    BOOL globalFound = NO;
    NSArray *ann = [[documentViewController document] uriAnnotationsForPageNumber:1];
    if([ann count] > 0){
        // NSLog(@"There are annotations");
        for (FPKURIAnnotation * annotation in ann) {
            if ([annotation.uri hasPrefix:@"settings"]){
                uri = annotation.uri;
                NSLog(@"Global found URI: %@", uri);
                globalFound = YES;
                // break;
            }
        }    
    }
    
    if(globalFound)
    {
        NSArray *arrayParameter = nil;
        NSString *uriResource = nil;
        NSArray *arrayAfterResource = nil;
        NSArray *arrayArguments = nil;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        arrayParameter = [uri componentsSeparatedByString:@"://"];
        if([arrayParameter count] > 0){
            
            if([arrayParameter count] > 1){
                uriResource = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:1]];
                // NSLog(@"%@", uriResource);
                
                arrayAfterResource = [uriResource componentsSeparatedByString:@"?"];
                if([arrayAfterResource count] > 0)
                    [parameters setObject:[arrayAfterResource objectAtIndex:0] forKey:@"resource"];
                if([arrayAfterResource count] == 2){
                    arrayArguments = [[arrayAfterResource objectAtIndex:1] componentsSeparatedByString:@"&"];
                    for (NSString *param in arrayArguments) {
                        NSArray *keyAndObject = [param componentsSeparatedByString:@"="];
                        if ([keyAndObject count] == 2) {
                            [parameters setObject:[[keyAndObject objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[keyAndObject objectAtIndex:0]];
                            
                            // NSLog(@"%@ = %@", [keyAndObject objectAtIndex:0], [parameters objectForKey:[keyAndObject objectAtIndex:0]]);
                        }
                    }    
                }
            }
            
            // Global parameters
            // Place it on the first pdf page
            //    settings://?mode=3&automode=3&zoom=1.0&padding=0&shadow=YES&sides=0.1&status=NO
            
            if([parameters objectForKey:@"mode"])
            {
                int mode = 1;
                if([[parameters objectForKey:@"mode"] isEqualToString:@"Single"])
                {
                    mode = 1;
                }
                else  if([[parameters objectForKey:@"mode"] isEqualToString:@"Double"])
                {
                    mode = 2;
                }
                else if([[parameters objectForKey:@"mode"] isEqualToString:@"Overflow"])
                {
                    mode = 3;
                }
                [documentViewController setMode:mode];
            }
                
            if([parameters objectForKey:@"automode"])
            {
                int mode = 1;
                if([[parameters objectForKey:@"automode"] isEqualToString:@"None"])
                {
                    mode = 1;
                }
                else if([[parameters objectForKey:@"automode"] isEqualToString:@"Single"])
                {
                    mode = 2;
                }
                else  if([[parameters objectForKey:@"automode"] isEqualToString:@"Double"])
                {
                    mode = 3;
                }
                else if([[parameters objectForKey:@"automode"] isEqualToString:@"Overflow"])
                {
                    mode = 4;
                }
                
                [documentViewController setAutoMode:mode];        
            }
            if([parameters objectForKey:@"zoom"])
            {
                [documentViewController setDefaultMaxZoomScale:[[parameters objectForKey:@"zoom"] floatValue]];
                // NSLog(@"Zoom set to %f", [documentViewController defaultMaxZoomScale]);
            }
            
            if([parameters objectForKey:@"padding"])
                [documentViewController setPadding:[[parameters objectForKey:@"padding"] intValue]];
            if([parameters objectForKey:@"shadow"])
                [documentViewController setShowShadow:[[parameters objectForKey:@"padding"] boolValue]];
            if([parameters objectForKey:@"sides"])
                [documentViewController setDefaultEdgeFlipWidth:[[parameters objectForKey:@"sides"] floatValue]];
            if([parameters objectForKey:@"status"])
                [[UIApplication sharedApplication] setStatusBarHidden:![[parameters objectForKey:@"status"] boolValue] withAnimation:UIStatusBarAnimationSlide];
            
            // Every available orientatios: UIDeviceOrientationPortrait, UIDeviceOrientationPortraitUpsideDown, UIDeviceOrientationLandscapeRight, UIDeviceOrientationLandscapeLeft            
            NSMutableArray *orientations = [[NSMutableArray alloc] init];
            
            if([parameters objectForKey:@"portrait"] && [[parameters objectForKey:@"portrait"] boolValue])
                [orientations addObject:[NSNumber numberWithInt:1]];
            if([parameters objectForKey:@"portraitupsidedown"] && [[parameters objectForKey:@"portraitupsidedown"] boolValue])
                [orientations addObject:[NSNumber numberWithInt:2]];
            if([parameters objectForKey:@"landscaperight"] && [[parameters objectForKey:@"landscaperight"] boolValue])
                [orientations addObject:[NSNumber numberWithInt:4]];
            if([parameters objectForKey:@"landscapeleft"] && [[parameters objectForKey:@"landscapeleft"] boolValue])
                [orientations addObject:[NSNumber numberWithInt:8]];

            if([documentViewController respondsToSelector:@selector(setSupportedOrientation:)]){
                [documentViewController setSupportedOrientation:[self supportedOrientations:orientations]];
            }
        }
    }
}


-(NSUInteger)supportedOrientations:(NSArray *)orientations
{
    NSUInteger v = 0;
    for(NSNumber * number in orientations) {
        v|=[number intValue];
    }
    return v;
}

@end
