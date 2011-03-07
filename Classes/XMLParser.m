    //
//  RssViewController.m
//  FastPDF
//
//  Created by Mac Book Pro on 04/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"
#import "MenuViewController_Kiosk.h"

@implementation XMLParser

@synthesize menuViewController;
@synthesize pdfInDownload,downloadError;
@synthesize currentString;
@synthesize documents;
@synthesize currentItem;
@synthesize httpRequest;

- (void)viewDidLoad {
	pdfInDownload = NO;
	downloadError = NO;
}

-(void)downloadPDF:(id)sender withUrl:(NSString *)sourceURL andName:(NSString *)destinationFileName {
	
	
	NSURL *url = [NSURL URLWithString:sourceURL];
	
	ASIHTTPRequest * request = nil;
	
	NSArray * paths = nil;
	NSString * documentsDirectory = nil;
	NSString * pdfPath = nil;
	
	// Destination filename path.
	
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDirectory = [paths objectAtIndex:0];
	pdfPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",destinationFileName]];
	
	request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setUseKeychainPersistence:YES];
	[request setDownloadDestinationPath:pdfPath];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request setShouldPresentAuthenticationDialog:YES];
	[request setDownloadDestinationPath:pdfPath];
	
	
	self.httpRequest = request;
	
	[request startAsynchronous];
}

-(void)requestStarted:(ASIHTTPRequest *)request{
	
	pdfInDownload = YES;
}

-(void)requestFinished:(ASIHTTPRequest *)request{
	//UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"DOWNLOAD FINISHED" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Ok" otherButtonTitles:nil,nil];
//	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//	[popupQuery showInView:self.view];

	pdfInDownload = NO;

}

-(void)requestFailed:(ASIHTTPRequest *)request{
//
//	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"ERROR DOWNLOAD" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil,nil];
//	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//	[popupQuery showInView:self.view];
	pdfInDownload = NO;
}


//
//- (void)viewWillAppear:(BOOL)animated {
//	[super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//	[super viewDidAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//}

- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	
}

- (void)parseXMLFileAtURL:(NSString *)URL {	
	
	NSXMLParser * xmlParser = nil;
	NSString * filePath = nil;
	NSData * fileData = nil;
	NSURL * xmlURL = nil;
	NSMutableArray * storiesArray = nil;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Allocate a new array to store the entries (just in case somebody call parse twice).
	
	storiesArray = [[NSMutableArray alloc] init];
	self.documents = storiesArray;
	[storiesArray release];
	
    // String URL's to actual NSURL.
	
    xmlURL = [NSURL URLWithString:URL];
	
    if (downloadError) {
		
		// If an error occurred while downloading, we default to the bundled xml.
		
		filePath = [[NSBundle mainBundle] pathForResource:DEF_XML_NAME ofType:@"xml"];  
		fileData = [NSData dataWithContentsOfFile:filePath]; 
		xmlParser = [[NSXMLParser alloc] initWithData:fileData];
		
	} else {
		xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	}
	
    // Set self as the delegate of the parser.
    
	[xmlParser setDelegate:self];
	
    // Not intrested in advanced features.
	
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
	
    [xmlParser parse]; // Parse.
	
	// Cleanup.
	
	[xmlParser release];
	[pool release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	downloadError = YES;
	
	[self parseXMLFileAtURL:DEF_XML_URL];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{            
	
	if ([elementName isEqualToString:KEY_PDF]) {
		
		self.currentItem = [[NSMutableDictionary alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//parse the xml with the element included into the xml.
	if ([elementName isEqualToString:KEY_TITLE]) {
		
		[currentItem setValue:currentString forKey:KEY_TITLE];
		
	} else if ([elementName isEqualToString:KEY_LINK]) {
		
		[currentItem setValue:currentString forKey:KEY_LINK];
		
	} else if ([elementName isEqualToString:KEY_COVER]) {
		
		[currentItem setValue:currentString forKey:KEY_COVER];
		
	} else if ([elementName isEqualToString:KEY_PDF]) {
		
		[documents addObject:currentItem];
		[currentItem release];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	self.currentString = [string copy];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	downloadError = NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[documents release];
	
	[currentElement release];
	[currentItem release];
	[currentTitle release];
	[currentCopertina release];
	[currentLink release];
	[currentUrl release];
	
	[httpRequest release];
	
	[super dealloc];
}


@end