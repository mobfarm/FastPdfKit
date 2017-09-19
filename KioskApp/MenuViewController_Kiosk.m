//
//  MenuViewController_Kiosk.m
//  FastPdfKit
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController_Kiosk.h"
#import <FastPdfKit/MFDocumentManager.h>
#import <FastPdfKit/FastPdfKit.h>
#import "BookItemView.h"
#import "XMLParser.h"
#include <stdio.h>
#include <stdlib.h>

#define FPK_KIOSK_XML_URL @"https://raw.githubusercontent.com/mobfarm/FastPdfKit/resources/Classes/KioskApp/KioskResources/kiosk_list.xml"
#define FPK_KIOSK_XML_NAME @"kiosk_list"

@implementation MenuViewController_Kiosk

@synthesize buttonRemoveDict;
@synthesize openButtons;
@synthesize progressViewDict,imgDict;
@synthesize documentsList;
@synthesize graphicsMode;
@synthesize scrollView;
@synthesize interfaceLoaded;
@synthesize xmlURL;

-(IBAction)actionOpenPlainDocument:(NSString *)documentName {
	
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	 
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString * pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.pdf",documentName,documentName]];
    NSURL * documentUrl = [NSURL fileURLWithPath:pdfPath];
    
    NSString * resourceFolder = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",documentName]];
	
	// Now that we have the URL, we can allocate an istance of the MFDocumentManager class and use
	// it to initialize an MFDocumentViewController subclass 	
	
    MFDocumentManager * documentManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    documentManager.resourceFolder = resourceFolder;
	
	ReaderViewController * documentViewController = [[ReaderViewController alloc]initWithDocumentManager:documentManager];
    documentViewController.edgesForExtendedLayout = UIRectEdgeNone;
	documentViewController.documentId = documentName;
    
    // Present as a navigation controller item
    documentViewController.dismissBlock = ^{
        [[self navigationController] popToViewController:self animated:YES];
    };
    [[self navigationController]pushViewController:documentViewController animated:YES]; // Present as vavigation controller item
    
    /*
     // Present as a modal view controller
    documentViewController.dismissBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
     [self presentModalViewController:documentViewController animated:YES]; // Present as modal view controller
    */
    
	[documentViewController release];
	[documentManager release];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        buttonRemoveDict = [[NSMutableDictionary alloc] init];
        openButtons = [[NSMutableDictionary alloc] init];
        progressViewDict = [[NSMutableDictionary alloc] init];
        imgDict = [[NSMutableDictionary alloc] init];
        
        bookItemViews = [[NSMutableArray alloc]init];
        
        xmlDirty = YES;
        
        self.xmlURL = [NSURL URLWithString:FPK_KIOSK_XML_URL];

    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		buttonRemoveDict = [[NSMutableDictionary alloc] init];
		openButtons = [[NSMutableDictionary alloc] init];
		progressViewDict = [[NSMutableDictionary alloc] init];
		imgDict = [[NSMutableDictionary alloc] init];
		
		bookItemViews = [[NSMutableArray alloc]init];
        
        xmlDirty = YES;
        
		self.xmlURL = [NSURL URLWithString:FPK_KIOSK_XML_URL];
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
        
        [parser parseXMLFileAtURL:self.xmlURL];
    
        if([parser isDone]) {
            
            self.documentsList = [parser parsedItems];
            
        } else { // Embedded xml as backup.
            
            xmlUrl = [[NSBundle bundleForClass:[self class]] URLForResource:FPK_KIOSK_XML_NAME withExtension:@"xml"];
            
            [parser parseXMLFileAtURL:xmlUrl];
            
            if([parser isDone]) {
                self.documentsList = [parser parsedItems];
            }
        }
        
        [parser release];
    }
    
    [self buildInterface];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionDidFinish:) name:@"eu.fastpdfkit.kiosk.ConnectionDidFinish" object:nil];
}

-(void)handleConnectionDidFinish:(NSNotification *)notification {
    if(self.interfaceLoaded) {
        [self buildInterface];
    }
}

-(void)buildInterface{

	CGFloat yBorder = 0 ; 
	UIImageView * anImageView = nil;
	
	CGRect frame;
	NSString * titoloPdf = nil;
    NSString * titoloPdfNoSpace = nil;
	NSString * linkPdf = nil;
	NSString * copertinaPdf = nil;
    
	BookItemView * bookItemView = nil;
    
	NSUInteger documentsCount; // Used to iterate over each item in the list.
	
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
		scrollViewWidth = [[UIScreen mainScreen] bounds].size.width;
		scrollViewHeight = 875.0;
		detailViewHeight = 665.0;
		scrollViewVOffset = 130.0;
		
	} else {
		
		thumbWidth = 125.0;
		thumbHeight = 170.0;
		thumbHOffsetLeft = 10.0;
		thumHOffsetRight = 160.0;
		frameHeight = 115.0;
		scrollViewWidth = [[UIScreen mainScreen] bounds].size.width;
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
    
    anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yBorder, scrollViewWidth+2, 40)];
    [anImageView setImage:[UIImage imageNamed:@"Kioks/border" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    [anImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:anImageView];
    [anImageView release];
    
    
	
	scrollView.backgroundColor = [UIColor whiteColor];
	[scrollView setShowsVerticalScrollIndicator:NO];
    
    UIView *testViewContainer = [[UIView alloc] initWithFrame:CGRectMake((scrollView.frame.size.width-scrollViewWidth)/2, 0, scrollViewWidth,0)];
	
	[testViewContainer setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    
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
		[testViewContainer addSubview:bookItemView.view];
		
		// Adding stuff to their respective containers.
		
		[imgDict setValue:bookItemView.openButtonFromImage forKey:titoloPdfNoSpace];
		[openButtons setValue:bookItemView.openButton forKey:titoloPdfNoSpace];
		[buttonRemoveDict setValue:bookItemView.removeButton forKey:titoloPdfNoSpace];
		[progressViewDict setValue:bookItemView.progressDownload forKey:titoloPdfNoSpace];
		
		[bookItemViews addObject:bookItemView];
		[bookItemView release];
		
	}
    
    [testViewContainer setFrame:CGRectMake((scrollView.frame.size.width-scrollViewWidth)/2, 0, scrollViewWidth,((documentsCount/2)+(documentsCount%2))*detailViewHeight)];
    
    [scrollView addSubview:testViewContainer];
    
    [scrollView setContentSize:CGSizeMake(testViewContainer.frame.size.width, testViewContainer.frame.size.height)];
	
    [testViewContainer release];
	
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

- (void)dealloc {
	
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
	[documentsList release];
	
	[buttonRemoveDict release];
	[openButtons release];
	[progressViewDict release];
	[imgDict release];
	[downloadProgressContainerView release];
    [downloadProgressView release];
    
    [scrollView release];
    [xmlURL release];
	[bookItemViews release];
	
    [super dealloc];
}

@end
