//
//  FPKView.h
//  FPKShared
//

#import <Foundation/Foundation.h>
#import <FPKShared/FPKOverlayManager.h>

/**
 The FPKView protocol must be implemented on each Extension.
 It includes the methods that will be called by the FPKOverlayManager to instantiate and communicate with the Extension.
 */

@protocol FPKView <NSObject>

/**
 This method is called by the FPKOverlayManager if the Extension supports the requested prefix.
 You should return the **UIView** to be placed over the page. You can also return `nil` and perform some other operations like presenting a modal view on the 
 
 @param params This dictionary contains all the parameters extracted from the url

 * **prefix** the part in the url before `://`
 * **path** the part in the url after `://`
 * **params** another NSDictionary that contains the parsed parameters after the `://`
     - **resource** the part before `?`
     - ... custom parameters included in the annotation separated by `&`
 * **load** YES if the call for the view is made when the pdf page is going to be loaded, NO if the call is made when the user taps on the annotation area
 
 @param frame The annotation frame in pdf page coordinates. If the `padding` parameter is specified in the url, the frame is a CGRectInset of the real annotation frame. This feature is useful if the pdf has been created with Adobe InDesign that creates the annotation 2 pixel wider than the original object. Just specify in the url a param `?padding=2` and the frame will be set accordingly.
 
 @param manager The FPKOverlayManager that can be used to perform many operations like accessing the [MFDocumentViewController](http://doc.fastpdfkit.com/Classes/MFDocumentViewController.html) or the [MFDocumentManager](http://doc.fastpdfkit.com/Classes/MFDocumentManager.html).
 
 @return **UIView** that will be placed over the pdf page by the FPKOverlayManager.
 */

- (UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager;

/**
 Get the accepted prefixes by an Extension encapsulated in an **NSArray** of **NSString**. Obviously you can support even just one prefix.
 
 	[NSArray arrayWithObjects:@"map", nil];
 
 @return 
 */

+ (NSArray *)acceptedPrefixes;

/**
You should implement this method to return a BOOL value only on supported prefixes.
 
 @param prefix The prefix in the form `@"map"`.
 @return YES or NO if the prefix is support by the Extension.
 */

+ (BOOL)respondsToPrefix:(NSString *)prefix;

/**
 The frame of the view can change when the pdf mode change and the device is rotated.
 The original frame is stored to perform the conversion on the fly when needed.
 
 @return rect The original frame of the **UIView**.
 */

- (CGRect)rect;

/**
 Set the original frame. More info on rect.
 
 @param rect The original frame.
 */

- (void)setRect:(CGRect)rect;

@optional

/**
 The view will be notified if it will be removed from the screen. 
 You can decide to perform some operations like stopping timers and release objects.
 
 @param manager The manager is the sender. It could be useful.
 */

- (void)willRemoveOverlayView:(FPKOverlayManager *)manager;
@end
