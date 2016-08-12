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
#import "FPKThumbnailDataStore.h"
#import "FPKSharedSettings.h"

@class MFDeferredContentLayerWrapper;
@class MFDocumentManager;
@class MFDocumentViewController;

@protocol FPKThumbnailView

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) UIImage * image;

@end

extern NSString * const FPKConfigurationDictionaryConfigKey;
extern NSString * const FPKConfigurationDictionaryPageKey;
extern NSString * const FPKConfigurationDictionaryOrientationKey;
extern NSString * const FPKConfigurationDictionaryModeKey;
extern NSString * const FPKConfigurationDictionaryPaddingKey;
extern NSString * const FPKConfigurationDictionaryEdgeFlipKey;
extern NSString * const FPKConfigurationDictionaryAlternateEdgeFlipKey;

static const NSUInteger FPKEmbeddedAnnotationsVideo = 1;
static const NSUInteger FPKEmbeddedAnnotationsAudio = 2;
static const NSUInteger FPKEmbeddedAnnotationsWeb = 4;
static const NSUInteger FPKEmbeddedAnnotationsAll = FPKEmbeddedAnnotationsAudio|FPKEmbeddedAnnotationsVideo|FPKEmbeddedAnnotationsWeb;

@interface MFDocumentViewController : UIViewController <UIScrollViewDelegate>

/**
 * Other delegates.
 */
@property (nonatomic, readonly) NSPointerArray * delegates;

/** 
 * Supported orientations that will be returned from -supportedInterfaceOrientations
 */
@property (nonatomic,readwrite) NSUInteger supportedOrientations;

/**
 * Can enable/disabled embedded annotations by type.
 */
@property (nonatomic, readwrite) NSUInteger supportedEmbeddedAnnotations;


@property (nonatomic,strong)id<FPKThumbnailDataStore> thumbnailDataStore;

/**
 * This is the configuration dictionary you can pass on.
 */
@property (nonatomic, copy) NSDictionary * configurationDictionary;

/**
 This property let you add the main DocumentViewControllerDelegate.
 */
@property (weak) id<MFDocumentViewControllerDelegate> documentDelegate;

/**
 If you need to register objects as DocumentViewControllerDelegate you can add them using this method.
 */

-(void)addDocumentDelegate:(NSObject<MFDocumentViewControllerDelegate> *)delegate;

/**
 If you have more than one DocumentViewControllerDelegate you can remove any of them with this method.
 */

-(void)removeDocumentDelegate:(NSObject<MFDocumentViewControllerDelegate> *)delegate;

/**
 Value representing supported orientation by this view controller. You can set
 multiple values by OR-ing them together.
 
 For example:
 
 supportedOrientation = FPKSupportedOrientationPortrait | FPKSupportedOrientationPortaitUpsideDown
 
 */
@property (nonatomic,readwrite) FPKSupportedOrientation supportedOrientation;

/**
 * The DocumentManager associated with this DocumentViewController.
 */
@property (nonatomic, readonly) MFDocumentManager * document;

/**
 This property enable or disable the directional lock in the inner (document)
 scroll view. 
 Default is NO.
 */
@property (nonatomic,readwrite,getter = isDirectionLockEnabled) BOOL directionalLockEnabled;

/**
 This property will enable an CATiledLayer version of the overlay view. This
 means overlay drawables will be drawn sharp, no matter the zoom of the scroll
 view.
 */
@property (readwrite) BOOL useTiledOverlayView;

/**
 Use this property to hide or show the horizontal scroller under the pages.
 */
@property (nonatomic,readwrite) BOOL showHorizontalScroller;

/**
 Set this flag to NO if you don't want the dropdown shadow under the pages.
 Default is YES.
 */
@property (nonatomic,readwrite) BOOL showShadow;

/**
 Set the amount of minimum padding between the pages and the screen edge.
 Default is 5.0. Values are clipped between 0 and 100.
 */
@property (nonatomic,readwrite) CGFloat padding;

/**
 * Add an OverlayDataSource. 
 */
-(void)addOverlayDataSource:(id<MFDocumentOverlayDataSource>)ovds;

/**
 * Remove an OverlayDataSource.
 */
-(void)removeOverlayDataSource:(id<MFDocumentOverlayDataSource>)ods;

/**
 Enable or disable FPK Annotations parsing at page load. Set it to NO if you
 don't use FPK Annotations and experience freezing while scrolling the pages.
 Default is YES (enabled).
 */
@property (nonatomic,readwrite) BOOL fpkAnnotationsEnabled;

-(id<FPKOverlayViewDataSource>)overlayViewDataSourceWithName:(NSString *)name;

/**
 Add an OverlayViewDataSource with a specific name.
*/
-(void)addOverlayViewDataSource:(id<FPKOverlayViewDataSource>)ovds name:(NSString *)name;

