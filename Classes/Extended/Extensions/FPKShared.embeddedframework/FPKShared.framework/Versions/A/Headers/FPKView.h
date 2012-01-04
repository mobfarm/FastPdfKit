//
//  FPKView.h
//  FastPdfKit Extension
//

#import <Foundation/Foundation.h>
#import <FPKShared/FPKOverlayManager.h>

/**
 @bug Complete the description and remove the icon
 
 <img src="../docs/fpk-icon.png" />
 */

@protocol FPKView <NSObject>
/**
 This method is invocated by the FPKOverlayManager if the Extension supports the requested prefix.
 You should return the **UIView** to be placed over the page. You can also return `nil` and perform some other operations like presenting a modal view on the 
 
 @param params This dictionary contains all the parameters extracted from the url

 * **prefix** the part in the url before `://`
 * **path** the part in the url after `://`
 * **params** another NSDictionary that contains the parsed paramenters after the `://`
     - **resource** the part before `?`
     - ... custom parameters included in the annotation separated by `&`
 * **load** YES if the call for the view is made when the pdf page is going to be loaded, NO if the call is made when the user taps on the annotation area
 
 @param frame The annotation frame in pdf page coordinates. If the `padding` parameter is specified in the url, the frame is a CGRectInset of the real annotation frame. This feature is useful if the pdf has been created with Adobe InDesign that creates the annotation 2 pixel wider than the original object. Just specify in the url a param `?padding=2` and the frame will be setted accordingly.
 
 @param manager The FPKOverlayManager that can be used to perform many operations like accessing the [MFDocumentViewController](http://doc.fastpdfkit.com/Classes/MFDocumentViewController.html) or the [MFDocumentManager](http://doc.fastpdfkit.com/Classes/MFDocumentManager.html).
 
 @return **UIView** that will be placed over the pdf page by the FPKOverlayManager.
 */

- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;

/**
 @bug complete the description
 
 
 @return
 */

+ (NSArray *)acceptedPrefixes;

/**
 @bug complete the description
 
 @param prefix
 @return 
 */

+ (BOOL)respondsToPrefix:(NSString *)prefix;

/**
 @bug complete the description
 
 
 @return rect 
 */

- (CGRect)rect;

/**
 @bug complete the description
 
 
 @param rect 
 */

- (void)setRect:(CGRect)rect;

@optional

/**
 @bug complete the description
 
 @param manager
 */

- (void)willRemoveOverlayView:(FPKOverlayManager *)manager;
@end
