    //
//  RssViewController.m
//  FastPDF
//
//  Created by Mac Book Pro on 04/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"
#import "MenuViewController.h"


@implementation XMLParser

@synthesize mvc;
@synthesize pdfInDownload;
@synthesize currentString;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
	
}*/


- (void)viewDidLoad {
	// Add the following line if you want the list to be editable
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
	//downloadInProgress.hidden=YES;
	pdfInDownload = NO;
}


-(void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf{
	
	
	 //_url = @"http://gapil.truelite.it/gapil.pdf";
	
	 NSURL *url = [NSURL URLWithString:_url];
	 request = [ASIHTTPRequest requestWithURL:url];
	 [request setDelegate:self];
	 
	 // Filename Path
	 
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *documentsDirectory = [paths objectAtIndex:0];
	
	 
	 NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[[delegate fileManager] firstAvailableFileNameForName:_url]];
	pdfPath = [pdfPath stringByAppendingString:@"/"];
	pdfPath = [pdfPath stringByAppendingString:nomefilepdf];
	pdfPath = [pdfPath stringByAppendingString:@".pdf"];
	 [request setUseKeychainPersistence:YES];
	 [request setDownloadDestinationPath:pdfPath];
	 [request setDidFinishSelector:@selector(requestFinished:)];
	 [request setDidFailSelector:@selector(requestFailed:)];
	 [request setShouldPresentAuthenticationDialog:YES];
	 [request setDownloadDestinationPath:pdfPath];
	 [request startAsynchronous];
}

-(void)requestStarted:(ASIHTTPRequest *)request{
	NSLog(@"requestStarted");
	//[downloadInProgress setHidden:NO];
	pdfInDownload = YES;
}

-(void)requestFinished:(ASIHTTPRequest *)request{
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"DOWNLOAD TERMINATO" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Ok" otherButtonTitles:nil,nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	NSLog(@"requestFinished");
	//[downloadInProgress setHidden:YES];
	pdfInDownload = NO;
	//devo salvare il doc ..
}

-(void)requestFailed:(ASIHTTPRequest *)request{
	NSLog(@"requestFailed");
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"ERRORE DOWNLOAD" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil,nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[popupQuery showInView:self.view];
	NSLog(@"requestFinished");
	//[downloadInProgress setHidden:YES];
	pdfInDownload = NO;
}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	NSLog(@"found file and started parsing");
	
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	stories = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [xmlParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
	
    [xmlParser parse];
	[pool release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{            
	
	if ([elementName isEqualToString:@"pdf"]) {
		
		item = [[NSMutableDictionary alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	
	if ([elementName isEqualToString:@"titolo"]) {
		
		[item setValue:currentString forKey:@"titolo"];
		
	} else if ([elementName isEqualToString:@"link"]) {
		
		[item setValue:currentString forKey:@"link"];
		
	} else if ([elementName isEqualToString:@"copertina"]) {
		
		[item setValue:currentString forKey:@"copertina"];
		
	} else if ([elementName isEqualToString:@"pdf"]) {
		
		[stories addObject:item];
		[item release];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	self.currentString = [string copy];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	//return stories;
	
	mvc.pdfHome = stories;

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void)dealloc {
	
	[currentElement release];
	[xmlParser release];
	[stories release];
	[item release];
	[currentTitle release];
	[currentCopertina release];
	[currentLink release];
	
	[super dealloc];
}


@end