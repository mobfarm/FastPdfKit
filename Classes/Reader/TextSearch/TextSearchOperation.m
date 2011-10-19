//
//  MFSearchOperation.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "TextSearchOperation.h"
#import "MFDocumentManager.h"

@implementation TextSearchOperation
@synthesize page, searchTerm, delegate, document;
@synthesize profile;

-(void)main {
	
	// Allocate an autorelease pool.
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	// Get the search result from the document.
	
    
    // Get the result from the document.
    NSArray *searchResult = [[document searchResultOnPage:page forSearchTerms:searchTerm]copy];
    
	if(![self isCancelled]) {
		
		if([delegate respondsToSelector:@selector(handleSearchResult:)])
			[(NSObject *)delegate performSelectorOnMainThread:@selector(handleSearchResult:) withObject:searchResult waitUntilDone:YES];
	}
	
	
	// Cleanup.
	
	[searchResult release];
	[pool release];
}

-(void)dealloc {
	
	[document release],document = nil;
	delegate = nil;
	[searchTerm release],searchTerm = nil;
	[super dealloc];
}

@end
