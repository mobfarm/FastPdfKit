//
//  MainViewController.h
//  OffscreenRendererTest
//
//  Created by Nicolò Tosi on 4/16/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentViewControllerDelegate.h"
#import "MFDocumentOverlayDataSource.h"
#import "FPKOverlayViewDataSource.h"


@class MFDeferredContentLayerWrapper;
@class MFDocumentManager;
@class MFDocumentViewController;

@interface MFDocumentViewController : UIViewController <UIScrollViewDelegate> {
	
@private
	
	// Mode change callback delegate
	NSObject<MFDocumentViewControllerDelegate> *documentDelegate;
	
    NSMutableSet * overlayDataSources;
    NSMutableSet * overlayViewDataSources;
    
	// Resources.
	NSOperationQueue * operationQueue;
	
	// Document.
	MFDocumentManager * document;
	
	// Detail view
	
	// Previews
    MFDeferredContentLayerWrapper * current;        // Currently 'focused' layer wrapper.
    MFDeferredContentLayerWrapper * focused;
    int nextBias, prevBias, wrapperCount;           // Wrappers info.
	NSArray * wrappers;                             // Wrappers.
	
	// Internal status
	MFDocumentDirection currentDirection;
	BOOL autoMode;
	MFDocumentMode currentMode;
    MFDocumentAutoMode currentAutoMode;
    
	MFDocumentLead currentLead;
	NSUInteger currentPage;
	NSUInteger startingPage;
	//MFLegacyMode legacyMode;
	
	NSInteger currentPosition;              // Currently displayed position.
	NSUInteger currentOrientation;          // Current orientation as intended by the application.
	NSUInteger currentNumberOfPositions;    // Current number of "screens".
    
	NSInteger currentDetailPosition;        // Current position of the detail view.
    
	NSInteger maxNumberOfPages;
	
	CGSize currentSize;                     // Current size as intended by the application.
	
	BOOL pageControlUsed;
	BOOL pageButtonUsed;
	BOOL autoZoom;
	
	BOOL firstLoad;
	int loads;
	
    float defaultMaxZoomScale;
    CGFloat defaultPageFlipWidth;
    
	BOOL pageFlipOnEdgeTouchEnabled;
	BOOL zoomInOnDoubleTapEnabled;
	BOOL documentInteractionEnabled;
	BOOL overlayEnabled;
    
    BOOL showShadow;
    CGFloat padding;
	
    BOOL useTiledOverlayView;
}

@property (assign) NSObject<MFDocumentViewControllerDelegate> *documentDelegate;
@property (readonly) MFDocumentManager * document;

/**
 This property enable or disable the directional lock in the inner (document) scroll view. Default is NO.
 */
@property (nonatomic,readwrite,getter = isDirectionLockEnabled) BOOL directionalLockEnabled;

/**
 This property will enable an CATiledLayer version of the overlay view. This means overlay drawables will be drawn sharp, no matter the zoom of the scroll view.
 */
@property (readwrite) BOOL useTiledOverlayView;

/**
 Use this property to hide or show the horizontal scroller under the pages.
 */
@property (nonatomic,readwrite) BOOL showHorizontalScroller;

/**
 Set this flag to NO if you don't want the dropdown shadow under the pages. Default is YES.
 */
@property (nonatomic,readwrite) BOOL showShadow;

/**
 Set the amount of minimum padding between the pages and the screen edge. Default is 5.0. Values are clipped between 0 and 100.
 */
@property (nonatomic,readwrite) CGFloat padding;

/**
 Add and remove an Overlay Datasource for Drawables and Touchables.
 */
-(void)addOverlayDataSource:(id<MFDocumentOverlayDataSource>)ods;
-(void)removeOverlayDataSource:(id<MFDocumentOverlayDataSource>)ods;

