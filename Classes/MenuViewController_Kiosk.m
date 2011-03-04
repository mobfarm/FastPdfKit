//
//  MenuViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
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
@synthesize documentName;
@synthesize buttonRemoveDict;
@synthesize buttonOpenDict;
@synthesize progressViewDict,imgDict;
@synthesize pdfHome;
@synthesize thumbWidth,thumbHeight,buttonWidth,buttonHeight,scrollViewWidth,scrollViewHeight,detailViewHeight,thumbHOffsetLeft,thumHOffsetRight,frameHeight,scrollViewVOffset;
@synthesize graphicsMode;


-(IBAction)actionOpenPlainDocumentFromNewMain:(id)sender {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *pdfPath = [documentsDirectory stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:documentName];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	
	NSURL *documentUrl = [NSURL fileURLWithPath:pdfPath];
	
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class (a wrapper) and use
	// it to initialize an MFDocumentViewController subclass 	
	MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
	
	DocumentViewController_Kiosk *aDocViewController = [[DocumentViewController_Kiosk alloc]initWithDocumentManager:aDocManager];
	aDocViewController.documentId = documentName;
	// [aDocViewController initNumberOfPageToolbar];
	
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
		thumbWidth=350;
		thumbHeight=480;
		thumbHOffsetLeft = 20;
		thumHOffsetRight = 380;
		frameHeight = 325;
		scrollViewWidth=771;
		scrollViewHeight=875;
		detailViewHeight=665;
		scrollViewVOffset=130;
		
	}else {
		thumbWidth=125;
		thumbHeight=170;
		thumbHOffsetLeft = 10;
		thumHOffsetRight = 160;
		frameHeight = 115;
		scrollViewWidth=323;
		scrollViewHeight=404;
		detailViewHeight=240;
		scrollViewVOffset=60;
	}
	
	XMLParser *parser = [[XMLParser alloc] init];
	
	parser.mvc = self;
	
	[parser parseXMLFileAtURL:@"http://go.mobfarm.eu/pdf/xmldaparsare.xml"];
	
	scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollViewVOffset, scrollViewWidth, scrollViewHeight)];
	scrollView.backgroundColor = [UIColor whiteColor];
	scrollView.contentSize = CGSizeMake(scrollViewWidth, detailViewHeight * ((NUM_PDFTOSHOW/2)+1));
	
	buttonRemoveDict = [[NSMutableDictionary alloc] init];
	buttonOpenDict = [[NSMutableDictionary alloc] init];
	progressViewDict = [[NSMutableDictionary alloc] init];
	imgDict = [[NSMutableDictionary alloc] init];
	
	for (int i=1; i<= NUM_PDFTOSHOW ; i++) {
		NSString *titoloPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"titolo"];
		NSString *linkPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"link"];
		NSString *copertinaPdf = [[pdfHome objectAtIndex: i-1] objectForKey: @"copertina"];
		MFHomeListPdf *viewPdf = [[MFHomeListPdf alloc] initWithName:titoloPdf andLinkPdf:linkPdf andnumOfDoc:i andImage:copertinaPdf andSize:CGSizeMake(thumbWidth, thumbHeight)];
		CGRect frame = self.view.frame;
		if ((i%2)==0) {
			frame.origin.y = (frameHeight * 2 ) * ( (i-1) / 2 );
			frame.origin.x = thumHOffsetRight;
			frame.size.width = thumbWidth;
			frame.size.height = detailViewHeight;
		}else {
			frame.origin.y = frameHeight *(i-1);
			frame.origin.x = thumbHOffsetLeft;
			frame.size.width = thumbWidth;
			frame.size.height = detailViewHeight;
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
	
	CGFloat yBorder = 0 ; 
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		yBorder = scrollViewVOffset-3 ;
	}else {
		yBorder = scrollViewVOffset-1 ;
	}
	
	UIImageView *border = [[UIImageView alloc] initWithFrame:CGRectMake(0, yBorder, scrollViewWidth, 40)]; 
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
