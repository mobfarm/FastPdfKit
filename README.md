# FastPdfKit

This repository contains the FastPdfKit iOS library with some sample projects. This library allows you to add some of the features of the [FastPdf application](http://fastpdf.eu) to your own app, allowing it to support pdf documents. For more information, see the [FastPdfKit website](http://fastpdfkit.com) and the [Support website](http://support.fastpdfkit.com).

### Update: 1.0.15 (Aug 09th, 2011)
* Added support to link annotation with Remote Go-To actions.
* Updated manual with latest methods.

### Update: 1.0.14 (Aug 05th, 2011)
* Added methods to convert points and rect to and from different coordinate systems. Take a look at the MFDocumentViewController for details.
* Documented the method to get the cropbox and rotation angle for each document page.

### Update: 1.0.13 (Jul 26th, 2011)
* Finally fixed the bad behavior of the detail (tiled) view on retina device.
* Fixed a bug involving rendering of the preview pages at low res on retina display introduced a few updates ago.
* The -didGoToPage callback is now called once when a page is changed on user scroll input.

### Update: 1.0.12 (Jul 21th, 2011)
* Fixed the bleeding of the pdf, usually on the front and back covers, introduced with the previous fixes.

### Update: 1.0.11 (Jul 18th, 2011)
* Fixed a bug where disabling the shadow, the page resulted with a transparent backing
* Fixed a rare occurrence of a crash while searching due to array boundaries miscalculation

### Update: 1.0.10 (Jul 15th, 2011)
* Added a sample application (FastPdfKit Resizing Sample) to illustrate how to handle the situation where the MFDocumentViewController's view is added as a subview of another view. The MFDocumentViewController has not been created to used that way, but there's a simple workaround to getting things work in most cases.

### Update: 1.0.9 (Jun 22th, 2011)
* Added directional lock to the page scroll view.
* Changed popover behavior in the DocumentViewControllerKiosk. This should fix crash when reopening a document when dismissed with an open popover.
* Fixed a few more leaks.

### Update: 1.0.8 (Jun 10th, 2011)
* Thumbnails are laid out correctly upon rotation.

### Update: 1.0.7 (Jun 07th, 2011)
* Fixed a nasty bug in the parser of True Type font. CMap parser redone on the ground up to be formatting agnostic. Most of the search/extraction related crash should be fixed now. Remember to try the test_ versions of search and extraction function.

### Update: 1.0.6 (May 27th, 2011)

* Added an optional tiled version of the overlay view. If you want sharp drawables when zoomed in, set MFDocumentViewController's useTiledOverlayView to YES. Keep in mind that tiled layer rendering is slower, and memory usage is higher.
* Dropped search view controller and mini search view local copy of search manager delegate's results. They now directly access the data source results. Crash caused by inconsistency between the local copy and the data source data should be fixed.
* Replaced inner rendering parameters data class with a simpler struct together with a better synchronization between threads. Crash on CALayer status error with NAN origin should be fixed.

### Update: 1.0.5 (May 19th, 2011)
* Added two alternative methods in MFDocumentManager for text search and extraction. The methods are 
-(void)test_searchResultOnPage:(NSUInteger)page forSearchTerms:(NSString *)searchTerms
-(void)test_wholeTextForPage:(NSUInteger)page
They return the same results of the non _test versions. To use them, replace the occurrence of the older methods in the project, as exemplified in comments of TextSearchOperation's main() method and TextDisplayViewController's selectorWholeTextForPage: method.

### Update: 1.0.4 (May 3rd, 2011)
* Fixed the floating page issue, when the page is changed when zoomed in.

### Update: 1.0.3 (May 2nd, 2011)
* Better handling of the device orientation at startup.

### Update: 1.0.2 (Apr 29th, 2011)

* Fixed a bug where right drawables were not displayed.
* Zoom animation for setPage:withZoomLevel:onRect: is now correct. Moreover, passing 0 as the level of zoom will let the application try to fit the rect on screen.
* Fixed a crash when an annotation with an uri shorter than 7 char is found.
* Added leftPageNumber and rightPageNumber variables to the MFDocumentViewController.
* Fixed the autoMode on rotation not being considered at startup.

### Update: 1.0.1 (Apr 27th, 2011)

* Replaced URLForResource with pathForResources for 3.X compatibility;
* Added (float)zoomScale and (CGPoint)zoomOffset methods to MFDocumentViewController to get zoom position;
* Added support for CGPDFDocumentCreateWithProvider with method initWithDataProvider:(CGDataProviderRef)provider;
* Option to remove shadow and render the page fullscreen on MFDocumentViewController using (float)padding and (BOOL)showShadow methods;
* Fixed another crash with search results.

### Update: 1.0 (Apr 19th, 2011)

* Fixed ignored optional flag for the didChangeMode: callback.
* Added didReceiveTapOnAnnotationRect:wither:onPage: method. This replaces
didReceiveURIRequest:, but the latter is still called.

### Update: 1.0RC2 (Apr 6th, 2011)
* Fixed a crash when the searched string will not fit in the mini search view. Bookmarks not being saved when the popover is dismissed by clicking outside fixed. Double tap to zoom out will now work even when the zoom in has been performed manually. Added a callback to ask the documentviewcontroller delegate if a video will have to autoplay or not. Added page parameter to the double tap annotation callback. Removed a few unneeded logs and minor tweaks.

### Update: 1.0RC1 (Mar 8th, 2011)
* Kiosk application target added. Kiosk is a demo application with a customizable list of document to choose from. Viewer is enhanced with a scrollable list of page thumbnail and nicer interface.

### Update: 0.9.5 (Feb 14th, 2011)
* Early support for type 0 fonts for search and text extraction
* Fix on bookmarks controller buttons
* Safer cleanup implementation

### Update: 0.9.1 (Feb 3rd, 2011)
* Added customizable Td, TD, Tm, T* and TJ behaviour with custom profiles.
	Look at `mprofile.h` and `MFDocumentManager.h`
* Added CMap support for non Type 0 fonts
* Added FastPdfKit+ whitelist
* Fixed `SearchTableView` dequeue bug
* Added documentation and XCode docset
	* Local into the doc folder
	* Remote at [doc.mobfarm.eu/fastpdfkit](http://doc.mobfarm.eu/fastpdfkit)
	* XCode docset feed at [fastpdfkit.com/docset/docset.atom](http://fastpdfkit.com/docset/docset.atom)
* Solved some memory leaks

### Update: 0.9.0 (Dec 12th, 2010)
* Bundle-id protection
* Customizable interface
* Added splash image
* Results table selected words highlighted
* Small view for rapid results scrubbling
* Zoom on the found word
* Fixed first letter highlight bug
* Supported encoding for every non multibyte font

### Update: 0.7.1 (Dec 3rd, 2010)
* External links support

### Update: 0.7.0 (Nov 19th, 2010)
* Fixed bugs
* Single page thumbnail creation

### Update: 0.6.0 (Nov 17th, 2010)
* Link support
* Page screeshots (for thumbnails)
* Legacy mode for older devices
* Fixed problems with side buttons

### Update: 0.5.0 (Oct 5th, 2010)
* Added search support
	* Word search
	* Text highlight
	* Text extraction
	* Support for Type 1, Type 2 and Type 3 fonts

### Base features
* Fast PDF rendering with side sliding;
* Internal link support;
* Search with highlighted results;
* Text extraction;
* Legacy or Speedy mode;
* Embedded PDF thumbnails support;
* Page thumbnail creation;
* Page preloading;
* Large document support;
* Single, double or auto page modes;
* Autorotation;
* Customizable interface;
* Double tap and pinch to zoom;
* Landscape and Portrait support;
* Tap on a side to go forward or backward;
* Zoom Lock;
* Auto Zoom;
* Brightness control;
* Slider to change page;
* Bookmarks;
* Support for password protected documents;
* Outline - TOC;
* Full screen view;
* Partial screen view;
* Retina display support;
* Support every iOS version starting from 3.1;
* Compatible with every iPad, iPhone and iPod touch.


## How-To use on existing projects

### Add required files to existing project

* Download and extract the last sample project;

* Open your existing app Xcode project, open Project menu and choose Add to Project… ⌥⌘A, then locate FastPdfKit folder inside the downloaded package and click Add ( this folder include the file MFDocumentViewController.h , libFastPDFKit.a and many other file ), be sure to check Copy items into destination group’s folder (if needed);

* Right click on the Framework group and select Add and then Existing Framework…, then choose QuartzCore.framework from the list and press Add;

* With the same method Add all of this framework : UIKit.framework , CoreText.framework , libz.1.2.3.dylib , AVFoundation.framework , MediaPlayer.framework , CFNetwork.framework , AudioToolbox.framework , Foundation.framework and CoreGraphics.framework.

### Start coding

* Choose or add a new controller (we will call it LauncherController) to manage pdf documents and in the .h file add and add lines 3 and 7 to the controller
 
 		//  LauncherController.h
 		#import <UIKit/UIKit.h>
 		@class MFDocumentManager;
 		@interface LauncherController : UIViewController {
 		}
 		-(IBAction)actionOpenPlainDocument:(id)sender;
 		@end
 		
* Add this code before the @implementation line in the .m file
 
 		#import "MFDocumentManager.h"
 		#import "MFDocumentViewController.h"
 		#define DOC_PLAIN @"FastPdfKit-1.0RC1"

* Implement at least this method in the .m file

		 //  LauncherController.m	
		-(IBAction)actionOpenPlainDocument:(id)sender {
     		NSString *documentPath = [[NSBundle mainBundle]pathForResource:DOC_PLAIN ofType:@"pdf"];
     		NSURL *documentUrl = [NSURL fileURLWithPath:documentPath];	
     		MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
     		MFDocumentViewController *aDocViewController = [[MFDocumentViewController alloc]initWithDocumentManager:aDocManager];
     		[self presentModalViewController:aDocViewController animated:YES]; 
     		[aDocViewController release];
 		}
 		
* Now call the above action to open the pdf. You can find the code above with comments in the BasicLauncherController class.

Within FastPdfKit folder there are many other sample controllers (in the Controllers group) where you can find methods (heavily commented) to manage every feature.

If you have any other question please contact us at [Support](http://support.fastpdfkit.com/)