/**
 Add and remove an Overlay View Datasource for overlay UIViews.
*/
-(void)addOverlayViewDataSource:(id<FPKOverlayViewDataSource>)ovds;
-(void)removeOverlayViewDataSource:(id<FPKOverlayViewDataSource>)ovds;

/**
 This method will provoke the redraw of the overlay. Overlay Datasources will be asked to provide drawables.
 */
-(void)reloadOverlay;

/**
 This will return the appropriate zoom level to perfectly zoom onto an annotation. If return 0, there's no available
 page data to compute the zoom yet.
 */
-(float)zoomLevelForAnnotationRect:(CGRect)rect ofPage:(NSUInteger)page;

/**
 Return the zoom scale of the page scroll view.
 */
-(float)zoomScale;

/**
 Return the offset of the page scroll view.
 */
-(CGPoint)zoomOffset;

/**
 This method will return the page number of the left page displayed. If the mode is single page, the left page number is the current page.
 */
-(NSUInteger)leftPage;

/**
 This method will return the page number of the right page displayed. If the mode is single, right page number is invalid.
 */
-(NSUInteger)rightPage;

/**
 Set the starting page of the document. It is valid only after initialization and before the view is
 displayed on the screen. Tipically you want to set this just after the init of the viewController.
 Default is 1.
 */
@property (nonatomic,readwrite) NSUInteger startingPage;

/**
 Enable the page flip when the user touch the edges of the screen.
 */
@property (assign,readwrite,getter=isPageFlipOnEdgeTouchEnabled) BOOL pageFlipOnEdgeTouchEnabled;

/**
 Set and get the percentage of the screen associated with the page flip on edge 
 touch action. Default value is 0.1, this mean that the 10% of the width of the 
 screen on either side will receive such events. Values are clipped between 0.0 
 and 0.5 to prevent overlap.
 */
-(void)setEdgeFlipWidth:(CGFloat)edgeFlipWidth;
-(CGFloat)edgeFlipWidth;

/**
 Default value to wich the current value will be reset to after each page change.
 Default is 0.1.
 */
@property (nonatomic,readwrite) CGFloat defaultEdgeFlipWidth;


/**
 Enabled the zoom in when the user double tap on the screen.
 */
@property (assign,readwrite,getter=isZoomInOnDoubleTapEnabled) BOOL zoomInOnDoubleTapEnabled;

@property (assign,readwrite,getter=isDocumentInteractionEnabled) BOOL documentInteractionEnabled;

/**
 Enable or disable the display of overlay item over the document. Default is disabled.
 */
@property (readwrite) BOOL overlayEnabled;

/**
 Enabled or force the legacy mode, or let the app choose to enable it or not 
 depending on the device. Default is disabled.
 */
// Private status variable about legacyMode...
@property (readwrite) BOOL legacyModeEnabled;


/**
 This is the default maximum magnification the pdf will zoom.
 */
@property (nonatomic,readwrite) float defaultMaxZoomScale;

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager;

/**
 This metod enable or disable the automatic mode switching upon rotation. If 
 enabled, the page mode will be automatically changed to single page in portrait 
 and side-by-side (double) on landscape. Setting the mode manually will disable 
 the automode.
 */
-(BOOL)automodeOnRotation;

/**
 Returns whether automode is enabled or not.
 */
-(void)setAutomodeOnRotation:(BOOL)automode;

/**
 Set how the pages are presented to the user. MFDocumentModeSingle present a 
 single page to the user, centered on the screen. MFDocumentModeDouble present 
 two pages side-by-side, as they would appear on a magazine or a books. This 
 will allow to preserve content split between the pages, for example a large 
 background image.
 */
-(void)setMode:(MFDocumentMode)newMode;


/**
 Set the mode to which the document will automatically switch to upon rotation. 
 Pass MFDocumentAutoModeX values and not MFDocumentModeX values, since it is not
 guaranteed to be the same.
 */
-(void)setAutoMode:(MFDocumentAutoMode)newAutoMode;

/**
 Returns the current mode used to display the document.
 */