/**
 * Add an OverlayViewDataSources. The returned name is random generated and can 
 * be used to retrieve it later on.
 */
-(NSString *)addOverlayViewDataSource:(id<FPKOverlayViewDataSource>)ovds;

/**
 Remove an OverlayViewDatasource.
 */
-(void)removeOverlayViewDataSource:(id<FPKOverlayViewDataSource>)ovds;

/**
 * Remove an OverlayViewDataSource with a specific name.
 */
-(id<FPKOverlayViewDataSource>)removeOverlayViewDataSourceWithName:(NSString *)name;

/**
 This method will provoke the redraw of the overlay. Overlay Datasources will be
 asked to provide drawables.
 */
-(void)reloadOverlay;

/**
 This will return the appropriate zoom level to perfectly zoom onto an annotation.
 If return 0, there's no available page data to compute the zoom yet.
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
 This method will return the page number of the left page displayed. If the mode
 is single page, the left page number is the current page.
 */
-(NSUInteger)leftPage;

/**
 This method will return the page number of the right page displayed. If the mode
 is single, right page number is invalid.
 */
-(NSUInteger)rightPage;

/**
 Document identifier, to allow discriminate between different documents.
 */
@property (nonatomic, copy) NSString * documentId;

/**
 Set the starting page of the document. It is valid only after initialization
 and before the view is displayed on the screen. Tipically you want to set this 
 just after the init of the viewController.
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
@property (nonatomic,readwrite) CGFloat edgeFlipWidth;

/**
 Enabled the zoom in when the user double tap on the screen.
 */
@property (nonatomic,readwrite,getter=isZoomInOnDoubleTapEnabled) BOOL zoomInOnDoubleTapEnabled;

/**
 Enabled the document interaction.
 */
@property (nonatomic,readwrite,getter=isDocumentInteractionEnabled) BOOL documentInteractionEnabled;

/**
 Enable or disable the display of overlay item over the document.
 Default is disabled.
 */
@property (nonatomic,readwrite,getter = isOverlayEnabled) BOOL overlayEnabled;

/**
 Enabled or force the legacy mode, or let the app choose to enable it or not 
 depending on the device. Default is disabled.
 */
@property (nonatomic,readwrite,getter = isLegacyModeEnabled) BOOL legacyModeEnabled;

/**
 This is the default maximum magnification the pdf will zoom.
 */
@property (nonatomic,readwrite) float defaultMaxZoomScale;

/**
 Call this method to start working with the pdf.
 */

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
 Call this method rightly after dismissing this MFDocumentViewController 
 instance. It will release all the resources and stop the background threads. 
 Once this method has been called, the MFDocumentViewController instance cannot 
 be considered valid anymore and should be released.
 */
-(void)cleanUp;

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


/**
 Hide the bottom thumbnail scroll view.
 */
-(void)hideThumbnails;

/**
 Show the bottom thumbnail scroll view.
 */
-(void)showThumbnails;

/**
 Set the max number of preview images to use at any time. Call this before 
 presenting the MFDocumentViewController subclass. Default is 4, sweet spot is
 3-4 and you should not exceed this number unless your target device are iPhone4 
 iPad2 or newer devices and/or your PDF are scarce of images.
 */
@property (nonatomic,readwrite) NSUInteger previewsCount;

/**
 Access the inner paged scroll view.
 */
@property (strong, readonly) UIScrollView * pagedScrollView;

/**
 * Height of the thumbnail in the scrollview. Default is 80.
 */
@property (nonatomic, readwrite) CGFloat thumbnailHeight;

/**
 * Background color of the thumbnail view.
 */
@property (nonatomic, strong) UIColor * thumbnailBackgroundColor;

/**
 * Enabled or disable the page slider item in the toolbar.
 */
@property (nonatomic, readwrite, getter = isPageSliderEnabled) BOOL pageSliderEnabled;

/**
 * Enable or disable the thumbnail slider item in the toolbar. The page slider will
 * take the precedence over this one.
 */
@property (nonatomic, readwrite, getter = isThumbnailSliderEnabled) BOOL thumbnailSliderEnabled;

/**
 * Enable or disable background thumbnail rendering, even when the thumbnail slider is not visible.
 * Default is YES.
 */
@property (nonatomic, readwrite) BOOL backgroundThumbnailRenderingEnabled;

/**
 Key to encrypt cached images. If left to the nil default value, image will not 
 be encrypted.
 Keep in mind that, for now, you have to manually delete the thumbnail cache if
 you change associated with a certain documentId (unlikely you'll ever need to
 do that).
 */
@property (copy, nonatomic) NSString * cacheEncryptionKey;

/**
 This path will be used to cache the thumbnails images. If left undefined by the
 user, the kit will generate one depending on the documentId first, then a 
 shared one.
 */
@property (copy, atomic, readwrite) NSString * thumbnailsCachePath;

