//
//  RssViewController.h
//  FastPDF
//
//  Created by Mac Book Pro on 04/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MenuViewController.h"


@interface XMLParser : UIViewController <ASIHTTPRequestDelegate>{
	
	
	
	//IBOutlet UILabel *downloadInProgress;
	
	
	NSXMLParser * xmlParser;
	
	NSMutableArray * stories;
	
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
	NSString *currentString;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSString * currentUrl ;
	NSMutableString * currentTitle, * currentCopertina, * currentLink;
	ASIHTTPRequest *request;
	id delegate;
	MenuViewController *mvc ;
	
	BOOL pdfInDownload;
	BOOL errorDownload;
}

@property (nonatomic, assign) MenuViewController *mvc;
@property (readwrite) BOOL pdfInDownload;
@property (readwrite) BOOL errorDownload;
@property (nonatomic,retain ) NSString *currentString;

-(void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf;

@end
