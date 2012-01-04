//
//  MainViewController.m
//  SampleProject
//

#import "MainViewController.h"
#import <FastPdfKit/ReaderViewController.h>
#import "OverlayManager.h"

@implementation MainViewController

-(IBAction)actionOpenPlainDocument:(id)sender{
    /** Set document name */
    NSString *documentName = @"sample";
    
    /** Get document from the App Bundle */
    NSURL *documentUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documentName ofType:@"pdf"]];
    
    /** Instancing the documentManager */
	MFDocumentManager *documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    
	/** Instancing the readerViewController */
    ReaderViewController *pdfViewController = [[ReaderViewController alloc]initWithDocumentManager:documentManager];
    
    /** Set resources folder on the manager */
    documentManager.resourceFolder = [[NSBundle mainBundle] resourcePath];
    
    /** Set document id for thumbnail generation */
    pdfViewController.documentId = documentName;
    [pdfViewController setPadding:0.0];
    
    /**
     Instantiating the FPKOverlayManager (you can find in the the FPKShared framework) to manage extensions.
     
     You can use initWithExtensions or set them manually in the init method.

     NSArray *extensions = [[NSArray alloc] initWithObjects:@"FPKYouTube", nil];
     OverlayManager *_overlayManager = [[[OverlayManager alloc] initWithExtensions:extensions] autorelease];
     */
    
    OverlayManager *_overlayManager = [[[OverlayManager alloc] init] autorelease];

    /** Add the FPKOverlayManager as OverlayViewDataSource to the ReaderViewController */
    [pdfViewController addOverlayViewDataSource:_overlayManager];
    
    /** Register as DocumentDelegate to receive tap */
    [pdfViewController addDocumentDelegate:_overlayManager];
    
    /** Set the DocumentViewController to obtain access the the conversion methods */
    [_overlayManager setDocumentViewController:(MFDocumentViewController <FPKOverlayManagerDelegate> *)pdfViewController];
    
	/** Present the pdf on screen in a modal view */
    [self presentModalViewController:pdfViewController animated:YES]; 
    
    /** Release the pdf controller*/
    [pdfViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
