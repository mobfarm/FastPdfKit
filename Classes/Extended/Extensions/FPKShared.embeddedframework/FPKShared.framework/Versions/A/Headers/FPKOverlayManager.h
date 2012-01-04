//
//  FPKOverlayManager.h
//  FastPdfKit Extension
//

#import <FastPdfKit/MFDocumentViewController.h>

/**
 @bug complete the description
 */


@protocol FPKOverlayManagerDelegate <NSObject>
@optional

/**
 @bug complete the description
 @param disabled
 */

- (void)setGesturesDisabled:(BOOL)disabled;
@end

/**
 @bug complete the description
 */


@interface FPKOverlayManager : NSObject <FPKOverlayViewDataSource, MFDocumentViewControllerDelegate>{
    NSMutableArray *overlays;
    NSArray *extensions;
    MFDocumentViewController <FPKOverlayManagerDelegate> * documentViewController;
}

/**
 You need to assign to the FPKOverlayManager the MFDocumentViewController in order to access its MFDocumentManager and the coordinate conversion methods.
 */

@property(nonatomic, assign) MFDocumentViewController <FPKOverlayManagerDelegate> * documentViewController;

/**
 Method to set the supported Extensions.
 
 @param ext An array of strings that should contain every supported annotation like **FPKMap**, **FPKYouTube**, ecc.
 
    [anOverlayManager setExtensions:[[NSArray alloc] initWithObjects:@"FPKMap", @"FPKYouTube", nil]];
 
 */
- (void)setExtensions:(NSArray *)ext;

/**
 You can init this object passing the extensions as array, or use the standard init method and then set the extensions manually.
 
 @param ext An array of strings that should contain every supported annotation like **FPKMap**, **FPKYouTube**, ecc.
 
    [[anOverlayManager alloc] initWithExtensions:[[NSArray alloc] initWithObjects:@"FPKMap", @"FPKYouTube", nil]];
 
 */
- (FPKOverlayManager *)initWithExtensions:(NSArray *)ext;

/**
 Method that is called to transform a pdf annotation into a `UIView` that will be added over the pdf page. The method itself checks if there is an Extension that support the url *prefix* and pass every parameter to the Extension.
 
 @param load If the method is called when the pdf page is going to be drawn the value should be YES, otherwise NO (usually when a user tapped on the page over the annotation rect).
 
 @param rect The CGRect in page coordinates of the annotation as extracted from the pdf tree.
 
 @param uri The uri contained in the annotation hyperlink in the form *prefix://path?param1&param2*.
 
 @param page The pdf page that is requesting the view for the annotation.
 
 @return The `UIView` that has been created by the right Extension and will be added over the page.
 */
- (UIView *)showAnnotationForOverlay:(BOOL)load withRect:(CGRect)rect andUri:(NSString *)uri onPage:(NSUInteger)page;

/** 
 @bug complete description
 */
-(UIView *)overlayViewWithTag:(int)tag;
@end


