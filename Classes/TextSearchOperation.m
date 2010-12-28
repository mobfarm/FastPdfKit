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

-(void)main {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	MFSearchResult *searchResult = [[document searchResultOnPage:page forSearchTerms:searchTerm]retain];
	
	if(![self isCancelled]) {
		
		if([delegate respondsToSelector:@selector(handleSearchResult:)])
			[delegate performSelectorOnMainThread:@selector(handleSearchResult:) withObject:searchResult waitUntilDone:YES];
	}
	
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