/**
 This path will be used to cache the page images. If left undefined by the
 user, the kit will generate one depending on the documentId first, then a
 shared one.
 */
@property (copy, atomic, readwrite) NSString * imagesCachePath;

/**
 Visited pages system.
 */

/**
 * This will move to the next visited page, if any.
 */
-(void)nextVisitedPage;

/**
 * This will go back to the previously visited page, if any.
 */
-(void)previousVisitedPage;

/**
 * Amount of forward visited pages. It will be greather than 0
 * only when the user as jumped back.
 */
-(NSInteger)nextVisitedPagesCount;

/**
 * Amount of previously visited pages. It is usually greather than 0,
 * unless the user has already jumped to the bottom of the stack.
 */
-(NSInteger)previousVisitedPagesCount;

/**
 * This will set the image cache scale to use. You can choose between 
 * FPKImageCacheStandard, FPKImageCacheTrueToPixels and FPKImageCacheAnamorphic.
 *
 * Default si FPKImageCacheTrueToPixels.
 */
-(void)setImageCacheScaling:(FPKImageCacheScale)scale;
-(FPKImageCacheScale)imageCacheScaling;

/**
 * This set if image cache will use JPEG or the default PNG compression.
 *
 * Default is YES (it will use JPEG).
 */
-(void)setUseJPEG:(BOOL)useJPEGOrNot;
-(BOOL)useJPEG;

/**
 * This set the compressione level for the JPEG image compression, if JPEG
 * image compression is used (greather the value lesser the compression). 
 * Level 0.75 is a good compromise between image quality, speed and size.
 *
 * Default is 0.75.
 */
-(void)setImageCacheCompression:(CGFloat)level;
-(CGFloat)imageCacheCompression;

/**
 * This will set if high detailed tiles will be shown at 1x zoom factor. You 
 * can choose between FPKForceTilesNever, FPKForceTilesAlways,
 * FPKForceTilesOverflowOnly.
 *
 * Default is FPKForceTilesOverflowOnly.
 */
-(void)setForceTiles:(FPKForceTiles)force;
-(FPKForceTiles)forceTiles;

/**
 * This wil set the oversize of the image cache. Image size will be calculated
 * taking screen size and page cropbox size into account to produce and image 
 * that will fit the screen. Oversize is a factor of how much the final image 
 * will be bigger than the optimal. Oversize of 0.05 will generate an image 
 * with roughly 10% more pixel than the screen (1.05 * 1.05 = 1.1).
 *
 * Default is 0.05.
 */
-(void)setImageCacheOversize:(CGFloat)oversize;
-(CGFloat)imageCacheOversize;

/**
 * This flag will force the controller to delete the cache at launch. The flag
 * will be reset to NO after clean up.
 */
@property (readwrite, nonatomic) BOOL cleanUpCacheAtLaunch;

/**
 * This will tell the controller to use the navigation controller's toolbar
 * instead of its own. Toolbar items will be replaced with document controller's
 * own items. Default is NO. Since navigation toolbar is usually 44 points high, 
 * it would be better to set pageSliderEnabled to YES and thumbnailSliderEnabled
 * to NO rather to try fit the thumbnails into the navigation toolbar.
 */
@property (readwrite, nonatomic) BOOL useNavigationControllerToolbar;

/**
 * Height of the toolbar. Set to force toolbar height, otherwise 44.0 will be
 * used if page slider is enabled, 88.0 if thumbnails are enabled. 
 * Default is -1.0.
 */
@property (readwrite, nonatomic) CGFloat thumbnailBarHeight;

/**
 * Toolbar. It will return nil if useNavigationToolbar has been set to YES.
 */
@property (strong, nonatomic) UIToolbar * toolbar;

/**
 * Invoked when the user cancel the page slider movement by touching up outside
 * the slider. Call super if you want the embedded pageSliderLabel to reset
 * to the actual page number.
 * @param slider The slider.
 */
-(void)pageSliderCancel:(UISlider *)slider;

/**
 * Invoked when the slider slided. This is used to update the pageSliderLabel to
 * show the page that will be loaded when the slider is released. When you override
 * this method, remember to call super.
 * @param slider The slider.
 */
-(void)pageSliderSlided:(UISlider *)slider;

/**
 * Invoked when the user stop dragging the slider and release it by touching up 
 * inside the slider bounds. When you override this, call super if you want the 
 * current displayed page to be updated accordingly.
 * @param slider The slider.
 */
-(void)pageSliderStopped:(UISlider *)slider;

/**
 * Return the number of the page at the current view location.
 * @param location A location in the controller's view.
 * @return The number of the page at the location.
 */
-(NSUInteger)pageAtLocation:(CGPoint)location;

/**
 * Settings object.
 */
@property (nonatomic, strong) FPKSharedSettings * settings;

@end
