//
//  FPKOverlayManager.m
//  FPKShared
//

#import "FPKOverlayManager.h"
#import <FastPdfKit/FPKURIAnnotation.h>
#import <FastPdfKit/MFDocumentManager.h>
#import "FPKView.h"
#import <FastPdfKit/Stuff.h>

@implementation FPKOverlayManager
@synthesize documentViewController;

- (FPKOverlayManager *)initWithExtensions:(NSArray *)ext
{
	self = [super init];
	if (self != nil) {
	
        [self setExtensions:ext];
	}
    
	return self;
}

- (void)setExtensions:(NSArray *)ext{
    
    // Set the supported extension list. If the list is different than the
    // previous one clean up the overlays'array and prepare a fresh one.
    
    if(_extensions!=ext) {
        
        _extensions = ext;
        
        if(!_overlays) {
        
            _overlays = [[NSMutableArray alloc] init];
        
        } else {
            
            [_overlays removeAllObjects];
        }
    }
}

- (void)setScrollLock:(BOOL)lock{
    [documentViewController setScrollEnabled:!lock];
    [documentViewController setGesturesDisabled:lock];
}

-(void)documentViewController:(MFDocumentViewController *)dvc willRemoveOverlayView:(UIView *)view{
    for(UIView <FPKView> *view in _overlays){
        if([view respondsToSelector:@selector(willRemoveOverlayView:)]){
            [view willRemoveOverlayView:self];
        }
    }
}

- (void)documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnAnnotationRect:(CGRect)rect withUri:(NSString *)uri onPage:(NSUInteger)page{
    /** We are registered as delegate for the documentViewController, so we can receive tap on annotations */
    [self showAnnotationForOverlay:NO withRect:rect andUri:uri onPage:page];
}

-(UIView *)overlayViewWithTag:(int)tag{
    return [documentViewController.view viewWithTag:tag];
}

- (UIView *)showAnnotationForOverlay:(BOOL)load
                            withRect:(CGRect)rect
                              andUri:(NSString *)uri
                              onPage:(NSUInteger)page
{
    // NSLog(@"Uri: %@", uri);
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    /** 
        Set the supported extensions array when you instantiate your FPKOverlayManager subclass
        [self setExtensions:[[NSArray alloc] initWithObjects:@"FPKYouTube", nil]];
    */
    
    if(!_extensions) {
        [self setExtensions:[NSArray new]];
    }
    
    NSArray *arrayParameter = nil;
	NSString *uriType = nil;
    NSString *uriResource = nil;
    NSArray *arrayAfterResource = nil;
    NSArray *arrayArguments = nil;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    UIView *retVal = nil;
    
    arrayParameter = [uri componentsSeparatedByString:@"://"];
	if([arrayParameter count] > 0){
        
        uriType = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:0]];
        [dic setObject:uriType forKey:@"prefix"];
        [dic setObject:[NSNumber numberWithBool:load] forKey:@"load"];
        
        // NSLog(@"URI Type %@", uriType);
        
        if([arrayParameter count] > 1){
            uriResource = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:1]];
            [dic setObject:uriResource forKey:@"path"];
            
            // NSLog(@"Uri Resource: %@", uriResource);

            // Set default parameters
            [parameters setObject:[NSNumber numberWithBool:YES] forKey:@"load"]; // By default the annotations are loaded at startup
            
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
            if ([parameters objectForKey:@"padding"]) {
                // NSLog(@"Rect: %@", NSStringFromCGRect(rect));
                // rect = CGRectOffset(rect, -[[parameters objectForKey:@"padding"] floatValue], -[[parameters objectForKey:@"padding"] floatValue]);
                rect = CGRectMake(rect.origin.x + [[parameters objectForKey:@"padding"] floatValue], rect.origin.y + [[parameters objectForKey:@"padding"] floatValue], rect.size.width - 2*[[parameters objectForKey:@"padding"] floatValue], rect.size.height - 2*[[parameters objectForKey:@"padding"] floatValue]);
                // NSLog(@"Rect: %@", NSStringFromCGRect(rect));
            }
            
            [dic setObject:parameters forKey:@"params"];
        } 
         
        NSString *class = nil;
        
        if(_extensions && [_extensions count] > 0){
            for(NSString *extension in _extensions){
                
                Class classType = NSClassFromString(extension);
                
                if ([classType respondsToPrefix:uriType]) {
                    class = extension;
                    // NSLog(@"FPKOverlayManager - Found Extension %@ that supports %@", extension, uriType);
                }
            } 
        }
        
        if (class && ((load && [[parameters objectForKey:@"load"] boolValue]) || !load)){
            UIView *aView = [(UIView <FPKView> *)[NSClassFromString(class) alloc] initWithParams:dic andFrame:[documentViewController convertRect:rect toViewFromPage:page] from:self];
            retVal = aView;
            // [aView release];
        } else {
            NSLog(@"FPKOverlayManager - No Extension found that supports %@", uriType);
        }
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

- (void)setGlobalParametersFromAnnotation{
    NSString *uri;
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
    
    if(globalFound){
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
            
            if([parameters objectForKey:@"mode"]){
                int mode = 1;
                if([[parameters objectForKey:@"mode"] isEqualToString:@"Single"]){
                    mode = 1;
                } else  if([[parameters objectForKey:@"mode"] isEqualToString:@"Double"]){
                    mode = 2;
                } else if([[parameters objectForKey:@"mode"] isEqualToString:@"Overflow"]){
                    mode = 3;
                }
                [documentViewController setMode:mode];
            }
                
            if([parameters objectForKey:@"automode"]){
                int mode = 1;
                if([[parameters objectForKey:@"automode"] isEqualToString:@"None"]){
                    mode = 1;
                }else if([[parameters objectForKey:@"automode"] isEqualToString:@"Single"]){
                    mode = 2;
                } else  if([[parameters objectForKey:@"automode"] isEqualToString:@"Double"]){
                    mode = 3;
                } else if([[parameters objectForKey:@"automode"] isEqualToString:@"Overflow"]){
                    mode = 4;
                }
                [documentViewController setAutoMode:mode];        
            }
            if([parameters objectForKey:@"zoom"]){
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


-(NSUInteger)supportedOrientations:(NSArray *)orientations {
    NSUInteger v = 0;

    for(NSNumber * number in orientations) {
        v|=[number intValue];
    }
    return v;
}

@end
