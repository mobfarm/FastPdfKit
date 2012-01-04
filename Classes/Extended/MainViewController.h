//
//  MainViewController.h
//  SampleProject
//

#import <UIKit/UIKit.h>
#import <FastPdfKit/FastPdfKit.h>

@class MFDocumentManager;

/**
 The controller opens the pdf view.

*/

@interface MainViewController : UIViewController

/**
 The document to open a pdf document with FastPdfKit.
 
Set document name
     NSString *documentName = @"sample";
     
Get document from the App Bundle
     NSURL *documentUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documentName ofType:@"pdf"]];
     
Instancing the **MFDocumentManager**
 	MFDocumentManager *documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
     
Instancing the **ReaderViewController**
     ReaderViewController *pdfViewController = [[ReaderViewController alloc]initWithDocumentManager:documentManager];
     
Set resources folder on the manager
     documentManager.resourceFolder = [[NSBundle mainBundle] resourcePath];
     
Set document id for thumbnail generation
     pdfViewController.documentId = documentName;
     
Set the padding around page to 0.0     
     [pdfViewController setPadding:0.0];
     
Instantiating the FPKOverlayManager (you can find in the the FPKShared framework) to manage extensions.
      
You can use initWithExtensions:
     NSArray *extensions = [[NSArray alloc] initWithObjects:@"FPKYouTube", nil];
     OverlayManager *_overlayManager = [[[OverlayManager alloc] initWithExtensions:extensions] autorelease];

Or set them manually subclassing the init method     
     OverlayManager *_overlayManager = [[[OverlayManager alloc] init] autorelease];
 
Add the FPKOverlayManager as OverlayViewDataSource to the ReaderViewController
     [pdfViewController addOverlayViewDataSource:_overlayManager];
     
Register as documentDelegate to receive tap
     [pdfViewController addDocumentDelegate:_overlayManager];
     
Set the DocumentViewController to obtain access the the conversion methods
     [_overlayManager setDocumentViewController:(MFDocumentViewController <FPKOverlayManagerDelegate> *)pdfViewController];
     
Present the pdf on screen in a modal view
     [self presentModalViewController:pdfViewController animated:YES]; 
     
Release the pdf controller
     [pdfViewController release];
 
 
 @param id Usually the **UIButton** that invoked the method.
*/

-(IBAction)actionOpenPlainDocument:(id)sender;

@end
