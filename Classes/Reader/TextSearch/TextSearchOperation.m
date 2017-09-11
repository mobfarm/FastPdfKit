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

-(void)main 
{	
	// Allocate an autorelease pool.
	
	@autoreleasepool {
        
        NSArray *searchResult = [self.document searchResultOnPage:self.page
                                               forSearchTerms:self.searchTerm
                                                   ignoreCase:self.ignoreCase
                                                   exactMatch:self.exactMatch];
        
        if([self isCancelled])
        {
            return;
        }
        
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [_delegate handleSearchResult:searchResult];
            });
    }
}

@end
