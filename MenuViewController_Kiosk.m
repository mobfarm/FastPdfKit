//
//  MenuViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 25/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController_Kiosk.h"
#import "MFDocumentManager.h"
#import "DocumentViewController_Kiosk.h"
#import "MFHomeListPdf.h"
#import "XMLParser.h"
#include <stdio.h>
#include <stdlib.h>

#define NUM_PDFTOSHOW 5

@implementation MenuViewController_Kiosk

@synthesize referenceButton, manualButton, referenceTextView, manualTextView;
@synthesize document;
@synthesize passwordAlertView;
@synthesize downloadProgressView;
@synthesize DownloadProgress;
@synthesize nomePdfDaAprire;
@synthesize buttonRemoveDict;
@synthesize buttonOpenDict;
@synthesize progressViewDict,imgDict;
@synthesize pdfHome;
@synthesize widthThumb,heightThumb,widthButton,heightButton,widthScrollView,heightScrollView,heightViewDetail,xSxThumb,xDxThumb,heightFrame,yScrollView;
@synthesize graphicsMode;


-(IBAction)actionOpenPlainDocumentFromNewMain:(id)sender {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:nomePdfDaAprire];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	
	NSURL *documentUrl = [NSURL fileURLWithPath:pdfPath];
	
	
	
	
	//
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class (a wrapper) and use
	// it to initialize an MFDocumentViewController subclass 	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	DocumentViewController_Kiosk *aDocViewController = [[DocumentViewController_Kiosk alloc]initWithDocumentManager:aDocManager];
	aDocViewController.nomefile=nomePdfDaAprire;
	[aDocViewController initNumberOfPageToolbar];
	//
	//	In this example we use a navigation controller to present the document view controller but you can present it
	//	as a modal viewcontroller or just show a single PDF right from the beginning
	// [self presentModalViewController:aDocViewController animated:YES]; 
	
	[[self navigationController]pushViewController:aDocViewController animated:YES];
	
	[aDocViewController release];
	[aDocManager release];
	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Graphics visualization
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		widthThumb=350;
		heightThumb=480;
		xSxThumb = 20;
		xDxThumb = 380;
		heightFrame = 325;
		widthScrollView=771;
		heightScrollView=875;
		heightViewDetail=665;
		yScrollView=130;
		
	}else {
		widthThumb=125;
		heightThumb=170;
		xSxThumb = 10;
		xDxThumb = 160;
		heightFrame = 115;
		widthScrollView=323;
		heightScrollView=404;
		heightViewDetail=240;
		yScrollView=60;
	}
	
	XMLParser *parser = [[XMLParser alloc] init];
	
	parser.mvc = self;
	
	[parser parseXMLFileAtURL:@"http://go.mobfarm.eu/pdf/xmldaparsare.xml"];
	
	scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yScrollView, widthScrollView, heightScrollView)];
	scrollView.backgroundColor = [UIColor whiteColor];
	scrollView.contentSize = CGSizeMake(widthScrollView, heightViewDetail * ((NUM_PDFTOSHOW/2)+1));
	
	buttonRemoveDict = [[NSMutableDictionary alloc] init];
	buttonOpenDict = [[NSMutableDictionary alloc] init];
	progressViewDict = [[NSMutableDictionary alloc] init];
	imgDict = [[NSMutableDictionary alloc] init];
	
	for (int i=1; i<= NUM_PDFTOSHOW ; i++) {
		NSString *titoloPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"titolo"];
		NSString *linkPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"link"];
		NSString *copertinaPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"copertina"];
		MFHomeListPdf *viewPdf = [[MFHomeListPdf alloc] initWithName:titoloPdf andLinkPdf:linkPdf andnumOfDoc:i andImage:copertinaPdf andSize:CGSizeMake(widthThumb, heightThumb)];
		CGRect frame = self.view.frame;
		if ((i%2)==0) {
			frame.origin.y = (heightFrame * 2 ) * ( (i-1) / 2 );
			frame.origin.x = xDxThumb;
			frame.size.width = widthThumb;
			frame.size.height = heightViewDetail;
		}else {
			frame.origin.y = heightFrame *(i-1);
			frame.origin.x = xSxThumb;
			frame.size.width = widthThumb;
			frame.size.height = heightViewDetail;
		}
		
		viewPdf.view.frame = frame;
		viewPdf.mvc=self;
		[scrollView addSubview:viewPdf.view];
		[imgDict setValue:viewPdf.openButtonFromImage forKey:titoloPdf];
		[buttonOpenDict setValue:viewPdf.openButton forKey:titoloPdf];
		[buttonRemoveDict setValue:viewPdf.removeButton forKey:titoloPdf];
		[progressViewDict setValue:viewPdf.progressDownload forKey:titoloPdf];
		
	}
	[self.view addSubview:scrollView];
	
	UIImageView *border = [[UIImageView alloc] initWithFrame:CGRectMake(0, yScrollView-3, widthScrollView, 40)]; 
	[border setImage:[UIImage imageNamed:@"border.png"]];
	[self.view addSubview:border];
	[border release];
}

-(void)showViewDownload{
	DownloadProgress.hidden = NO;
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.10];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[DownloadProgress setFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, 200)];
	[UIView commitAnimations];
}

-(void)hideViewDownload{
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[DownloadProgress setFrame:CGRectMake(0, DownloadProgress.frame.origin.y+DownloadProgress.frame.size.height, DownloadProgress.frame.size.width, DownloadProgress.frame.size.height)];
	[UIView commitAnimations];

	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if(interfaceOrientation == UIDeviceOrientationPortrait){
		return YES;
	}else {
		return NO;
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[self setManualButton:nil];
	[self setManualTextView:nil];
	[self setReferenceButton:nil];
	[self setReferenceTextView:nil];
	[buttonRemoveDict dealloc];
	[buttonOpenDict dealloc];
	[progressViewDict dealloc];
	[imgDict dealloc];
}


- (void)dealloc {
    [super dealloc];
}

@end
