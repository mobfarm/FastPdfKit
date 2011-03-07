//
//  XMLParser.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MenuViewController_Kiosk.h"

#define KEY_COVER @"cover"
#define KEY_LINK @"link"
#define KEY_TITLE @"title"
#define KEY_PDF @"pdf"
#define DEF_XML_URL @"http://fastpdfkit.com/kiosk/kiosk_list.xml"
#define DEF_XML_NAME @"kiosk_list"

@interface XMLParser : NSObject <ASIHTTPRequestDelegate,UIActionSheetDelegate,NSXMLParserDelegate>{
	
	NSMutableArray * documents;
	
	// Temporary item, added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * currentItem;
	NSString *currentString;
	
	NSString * currentElement;
	NSString * currentUrl ;
	NSMutableString * currentTitle, * currentCopertina, * currentLink;
	
	ASIHTTPRequest * httpRequest;
	
	// id delegate;
	
	MenuViewController_Kiosk *menuViewController ;
	
	BOOL pdfInDownload;
	BOOL downloadError;
}

@property (nonatomic, assign) MenuViewController_Kiosk *menuViewController;
@property (readwrite) BOOL pdfInDownload;
@property (readwrite) BOOL downloadError;
@property (nonatomic,retain ) NSString *currentString;
@property (nonatomic, retain) NSMutableArray * documents;
@property (nonatomic, retain) NSMutableDictionary * currentItem;
@property (nonatomic, retain) ASIHTTPRequest * httpRequest;

-(void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf;
-(void)parseXMLFileAtURL:(NSString *)URL;

@end
