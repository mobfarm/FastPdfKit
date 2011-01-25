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

@class MFDeferredContentLayerWrapper;
@class MFDocumentManager;
@class MFDetailViewController;
@class MFDocumentViewController;

@interface MFDocumentViewController : UIViewController <UIScrollViewDelegate> {
	
@private
	
	// Mode change callback delegate
	NSObject<MFDocumentViewControllerDelegate> *documentDelegate;
	NSObject<MFDocumentOverlayDataSource> *overlayDataSource;
	
	// Resources.
	NSOperationQueue * operationQueue;
	
	// Document.
	MFDocumentManager * document;
	
	// Detail view
	UIScrollView * pagedScrollView;
	MFDetailViewController * detailViewController;
	UIView * detailView;
	
	// Previews
	MFDeferredContentLayerWrapper * previous;
	MFDeferredContentLayerWrapper * current;
	MFDeferredContentLayerWrapper * next;
	MFDeferredContentLayerWrapper * former;
	
	NSArray * wrappers;
	
	// Internal status
	MFDocumentDirection currentDirection;
	BOOL autoMode;
	MFDocumentMode currentMode;
	MFDocumentLead currentLead;
	NSUInteger currentPage;
	NSUInteger startingPage;
	//MFLegacyMode legacyMode;
	
	NSInteger currentPosition;
	NSUInteger currentOrientation;
	NSUInteger currentNumberOfPositions;
	
	NSInteger maxNumberOfPages;
	
	CGSize currentSize;
	
	BOOL pageControlUsed;
	BOOL pageButtonUsed;
	BOOL autoZoom;
	
	BOOL firstLoad;
	int loads;
	
	BOOL pageFlipOnEdgeTouchEnabled;
	BOOL zoomInOnDoubleTapEnabled;
	BOOL documentInteractionEnabled;
	BOOL overlayEnabled;
	
}

@property (assign) NSObject<MFDocumentOverlayDataSource> *overlayDataSource;
@property (assign) NSObject<MFDocumentViewControllerDelegate> *documentDelegate;
@property (readonly) MFDocumentManager * document;

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
 Enabled the zoom in when the user double tap on the screen.
 */
@property (assign,readwrite,getter=isZoomInOnDoubleTapEnabled) BOOL zoomInOnDoubleTapEnabled;

@property (assign,readwrite,getter=isDocumentInteractionEnabled) BOOL documentInteractionEnabled;

/**
 Enable or disable the display of overlay item over the document. Default is disabled.
 */
@property (readwrite) BOOL overlayEnabled;

/**
 Enabled or force the legacy mode, or let the app choose to enable it or not depending on the device.
 Default is disabled.
 */
// Private status variable about legacyMode...
@property (readwrite) BOOL legacyModeEnabled;

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager;

/**
 This metod enable or disable the automatic mode switching upon rotation. If enabled, the page mode will be automatically
 changed to single page in portrait and side-by-side (double) on landscape. Setting the mode manually will disable the automode.
 */
-(BOOL)automodeOnRotation;

/**
 Returns whether automode is enabled or not.
 */
-(void)setAutomodeOnRotation:(BOOL)automode;

/**
 Set how the pages are presented to the user. MFDocumentModeSingle present a single page to the user, centered on the screen. MFDocumentModeDouble present two pages side-by-side, as they would appear on a magazine or a books. This will allow to preserve content split between the pages, for example a large background image.
 */
-(void)setMode:(MFDocumentMode)newMode;

/**
 Returns the current mode used to display the document.
 */
-(MFDocumentMode)mode;

/**
 This metod will set the current page of the document and jump to the specified page. Current page is used to determine bookmarks position. On side-by-side (double) mode, it is usually the left-most page of the two.
 */
-(void)setPage:(NSUInteger)page;

/**
 This metod will set the current page of the document and jump to the specified page, while trying to zoom in on the specified rect */
-(void)setPage:(NSUInteger)page withZoomOfLevel:(float)zoomLevel onRect:(CGRect)rect;

/**
 Returns the current page of the document.
 */
-(NSUInteger)page;

/**
 This method will set the lead used to present the pages in side-by-side (double) mode. With MFDocumentLeadLeft, the
 cover will appear on the left side in side-by-side mode, whereas with MFDocumentLeadRight will appear on the right side. Use this method to keep pairing between pages for books and magazines. Single page mode is not affected by this setting.
 */
-(void)setLead:(MFDocumentLead)newLead;

/**
 Returns the current lead used when presenting the document.
 */
-(MFDocumentLead)lead;

/**
This method is used to set the page reading direction: left to right or right to left.
*/
-(void)setDirection:(MFDocumentDirection)newDirection;

/**
 Return the current direction used by the document.
 */
-(MFDocumentDirection)direction;

/**
 This method will turn on or off the autozoom feature. If on, the current zoom level will be kept between pages,
 otherwise will be rest to 100% on page change.
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
 This method will begin an animated transition to the previous page, if available.
 */
-(void)moveToPreviousPage;

/**
 Call this method rightly after dismissing this MFDocumentViewController instance. It will release all the resources
 and stop the background threads. Once this method has been called, the MFDocumentViewController instance cannot be
 considered valid anymore and should be released.
 */
-(void)cleanUp;

@end
