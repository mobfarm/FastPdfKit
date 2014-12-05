//
//  MFSearchOperation.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "TextSearchOperation.h"
#import "MFDocumentManager.h"

@implementation TextSearchOperation
@synthesize page, searchTerm, delegate, document;
@synthesize profile;
@synthesize exactMatch, ignoreCase;

-(void)main 
{	
	// Allocate an autorelease pool.
	
	@autoreleasepool {
        
        NSArray *searchResult = [document searchResultOnPage:page
                                               forSearchTerms:searchTerm
                                                   ignoreCase:ignoreCase
                                                   exactMatch:exactMatch];
        
        if(![self isCancelled])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [delegate handleSearchResult:searchResult];
            });
        }
    }
}

-(void)dealloc 
{	
	self.delegate = nil;
	
    [searchTerm release];
    [document release];
    
	[super dealloc];
}

@end
