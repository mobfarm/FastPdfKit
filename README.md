# FastPdfKit

----

This repository contains the FastPdfKit iOS library with some sample projects.
 
FastPdfKit is a library that let you show pdf documents in iOS applications bypassing all performances and missing features problems related to QuickLook.

Side scrolling, search with highlighted results, preview and thumbnails, text extraction, overlay views, embedded multimedia, optimization for every device, single and double page are just some of countless features included in FastPdfKit.

For more information, see the [FastPdfKit website](http://fastpdfkit.com) and the [Support website](http://support.fastpdfkit.com).

![Interface iPad](http://reader.fastpdfkit.com/readme/interface1s.png)
![Search iPad](http://reader.fastpdfkit.com/readme/search1s.png)

![Interface iPhone](http://reader.fastpdfkit.com/readme/2pages2s.png)
![Search iPhone](http://reader.fastpdfkit.com/readme/search4s.png)

## Features

### Reading

-   Side page sliding
-   [Single
    page](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setMode:)
-   [Double
    page](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setMode:)
-   Landscape/Portrait with
    [automode](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setAutomodeOnRotation:)
-   Extreme speed
-   Native pdf thumbnails extraction
-   [High definition
    thumbnails](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/createImageForThumbnailOfPageNumber:ofSize:andScale:)
    generation
-   [Page
    preload](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/legacyModeEnabled)
-   [Double
    tap](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/zoomInOnDoubleTapEnabled)
    and pinch to zoom
-   [Tap on the
    side](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/pageFlipOnEdgeTouchEnabled)
    to go forward or backward
-   [Zoom Lock with
    animation](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setAutozoomOnPageChange:)
-   [Control zoom
    level](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/zoomScale)
    for each page
-   [Quick page change bar with
    thumbnails](https://github.com/mobfarm/FastPdfKit/tree/master/Classes/Reader/ThumbnailSlider)
    and page numbers
-   [Bookmarks](https://github.com/mobfarm/FastPdfKit/blob/devel/Classes/Reader/Bookmarks/BookmarkViewController.h)
-   [Outline - Table Of
    Contents](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/outline)
    [personalizzabili](http://doc.fastpdfkit.com//Classes/MFPDFOutlineEntry.html)
-   [Left to Right and Right to
    left](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setDirection:)
    reading
-   [Switch left to right
    pages](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setLead:)
-   [Shadown on pages
    customizable](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/showShadow)
-   [Padding
    settable](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/showShadow)
-   [Side areas to go forward and backward with custom
    dimension](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setEdgeFlipWidth:)
-   [Directional
    lock](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/directionalLockEnabled)
-   [Custom pdf
    background](http://support.fastpdfkit.com/kb/faq-and-tips/can-i-change-the-mfdocumentviewcontrollers-background)
-   [Precise
    zoom](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html)
    on annotations and page parts
-   [Auto
    mode](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setAutomodeOnRotation:):
    single page in portrait and double page in landscape
-   [Goto page and zoom on
    rect](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setPage:withZoomOfLevel:onRect:)

### Multimedia and Annotations

-   [Custom annotation
    support](http://support.fastpdfkit.com/kb/faq-and-tips/can-i-use-custom-annotations-to-embed-something)
-   [Multimedia documents overlayed over the
    pages](http://support.fastpdfkit.com/kb/faq-and-tips/multimedia-protocols-and-url)
-   YouTube videos
-   Local videos
-   Streaming videos
-   Offline sound reproduction
-   Music streming
-   Web pages and html5 in overlay
-   Custo modal multimedia views
-   No limits
-   [You can customize
    protocols](http://support.fastpdfkit.com/kb/faq-and-tips/can-i-use-custom-annotations-to-embed-something)
-   [Touchable overlay
    views](http://support.fastpdfkit.com/kb/faq-and-tips/drawables-and-touchables)
-   [Draw over pdf
    layers](http://support.fastpdfkit.com/kb/faq-and-tips/drawables-and-touchables)
    in page coordinates
-   [Overlayed
    UIViews](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/addOverlayViewDataSource:)
-   [Embedded local audio
    Player](http://doc.fastpdfkit.com//Protocols/MFAudioProvider.html)with
    [pause/play and
    volume](http://doc.fastpdfkit.com//Protocols/MFAudioPlayerViewProtocol.html)
-   [Embedded remote audio
    player](http://doc.fastpdfkit.com//Protocols/MFAudioProvider.html)
-   Embedded movie player with fullscreen option
-   Embedded fullscreen browser
-   [Overlay on Tiled Layer on
    demand](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/useTiledOverlayView)
-   [Tap](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html#//api/name/documentViewController:didReceiveTapOnAnnotationRect:withUri:onPage:)
    and [double
    tap](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html#//api/name/documentViewController:didReceiveDoubleTapOnAnnotationRect:withUri:onPage:)
    on annotations
-   [Video](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html#//api/name/documentViewController:doesHaveToAutoplayVideo:)
    and
    [sound](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html#//api/name/documentViewController:doesHaveToAutoplayAudio:)
    with autoplay
-   [Coordinates
    conversions](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/setPage:withZoomOfLevel:onRect:)

### Kiosk

-   [Sample interactive
    kiosk](https://github.com/mobfarm/FastPdfKit/tree/master/Classes/KioskApp)
-   [xml document to get new
    issues](https://github.com/mobfarm/FastPdfKit/blob/devel/Resources/kiosk_list.xml)
-   [Background
    download](http://developer.apple.com/library/iOS/#documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html)
-   [Ready in 3
    minutes](http://www.youtube.com/mobfarm#p/u/1/Oj6_8zRfI4k)
-   Download pdf document or zipped archives (.fpk)
-   Cover displayed
-   Fully customizable

### Text

-   [Text search and result
    highlight](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/searchResultOnPage:forSearchTerms:withProfile:)
-   [List search
    results](http://doc.fastpdfkit.com//Classes/MFTextItem.html)
-   [Look through results and go to the following
    one](https://github.com/mobfarm/FastPdfKit/tree/master/Classes/Reader/TextSearch)
-   [Text
    extraction](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/wholeTextForPage:withProfile:)
-   [Link between
    pages](http://support.fastpdfkit.com/kb/faq-and-tips/are-internal-url-supported)
-   [Support for link with
    urls](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html#//api/name/documentViewController:didReceiveURIRequest:)
-   [Support for link to external documents]()
-   Search with [word
    selection](http://doc.fastpdfkit.com//Classes/MFTextItem.html) and
    results skimming
-   [Zoom on
    results](http://support.fastpdfkit.com/kb/faq-and-tips/change-zoom-level-for-search-results)
-   [Multibyte charachters
    supported](http://en.wikipedia.org/wiki/Variable-width_encoding)
-   [Customizable
    search](https://github.com/mobfarm/FastPdfKit/tree/master/Classes/Reader/TextSearch)
    and
    [profiling](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/defaultProfile)

### Miscellanous

-   True PDF
-   [Free version](http://fastpdfkit.com/plans) for low budget projects with complete
    features
-   Fully multitouch
-   Large document support
-   [Retina
    Display](http://www.apple.com/iphone/features/retina-display.html)
    optimization
-   [Customizable
    interface](https://github.com/mobfarm/FastPdfKit/tree/master/Classes/Reader)
-   Support for [encrypted
    documents](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/tryUnlockWithPassword:)
-   Works on every iOS version since 3.2
-   Universal Binary
-   [Destination named
    urls](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/pageNumberForDestinationNamed:)
-   [Get cropbox and
    rotation](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/getCropbox:andRotation:forPageNumber:)
    for each page
-   [Compatibility mode for older
    devices](http://doc.fastpdfkit.com//Classes/MFDocumentViewController.html#//api/name/legacyModeEnabled)
-   [Three sample projects with highly commented
    code](https://github.com/mobfarm/FastPdfKit)
-   [Ready to use interface for immediate deploy with framework and
    library](http://www.youtube.com/mobfarm#p/u/1/Oj6_8zRfI4k)
-   [Complete
    documentation](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html)
-   [View pdf in
    subview](http://support.fastpdfkit.com/kb/faq-and-tips/pdf-as-subview)
    or in standard [views
    stack](http://www.youtube.com/mobfarm#p/u/1/Oj6_8zRfI4k)
-   Every feature optimized for [iPhone](http://www.apple.com/iphone/)
-   Every feature optimized for [iPad](http://www.apple.com/ipad/)
-   Library and examples source code available on
    [github](https://github.com/mobfarm/fastpdfkit)
-   Works with [Xcode](http://itunes.apple.com/app/id448457090?mt=12)
    3.2.6 and 4.x
-   Open PDF documents[from file](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/initWithFileUrl:)
    and
    from[NSDataProvider](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/initWithDataProvider:)
-   Smart
    [caching](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/emptyCache)
    pdf
-   Open [multiple pdf documents at
    once](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html)
-   Complete [delegate
    feedbacks](http://doc.fastpdfkit.com//Protocols/MFDocumentViewControllerDelegate.html)
-   Support for
    [UIGestureRecogniser](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIGestureRecognizer_Class/Reference/Reference.html)
-   Multi-Threading is used to achieve maximum speed
-   [Automatic and optimized caching
    system](http://doc.fastpdfkit.com//Classes/MFDocumentManager.html#//api/name/emptyCache)

### Opportunities

-   Become a [Reseller](http://fastpdfkit.com/reseller)
-   How [fits your needs](http://fastpdfkit.com/target)
-   Free for selected [no-profit organizations](http://fastpdfkit.com/target#4)
-   [100+ applications](http://fastpdfkit.com/partners) already developed in [20 countries](http://fastpdfkit.com/reseller)
-   Tens of [Partners](http://fastpdfkit.com/partners)

## Targets

In the Xcode project you'll find some targets

* **FastPdfKit**: framework with everything needed to add just the reader to your app;
* **FPKKioskApp**: a Kiosk project with document download and ready to use reader class;
* **FPKSimpleApp**: a basic project with custom reader;
* **FPKReaderLib**: a static library with the `ReaderViewController`and its dependencies;
* **FPKKioskLib**: a static library with the kiosk classes;
* **FPKioskBundle**: bundle of resources for needed for the kiosk;
* **FPReaderBundle**: bundle of resources for needed by the `ReaderViewController`.

In **FastPdfKit.framework** and **FPKReaderLib** the `libFastPdfKit.a`that contains the compiled core rendering engine.

All the other classes are public and can be customized or subclassed at will.

Every target can be compiled and recompiled for your needs.

## Usage guide

This guide is also available as [screencast number 4](http://fastpdfkit.com/tutorials).

* Clone the repository from [github](https://github.com/mobfarm/fastpdfkit) or just grab the compressed archive;
* Open your existing project in Xcode;
* Open the downloaded folder in the Finder and locate **FastPdfKit.embeddedframework**;
* Drag the framework on the Xcode workspace;
* Inherit the project options: select the Project an from info tab and configurations line choose **FastPdfKitFramework** from the drop down list;
* Open the framework's Resource folder and locate the **Snippets.txt** document;
* Copy in you controller interface these lines:

		#import <FastPdfKit/FastPdfKit.h>
		@class MFDocumentManager;
		-(IBAction)actionOpenPlainDocument:(id)sender;

* Copy in your controller implementation these other lines:

		-(IBAction)actionOpenPlainDocument:(id)sender{
		    /** Set document name */
		    NSString *documentName = @"Manual";

		    /** Get temporary directory to save thumbnails */
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
		    /** Set thumbnails path */
		    NSString *thumbnailsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentName]];
    
		    /** Get document from the App Bundle */
		    NSURL *documentUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:documentName ofType:@"pdf"]];
    
		    /** Instancing the documentManager */
			MFDocumentManager *documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];

			/** Instancing the readerViewController */
		    ReaderViewController *pdfViewController = [[ReaderViewController alloc]initWithDocumentManager:documentManager];
    
		    /** Set resources folder on the manager */
		    documentManager.resourceFolder = thumbnailsPath;

		    /** Set document id for thumbnail generation */
		    pdfViewController.documentId = documentName;
    
			/** Present the pdf on screen in a modal view */
		    [self presentModalViewController:pdfViewController animated:YES]; 
    
		    /** Release the pdf controller*/
		    [pdfViewController release];
		}


* Choose a pdf from the finder and drop it in the project;
* Change the `documentName` to the corresponding name;
* Call the `actionOpenPlainDocument` method to open the document;
* Enjoy.


## Changelog

### Update 3.4.2 (June 28, 2012)
* Fix for password protected documents not working anymore

### Update 3.4.1 (June 2, 2012)

* Removed some warnings;
* Updated Extensions;
* Fixed episodical crashes.

### Update 3.4 (May 17, 2012)

* Added a new pdf engine. It is enabled by default. You can switch back to the old version by untick the appropriate option in the *Settings* (this will be available until the final release). Feedback on performances is welcomed.

The new version will attempt to cache pdf page images. If no `documentId` is set in the `MFDocumentViewController`, the default folders are in *Library/Caches/shared*, otherwise the cache is located in *Library/Caches/<documentId>*.

Default settings should provide good performance on all devices, from the first iPad to the new one.
Thumbnails generation has been moved inside the lib. Customization options for the thumbnail scroll view will be available in the final version.

* Fixed occasional crash with dual core devices on startup

### Update 3.3.3 (March 23, 2012)
* New rendering approach just for the new iPad (and its weak A5X CPU)
* Page thumbnails created for Retina Display on the new iPad
* Core Library built with Xcode 4.2 and iOS 5.0 to avoid poor performances caused by a (reintroduced) CATiledLayer.

### Update 3.3.2 (March 14, 2012)
* Alternate uri definition for modal annotations

### Update 3.3.1 (March 13, 2012)
* Added a supportedOrientation attribute to allow change of supported orientation at runtime
* Added alternate schemes (prefixes) for annotations' uri

### Update 3.3 (March 8, 2012)
* Improved support for the new retina iPad
* Fixed (contained) a crash occurring when the pdf provokes a transform stack buffer underflow

### Update 3.2.4 (January 30, 2012)
* Changed font cache again. This should avoid a few cases of creshes due to an NULL font name;

### Update 3.2.3 (January 24th, Tuesday, 2012)
* Removed a few debugging logs
* Added support to remote link in the ToC/Outline
* Internal document links work again

### Update 3.2.2 (January 13th, Friday, 2012)
* Fixed tiled overlay view flag being ignored
* Removed unneeded operator in the pdf scanner
* Changed pdf detail view timings


### Update 3.2.1 (January 5th, 2012)
* Less aggressive tiled view rendering
* Fixed a bug in the glyph name matching function
* Better caching of annotations
* Removed a few more synchronization point between main thread and worker th

### Update 3.2 (January 4th, 2012)
* New Extended target that supports Extensions;
* Out of the box supported Extensions:
    * [**FPKPayPal**](http://doc.fastpdfkit.com/Extensions/Classes/FPKPayPal.html) to create **catalogs** with **items** that can be **purchased** directly **from the app**;
    * [**FPKYouTube**](http://doc.fastpdfkit.com/Extensions/Classes/FPKYouTube.html) to place **YouTube** video on the page.
    * [**FPKGallerySlide**](http://doc.fastpdfkit.com/Extensions/Classes/FPKGallerySlide.html) interactive **image gallery** with manual or automatic advancement;
    * [**FPKMap**](http://doc.fastpdfkit.com/Extensions/Classes/FPKMap.html) to render an interactive google map;
    * [**FPKGalleryFade**](http://doc.fastpdfkit.com/Extensions/Classes/FPKGalleryFade.html) image gallery useful for the table of contents;
    * [**FPKGalleryTap**](http://doc.fastpdfkit.com/Extensions/Classes/FPKGalleryTap.html) to create a multi interactive image gallery;
    * [**FPKMessage**](http://doc.fastpdfkit.com/Extensions/Classes/FPKMessage.html) to show details or alerts;
    * [**FPKWebPopup**](http://doc.fastpdfkit.com/Extensions/Classes/FPKWebPopup.html) to open a **web page** in a popup view;
* Updated documentation to version 3.2
* Included Extensions documentation

For more informations reagarding Extensions [git.io/fpke](git.io/fpke).


### Update 3.1.3 (December 30th, 2011)
* Reworked page metrics synchronization to reduce lag on slow pdfs (more to come).
* Paged scroll view attribute is accessible again in the MFDocumentViewController
    public interface.
* FPK annotations parsing can be disabled by setting MFDocumentViewController's
    fpkAnnotationsEnabled to NO. Use this if you experience frequent freezes while
    skimming the pages.
* You can add multiple MFDocumentViewControllerDelegates by calling MFDocumentViewController's
    addDocumentDelegate: (and removeDocumentDelegate:). Check the interface for 
    details

### Update 3.1.2 (December 16th, 2011)
* Non-unlocked password protected douments should no more crash the application.
* Cordinates for taps on the right page are now correct.
* Fixed a bug involving multibyte fonts compromising search, introduced with
    unicode normalization.
* Few memory leaks in ReaderViewController.
* Overlay views are enbaled on any license again.
* Newstand is disabled as default due to a memory leak in the download procedure.
* Variable number of preview image. Check MFDocumentViewController header.

### Update 3.1.1 (November 30th, 2011)
* View size of the reader is now appropriate for the screen configuration (status bar only).
* Added missing dismiss button in ReaderViewController on iPhone.

### Update 3.1 (November 30th, 2011)
* Reverted to optional tiled overlay view (used for search resulth highlight). This
    seems to have fixed most 'crashes' (app bein killed actually) while zooming
    onto a page.
* A few memory leaks inside the unicode normalization data structures have been 
    fixed.
* Different handling of document view controller dismissal. It is no more necessary
    to call -cleanup on the MFDocumentViewController before relasing it. Actual
    method implementation does nothing.
* Quite a few small memory leaks fixed.
* Faster page redrawn on page transition (goToPage, setPageMode, etc.).
* MFHomeListPdfs is now BookItemView, be careful if you used to subclass the former
    in your project.
* Fixed a few errors in Win ANSI and Mac OS Roman encoding. For example, the Unicode
    character 'LEFT SINGLE QUOTATION MARK' U+2018 will no more be replaced by
    other characters.
* Changed font cache management. If you still get problem with [] (notedef) caracter
    in the text extracted, the cache might be the issue. Set MFDocumentManager's
    fontCacheEnabled property to NO.
* Unicode sequences will now be handled as such and the lib will no try (and fail)
    to compose them to a single unicode codepoint (it is related to search and
    extraction of text).
* Lib will now attemp to compose multibyte characted to a single codepoint for
    search and extraction.
* Added support to 14 (-2) Adobe Standard Fonts. If you get page empty, blank
    pages at text extraction check the simulator log and if the font marked as
    uncompleted is named like one of the files in the FPKCore/standard14fonts
    folder add that font to your application bundle.
* Font cache re-enabled. This time seems to work as expected.
* Default zoom not being set fixed (again).
* Search and extraction will not crash when certain characters are found. Instead
    a .notdef (usually it looks like an empty rect) value with be appended to the
    text.
* Enhanced search and extraction with Unicode composition and decomposition.
* Added search match modes:
	* Return an array of `MFTextItem` representing the matches of teh search term on the page passed as arguments. It is a good choice running this method in a secondary thread.
 	* `FPKSearchMode` has the following values:
 	* `FPKSearchModeHard` - if you search for 'bèzier' it will match 'bèzier' only but not
 'bezier'. If you search for 'bezier' it will match 'bezier' only.
 	* `FPKSearchModeSoft` - if you search for term 'bèzier' it will match both 'bezier' and 'bèzier'. Same if you search for 'bezier'.
 	* `FPKSearchModeSmart` - if you search for term 'bezier', it will also match 'bèzier', but if you search for 'bèzier' it will match 'bèzier' only.
	* Ignore case is self explanatory.
	* Default parameters are `FPKSearchModeSmart` and `ignoreCase` to `YES`.


### Update 3.0 (November 4th, 2011)
* Internal changes of the view hierarchy to provide more flexibility and overlay transitions.
* Revamped `ReaderViewController` user interface.
* Better thumbnail scroll view and generation.
* Added support to video overlay control parameters in the uri.
* Search now works for terms of unitary length.
* Added a method to retrieve annotations from the document and provide them as overlays.
* Slightly changes to `MFDocumentViewControllerDelegate` callbacks.
* New activation method with key *FPKLicenseKey* from *Info.plist*: no need to pull to get the activated version.

### Update 2.1.3 (September 27th, 2011)

Disabled the 2.1.1 font cache due to an implementation oversight. Will be re-introduced as soon as it will behave as expected.

### Update 2.1.2 (September 21th, 2011)
* Cleaned up text search and extraction a little bit. More fixes incoming.

### Update 2.1.1 (September 15th, 2011)
* Added a font cache system for text extraction and search, which should give sensible improvement in search speed especially on documents with a large amount of different fonts.

### Update 2.1.0 (September 14th, 2011)
* Added Overflow page mode to previous Single and Double. Basically, the pdf page will now fill the screen along its width, overflowing under the bottom of the screen if necessary.
* Added autoMode property. It will tell the MFDocumentViewController to what mode switch when in landscape if automodeOnRotation is YES. Default is MFAutoModeDouble, other option are MFAutoModeSingle and MFAutoModeOverflow.

### Update 2.0.3 (August 10th, 2011)
* Fixed a bug in the transformation returned on double page mode for page with an angle not equal to 0.
* Added guard to iOS 4.x only methods.

### Update 2.0.2 (August 09th, 2011)
* Added support to link annotation with Remote Go-To actions.
* Updated manual with latest methods.
* Added methods to convert points and rect to and from different coordinate systems. Take a look at the MFDocumentViewController for details.
* Documented the method to get the cropbox and rotation angle for each document page.
* Finally fixed the bad behavior of the detail (tiled) view on retina device.
* Fixed a bug involving rendering of the preview pages at low res on retina display introduced a few updates ago.
* The -didGoToPage callback is now called once when a page is changed on user scroll input.

### Update 2.0.1 (July 21th, 2011)
* Bleeding of the pdf cover images fixed.
* The embedded UIWebView is now embedded a bit better.

### Update 2.0.0-devel (July 12th, 2011)
* Multimedia support
* Reorganized project
* Many other improvements

If you have any other question please post it in the [Support Site](http://support.fastpdfkit.com)

