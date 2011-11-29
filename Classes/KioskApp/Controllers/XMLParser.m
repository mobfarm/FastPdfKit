//
//  XMLParser.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "XMLParser.h"
#import "MenuViewController_Kiosk.h"

#define FPK_XML_COVER @"cover"
#define FPK_XML_LINK @"link"
#define FPK_XML_TITLE @"title"
#define FPK_XML_PDF @"pdf"
// #define DEF_XML_URL @"http://fastpdfkit.com/kiosk/kiosk_list.xml"

@interface XMLParser()

@property (nonatomic, retain) NSMutableArray * documents;
@property (nonatomic, retain) NSMutableDictionary * currentItem;
@property (nonatomic, copy ) NSString *currentString;
@property (nonatomic, readwrite) BOOL downloadError;
@property (nonatomic, readwrite) BOOL endOfDocumentReached;

@end

@implementation XMLParser

@synthesize currentString;
@synthesize documents;
@synthesize currentItem;
@synthesize downloadError, endOfDocumentReached;

-(BOOL)isDone {
    
    return ((!self.downloadError)&&(self.endOfDocumentReached)&&(self.documents));
}

-(NSMutableArray *)parsedItems {
    
    return self.documents;
}

- (void)parseXMLFileAtURL:(NSURL *)url {	
	
	NSXMLParser * xmlParser = nil;
    NSData * xmlData = nil;
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.downloadError = NO;
    self.endOfDocumentReached = NO;

    xmlData = [NSData dataWithContentsOfURL:url];
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
	
	[xmlParser setDelegate:self];
	
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
	
    [xmlParser parse]; // Start parsing.
	
	[xmlParser release];
    
	[pool release];
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    
    NSMutableArray * documentsArray = [[NSMutableArray alloc] init];
	self.documents = documentsArray;
	[documentsArray release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	self.downloadError = YES;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{            
	
    NSMutableDictionary * dictionary = nil;
    
	if ([elementName isEqualToString:FPK_XML_PDF]) {
		
		// Create a new dictionary and release the old one (if necessary).
		dictionary = [[NSMutableDictionary alloc] init];
		self.currentItem = dictionary;
        [dictionary release];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	
	if ([elementName isEqualToString:FPK_XML_TITLE]) {
		
		[self.currentItem setValue:currentString forKey:FPK_XML_TITLE];
		
	} else if ([elementName isEqualToString:FPK_XML_LINK]) {
		
		[self.currentItem setValue:currentString forKey:FPK_XML_LINK];
		
	} else if ([elementName isEqualToString:FPK_XML_COVER]) {
		
		[self.currentItem setValue:currentString forKey:FPK_XML_COVER];
		
	} else if ([elementName isEqualToString:FPK_XML_PDF]) {
		
		[self.documents addObject:currentItem];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	
	self.currentString = string;
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
    self.endOfDocumentReached = YES;
}


- (void)dealloc {
	
	[documents release];
	
	[currentItem release];
	[currentString release];
	
    [super dealloc];
}


@end