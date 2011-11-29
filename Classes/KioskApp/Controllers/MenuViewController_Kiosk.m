//
//  MenuViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController_Kiosk.h"
#import "MFDocumentManager.h"
#import "ReaderViewController.h"
#import "BookItemView.h"
#import "XMLParser.h"
#include <stdio.h>
#include <stdlib.h>

#define FPK_KIOSK_XML_URL @"http://go.mobfarm.eu/pdf/kiosk_list.xml"
#define FPK_KIOSK_XML_NAME @"kiosk_list"

@implementation MenuViewController_Kiosk

@synthesize buttonRemoveDict;
@synthesize openButtons;
@synthesize progressViewDict,imgDict;
@synthesize documentsList;
@synthesize graphicsMode;
@synthesize scrollView;
@synthesize interfaceLoaded;


-(IBAction)actionOpenPlainDocument:(NSString *)documentName {
	
	MFDocumentManager * documentManager = nil;
	ReaderViewController * documentViewController = nil;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	NSArray *paths = nil;
	NSString *documentsDirectory = nil;
	NSString *pdfPath = nil;
	NSURL *documentUrl = nil;
	
	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",documentName,documentName]];
	documentUrl = [NSURL fileURLWithPath:pdfPath];
    
    pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentName]];
	
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class and use
	// it to initialize an MFDocumentViewController subclass 	
	
	documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    
    documentManager.resourceFolder = pdfPath;
	
	documentViewController = [[ReaderViewController alloc]initWithDocumentManager:documentManager];
	documentViewController.documentId = documentName;
	
	[[self navigationController]pushViewController:documentViewController animated:YES];
    
	[documentViewController release];
	[documentManager release];
	
	
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		buttonRemoveDict = [[NSMutableDictionary alloc] init];
		openButtons = [[NSMutableDictionary alloc] init];
		progressViewDict = [[NSMutableDictionary alloc] init];
		imgDict = [[NSMutableDictionary alloc] init];
		
		bookItemViews = [[NSMutableArray alloc]init];
        
        xmlDirty = YES;
		
	}
	
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
    
    XMLParser *parser = nil;
    NSURL * xmlUrl = nil;
    
    if(xmlDirty) {
        
        xmlDirty = NO;
    
        parser = [[XMLParser alloc] init];
        xmlUrl = [NSURL URLWithString:FPK_KIOSK_XML_URL];
        [parser parseXMLFileAtURL:xmlUrl];
    
        if([parser isDone]) {
            
            self.documentsList = [parser parsedItems];
            
        } else {
            
            xmlUrl = [MF_BUNDLED_BUNDLE(@"FPKKioskBundle") URLForResource:FPK_KIOSK_XML_NAME withExtension:@"xml"];
            
            [parser parseXMLFileAtURL:xmlUrl];
            
            if([parser isDone]) {
                self.documentsList = [parser parsedItems];
            }
        }
        
        [parser release];
    }
    
	//[self performSelector:@selector(buildInterface) withObject:nil afterDelay:0.5];
    [self buildInterface];
}


-(void)buildInterface{

	UIScrollView * aScrollView = nil;
	CGFloat yBorder = 0 ; 
	UIImageView * anImageView = nil;
	
	CGRect frame;
	NSString * titoloPdf = nil;
    NSString * titoloPdfNoSpace = nil;
	NSString * linkPdf = nil;
	NSString * copertinaPdf = nil;
    
	BookItemView * bookItemView = nil;
    
	int documentsCount; // Used to iterate over each item in the list.
	
	//Graphics visualization
	
	CGFloat thumbWidth;
	CGFloat thumbHeight;
	CGFloat scrollViewWidth;
	CGFloat scrollViewHeight;
	CGFloat detailViewHeight;
	CGFloat thumbHOffsetLeft;
	CGFloat thumHOffsetRight;
	CGFloat frameHeight;
	CGFloat scrollViewVOffset;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		thumbWidth = 350.0;
		thumbHeight = 480.0;
		thumbHOffsetLeft = 20.0;
		thumHOffsetRight = 380.0;
		frameHeight = 325.0;
		scrollViewWidth = 771.0;
		scrollViewHeight = 875.0;
		detailViewHeight = 665.0;
		scrollViewVOffset = 130.0;
		
	} else {
		
		thumbWidth = 125.0;
		thumbHeight = 170.0;
		thumbHOffsetLeft = 10.0;
		thumHOffsetRight = 160.0;
		frameHeight = 115.0;
		scrollViewWidth = 323.0;
		scrollViewHeight = 404.0;
		detailViewHeight = 240.0;
		scrollViewVOffset = 60.0;
	}
	
	documentsCount = [documentsList count];
    
       // Border.
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            yBorder = scrollViewVOffset-3 ;
        }else {
            yBorder = scrollViewVOffset-1 ;
        }
        
        anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yBorder, scrollViewWidth, 40)]; 
        [anImageView setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKKioskBundle",@"border",@"png")]];
        [self.view addSubview:anImageView];
        [anImageView release];
    
	aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollViewVOffset, scrollViewWidth, scrollViewHeight)];
	aScrollView.backgroundColor = [UIColor whiteColor];
	aScrollView.contentSize = CGSizeMake(scrollViewWidth, detailViewHeight * ((documentsCount/2)+(documentsCount%2)));
	
	for (int i=1; i<= documentsCount ; i++) {
		
		titoloPdf = [[documentsList objectAtIndex: i-1] objectForKey: @"title"];
        titoloPdfNoSpace = [titoloPdf stringByReplacingOccurrencesOfString:@" " withString:@""];
		linkPdf = [[documentsList objectAtIndex: i-1] objectForKey: @"link"];
		copertinaPdf = [[documentsList objectAtIndex: i-1] objectForKey: @"cover"];
        
        bookItemView = [[BookItemView alloc] initWithName:titoloPdfNoSpace andTitoloPdf:titoloPdf andLinkPdf:linkPdf andnumOfDoc:i andImage:copertinaPdf andSize:CGSizeMake(thumbWidth, thumbHeight)];
        
		frame = self.view.frame;
		
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
		
		bookItemView.view.frame = frame;
		bookItemView.menuViewController = self;
		[aScrollView addSubview:bookItemView.view];
		
		// Adding stuff to their respective containers.
		
		[imgDict setValue:bookItemView.openButtonFromImage forKey:titoloPdfNoSpace];
		[openButtons setValue:bookItemView.openButton forKey:titoloPdfNoSpace];
		[buttonRemoveDict setValue:bookItemView.removeButton forKey:titoloPdfNoSpace];
		[progressViewDict setValue:bookItemView.progressDownload forKey:titoloPdfNoSpace];
		
		[bookItemViews addObject:bookItemView];
		[bookItemView release];
		
	}
    
	self.scrollView = aScrollView;
    [aScrollView release];
    
	[self.view addSubview:scrollView];
    
    interfaceLoaded = YES;
}





// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if(interfaceOrientation == UIDeviceOrientationPortrait){
        
		return YES;
        
	} else {
        
		return NO;
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
    [buttonRemoveDict removeAllObjects];
	[openButtons removeAllObjects];
	[progressViewDict removeAllObjects];
	[imgDict removeAllObjects];
	[bookItemViews removeAllObjects];
    
    self.scrollView = nil; 
    
    [super viewDidUnload];
}


- (void)dealloc {
	
	[documentsList release];
	
	[buttonRemoveDict release];
	[openButtons release];
	[progressViewDict release];
	[imgDict release];
	[downloadProgressContainerView release];
    [downloadProgressView release];
    
    [scrollView release];
    
	[bookItemViews release];
	
    [super dealloc];
}

@end
