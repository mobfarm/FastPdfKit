//
//  SearchManager.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/10/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultDelegate.h"
#import "MFDocumentOverlayDataSource.h"

@class MFDocumentManager;

@interface SearchManager : UIView <MFDocumentOverlayDataSource> {

	// Status.
	
	BOOL stopped;
	BOOL running;
	
	// Data.
	NSUInteger startingPage;		// Starting page for the sarch.
	NSUInteger maxPage;				// Max page of the document.
	NSUInteger currentPage;			// Current page.
	NSString * currentSearchTerm;	// Current search term.
	
	// Concurrent operations.
	NSOperation * currentSearchOperation;		// Reference to the current op.
	NSOperationQueue * searchOperationQueue;	// The operation queue.
	
	MFDocumentManager * document;	// Our document.
	
	NSMutableArray * searchResults;	// Array of results. It's an array of array.
}

@property (nonatomic,retain) NSOperation * currentSearchOperation;
@property (nonatomic,retain) MFDocumentManager * document;
@property (nonatomic,copy) NSString * searchTerm;
@property (nonatomic,retain) NSMutableArray * searchResults;
@property (nonatomic,copy) NSString *currentSearchTerm;
@property (nonatomic,readwrite,getter=isRunning) BOOL running;

-(NSArray *)searchResultsAsPlainArray;
-(void)stopSearch;
-(void)startSearchOfTerm:(NSString *)term fromPage:(NSUInteger)startingPage;
-(void)cancelSearch;
@end