-(MFDocumentMode)mode;

/**
 This metod will set the current page of the document and jump to the specified 
 page. Current page is used to determine bookmarks position. On side-by-side 
 (double) mode, it is usually the left-most page of the two.
 */
-(void)setPage:(NSUInteger)page;

/**
 This metod will set the current page of the document and jump to the specified 
 page, while trying to zoom in on the specified rect. Pass 0.0 as zoomLevel to 
 let the application try to calculate the appropriate zoom level to fit the 
 rectangle on screen. 
 */
-(void)setPage:(NSUInteger)page withZoomOfLevel:(float)zoomLevel onRect:(CGRect)rect;

/**
 Returns the current page of the document.
 */
-(NSUInteger)page;

/**
 This method set the lead used to show the pages in side-by-side (double) mode. 
 With MFDocumentLeadLeft, the cover will appear on the left side in side-by-side
 mode, whereas with MFDocumentLeadRight will appear on the right side. Use this 
 method to keep pairing between pages for books and magazines. Single page mode 
 is not affected by this setting.
 */
-(void)setLead:(MFDocumentLead)newLead;

/**
 Returns the current lead used when presenting the document.
 */
-(MFDocumentLead)lead;

/**
 This method is used to set the page reading direction: left to right or right 
 to left.
*/
-(void)setDirection:(MFDocumentDirection)newDirection;

/**
 Return the current direction used by the document.
 */
-(MFDocumentDirection)direction;

/**
 This method will turn on or off the autozoom feature. If on, the current zoom 
 level will be kept between pages, otherwise will be rest to 100% on page 
 change.
 */
-(void)setAutozoomOnPageChange:(BOOL)autozoom;

/**
 Returns whether the autozoom feature is enabled or not.
 */
-(BOOL)autozoomOnPageChange;

/**
 This method will begin an animated transition to the next page, if available. 
 */
-(void)moveToNextPage;

/**
 This method will begin an animated transition to the previous page, if 
 available.
 */
-(void)moveToPreviousPage;

/**
 Convert a point from MFDocumentViewController's view space to page space.
 */
-(CGPoint)convertPoint:(CGPoint)point fromViewtoPage:(NSUInteger)page;

/**
 Convert a point from page space to MFDocumentViewController's view space.
 */
-(CGPoint)convertPoint:(CGPoint)point toViewFromPage:(NSUInteger)page;

/**
 Convert a rect from MFDocumentViewController's view space to page space.
 */
-(CGRect)convertRect:(CGRect)rect fromViewToPage:(NSUInteger)page;


/**
 Convert a rect from page space to MFDocumentViewController's view space.
 */
-(CGRect)convertRect:(CGRect)rect toViewFromPage:(NSUInteger)page;

/**
 Convert a point from overlay space (the whole view that hold the both left and 
 right page, and that you can zoom in and scroll over) to page space.
 */
-(CGPoint)convertPoint:(CGPoint)point fromOverlayToPage:(NSUInteger)page;

/**
 Convert a point from page space to overlay space.
 */
-(CGPoint)convertPoint:(CGPoint)point toOverlayFromPage:(NSUInteger)page;

/**
 Convert a rect from overlay space to page space.
 */
-(CGRect)convertRect:(CGRect)rect fromOverlayToPage:(NSUInteger)page;

/**
 Convert a ract from page to overlay space.
 */
-(CGRect)convertRect:(CGRect)rect toOverlayFromPage:(NSUInteger)page;

/**
 Override in your subclass to toggle gesture recognizer on overlay views on and 
 off.
 */
-(BOOL)gesturesDisabled;

/**
 Set the paged scroll enabled or not. Useful to lock the user in the current 
 page during animations.
 */
-(void)setScrollEnabled:(BOOL)lock;

/**
 Set the maximum zoom scale for the pdf page.
 */
-(void)setMaximumZoomScale:(NSNumber *)scale;

@end
