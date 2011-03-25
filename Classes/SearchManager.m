//
//  SearchManager.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/10/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "SearchManager.h"
#import "Stuff.h"
#import "TextSearchOperation.h"
#import "MFTextItem.h"
#import "MFDocumentViewController.h"

@interface SearchManager()

@property (nonatomic,retain) NSMutableArray * searchResults;
-(void)startSearchOperationForSearchTerm:(NSString*)term andPage:(NSUInteger)page;

@end


@implementation SearchManager

@synthesize document;
@synthesize searchTerm;
@synthesize searchResults;
@synthesize currentSearchOperation;
@synthesize delegate;
@synthesize currentSearchTerm;
@synthesize running;

#pragma mark -
#pragma mark SearchResultDelegate 

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page {
	
    // This method will get called when the document view controller will ask for drawables for the
	// page being displayed. In our case, the drawables - overlay items - are the highlighted bounding
	// box of the search result items.
	
	// Work on a copy of the current search results.
	
	NSArray *results = [searchResults copy];
	
	NSMutableArray *drawables = [[NSMutableArray alloc]init];
	
	// Now we will check the first element of each sub-array. Since every element in the array lay on
	// same page, if the first element is not on the right page we can discard the whole array.
	// It is not very clean but it is still better
	// than a plain linear search.
	
	for(NSArray * array in results) {
		
		MFTextItem *item = [array objectAtIndex:0];
		
		if([item page]==page)			
			[drawables addObjectsFromArray:array];
	}
	
	[results release];
	
	return [drawables autorelease];
}


#pragma mark -
#pragma mark Setters and getters

-(void)setDocument:(MFDocumentManager *)adocument{

	// Just set up the document and max number of page.
	
	if(adocument!=document) {
		
		[document release];
		document = [adocument retain];
		
		maxPage = [document numberOfPages];
	}
}

-(NSArray *)searchResultsAsPlainArray {

	NSMutableArray *plainResults = [NSMutableArray array];
	
	for(NSArray *  array in searchResults) {
		[plainResults addObjectsFromArray:array];
	}
	
	return plainResults;
}

#pragma mark -
#pragma mark Search methods

int calculateNextSearchPage(currentPage,maxPage) {

	// This is just an utility method used to calculate the next page, returning to the
	// first one - 0 actually - when the last one is exceeded, like in circular buffers.
	
	return (currentPage+1)%(maxPage+1);
}

-(void)cancelSearch {

	// Cancel the search.
	
	if(running) {
		
		[self stopSearch];
	}
	
	// Reset the status of the search. 
	
	currentPage = 0;
	startingPage = 0;
	
	// Reset the data.
	
	self.searchTerm = nil;
	[searchResults removeAllObjects];
	
	// Inform the delegate of the cancel event, so it can
	// update itself.
	[delegate searchGotCancelled];
}

-(void)stopSearch {
	
	// Stop the search, but keep in memory the status of the operation. We are likely to
	// keep accessing it even after the search has been stopped.
	
	if(!(running)) 
	   return;
	   
	running = NO;
	stopped = YES;
	
	[self.currentSearchOperation cancel], self.currentSearchOperation = nil;
	
	[delegate searchDidStop];
}


// Callback for the op.
-(void)handleSearchResult:(NSArray *)searchResult {

	if (stopped) {
	
		// Ignore the result.
		
	} else if (running) {

		// Append the result and notify the delegate.
		
		if(searchResult!=nil) {
			[searchResults addObject:searchResult];
			[delegate updateResults:searchResults withResults:searchResult forPage:currentPage];
		}
		
		// If we endend up on the starting page we can stop, otherwise take the next page and 
		// search on it too.
		
		currentPage = calculateNextSearchPage(currentPage,maxPage);
		
		if(currentPage != startingPage) {
			
			// Keep searching on the next page.
			
			[self startSearchOperationForSearchTerm:self.searchTerm andPage:currentPage];
			
		} else {
			
			// Just stop.
			
			stopped = YES;
			running = NO;
			
			[delegate searchDidStop];
		}
		
	} 
}

-(void)startSearchOperationForSearchTerm:(NSString*)term andPage:(NSUInteger)page {

	// Utility method to set up the search operation with the right parameters.
	
	TextSearchOperation * operation = [[TextSearchOperation alloc]init];
	
	// We use a local profile to configure the operation profile that will be used with the document
	// manager search method. The profile is copied to TextOperation, so we would be also able to use
	// a dynamically allocated one and release it afterwards.
	
	MFProfile profile;
	initProfile(&profile);	// Default initializer;
	// initProfileWithSettings(&profile, 0, 1, 3, 0, 1, 1, 0, 1); // Custom initializer. Look at mfprofile.h for details.
	
	operation.page = page;				// Page number.
	operation.searchTerm = term;		// Search term.
	operation.delegate = self;			// Delegate for handling the results.
	operation.document = self.document;	// Document.
	operation.profile = profile;
	
	// Save the search term.
	
	self.currentSearchTerm = term;		
	
	// Set the operation as the current one and add it to the operation queue.
	
	self.currentSearchOperation = operation;	
	[searchOperationQueue addOperation:operation];	
	
	[operation release];
}

-(void)startSearchOfTerm:(NSString *)term fromPage:(NSUInteger)aStartingPage {
	
	// Start the sarch.
	
	// Save the sarch term and set the starting and current page to the page passed as argument. We will
	// cycle over the entire document until we get back to the starting page.
	
	self.searchTerm = term;
	
	startingPage = aStartingPage;
	currentPage = aStartingPage;
	
	// Set the status flags.
	
	running = YES;
	stopped = NO;
	
	// Allocate a new mutable array to not modify the precedent one in the case it has been
	// retained by another object.
	NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
	self.searchResults = tmpArray;
	[tmpArray release];
	
	// Call the utility method to start a search operation.
	[self startSearchOperationForSearchTerm:term andPage:aStartingPage];
	
	// Notify the delegate.
	[delegate searchDidStart];
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    
    self = [super init];
    if (self) {
		
		// Only a single search operation at time.
        searchOperationQueue = [[NSOperationQueue alloc]init];
		[searchOperationQueue setMaxConcurrentOperationCount:1];
		
		// This will be allocated anew when a search operation begin, but
		// is better be safe than sorry.
		searchResults = [[NSMutableArray alloc]init];
		
    }
    return self;
}


- (void)dealloc {
	
	delegate = nil;
	
	MF_COCOA_RELEASE(document);
	
	MF_COCOA_RELEASE(searchTerm);
	MF_COCOA_RELEASE(searchResults);
	
	MF_COCOA_RELEASE(currentSearchOperation);
	MF_COCOA_RELEASE(searchOperationQueue);
	
	MF_COCOA_RELEASE(currentSearchTerm);
	
    [super dealloc];
}


@end
