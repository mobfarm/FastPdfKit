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
            SEL selector = NSSelectorFromString(@"handleSearchResult:");
            if([delegate respondsToSelector:selector])
                [(NSObject *)delegate performSelectorOnMainThread:selector withObject:searchResult waitUntilDone:YES];
        }
    }
}

-(void)dealloc 
{	
	self.delegate = nil;
	
}

@end
