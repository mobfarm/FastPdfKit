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
#import "NotificationFactory.h"

#define FPK_SRCMGR_STATUS_CANCELLED 0
#define FPK_SRCMGR_STATUS_ONGOING 1
#define FPK_SRCMGR_STATUS_STOPPED 2

#define FPK_SRCMGR_STATUS_IS_CANCELLED(x) ((x) == FPK_SRCMGR_STATUS_CANCELLED)
#define FPK_SRCMGR_STATUS_IS_GOING_ON(x) ((x) == FPK_SRCMGR_STATUS_ONGOING)
#define FPK_SRCMGR_STATUS_IS_STOPPED(x) ((x) == FPK_SRCMGR_STATUS_STOPPED)

#define FPK_SRCMGR_STATUS_CANCEL(x) ((x) = FPK_SRCMGR_STATUS_CANCELLED)
#define FPK_SRCMGR_STATUS_GO_ON(x) ((x) = FPK_SRCMGR_STATUS_ONGOING)
#define FPK_SRCMGR_STATUS_STOP(x) ((x) = FPK_SRCMGR_STATUS_STOPPED)

@interface SearchManager()

-(void)startSearchOperationForSearchTerm:(NSString*)term andPage:(NSUInteger)page;

@end

@implementation SearchManager

@synthesize document;
@synthesize searchTerm;
@synthesize searchResults;
@synthesize currentSearchOperation;
@synthesize currentSearchTerm;

#pragma mark -
#pragma mark SearchResultDelegate 

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page {
	
    // This method will get called when the document view controller will ask for drawables for the
	// page being displayed. In our case, the drawables - overlay items - are the highlighted bounding
	// box of the search result items.
	
	NSArray *results = nil; 
    NSMutableArray * drawables = nil;
    MFTextItem * item = nil;
    
    if(FPK_SRCMGR_STATUS_IS_CANCELLED(status))
        return nil;
    
    results = [searchResults copy]; // We are going to enumerate the array while the search is going on, so a copy is necessary.
	
	drawables = [[NSMutableArray alloc]init];
	
	// Now we will check the first element of each sub-array. Since every element in the array lay on
	// same page, if the first element is not on the right page we can discard the whole array.
	// Then we can set the color of the search result to a color that suit us better. Default is a mild red.
    
	for(NSArray * array in results) {
		
		item = [array objectAtIndex:0];
        
		if([item page] == page) {
        
            for(MFTextItem * item in array) {
                item.highlightColor = [MFTextItem highlightRedColor];
            }
            
            [drawables addObjectsFromArray:array];    
        }
	}
	
	[results release];
	
	return [drawables autorelease];
}


#pragma mark -
#pragma mark Setters and getters

-(BOOL)isRunning {
    return FPK_SRCMGR_STATUS_IS_GOING_ON(status);
}

-(BOOL)isCancelled {
    return FPK_SRCMGR_STATUS_IS_CANCELLED(status);
}

-(BOOL)isStopped {
    return FPK_SRCMGR_STATUS_IS_STOPPED(status);
}

-(void)setDocument:(MFDocumentManager *)adocument{

	// Just set up the document and max number of page.
	
	if(adocument!=document) {
		
		[document release];
		document = [adocument retain];
		
		maxPage = [document numberOfPages];
	}
}

-(NSArray *)searchResultsAsPlainArray {
    
    // As the name suggest, we are going to 'un-nest' the search result items.

	NSMutableArray *plainResults = [NSMutableArray array];
	
	for(NSArray *  array in searchResults) {
		[plainResults addObjectsFromArray:array];
	}
	
	return plainResults;
}

#pragma mark -
#pragma mark Search methods

int calculateNextSearchPage(int currentPage, int maxPage) {

	// This is just an utility method used to calculate the next page, returning to the
	// first one - 0 actually - when the last one is exceeded, like in circular buffers.
	
	return (currentPage+1)%(maxPage+1);
}

-(void)cancelSearch {

	// Cancel the search.
	NSNotification * notification = nil;
    
	if(FPK_SRCMGR_STATUS_IS_GOING_ON(status)) {
		
		[self stopSearch];
	}
	
    FPK_SRCMGR_STATUS_CANCEL(status);
    
	// Reset the status of the search. 
	
	currentPage = 0;
	startingPage = 0;
	
	// Reset the data.
	
	self.searchTerm = nil;
    self.searchResults = nil;
	
	// Send a notification of the cancel event, so it can
	// update itself.
    
    notification = [NotificationFactory notificationSearchGotCancelledWithSearchTerm:searchTerm fromSender:self];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

-(void)stopSearch {
	
	// Stop the search, but keep in memory the status of the operation. We are likely to
	// keep accessing it even after the search has been stopped.
    
	NSNotification * notification = nil;
    
	if(FPK_SRCMGR_STATUS_IS_GOING_ON(status)) {
	   
        FPK_SRCMGR_STATUS_STOP(status);
	
        [self.currentSearchOperation cancel];
	
        notification = [NotificationFactory notificationSearchDidStopWithSearchTerm:searchTerm fromSender:self];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
        
    }
}


// Callback for the op.
-(void)handleSearchResult:(NSArray *)searchResult {

    NSNotification * notification = nil;
    
	if (FPK_SRCMGR_STATUS_IS_STOPPED(status)) {
	
		// Ignore the result.
		
	} else if (FPK_SRCMGR_STATUS_IS_GOING_ON(status)) {

		// Append the result and notify the delegate.
		
		if(searchResult!=nil) {
			
            [searchResults addObject:searchResult];
            
            notification = [NotificationFactory notificationSearchResultsAvailable:searchResults forSearchTerm:searchTerm onPage:[NSNumber numberWithInt:currentPage] fromSender:self];
            [[NSNotificationCenter defaultCenter]postNotification:notification];
		}
		
		// If we endend up on the starting page we can stop, otherwise take the next page and 
		// search on it too.
		
		currentPage = calculateNextSearchPage(currentPage,maxPage);
		
		if(currentPage != startingPage) {
			
			// Keep searching on the next page.
			
			[self startSearchOperationForSearchTerm:self.searchTerm andPage:currentPage];
			
		} else {
			
			// Just stop.
			FPK_SRCMGR_STATUS_STOP(status);
            
            notification = [NotificationFactory notificationSearchDidStopWithSearchTerm:searchTerm fromSender:self];
            [[NSNotificationCenter defaultCenter]postNotification:notification];
            
		}
		
	} 
}

-(void)startSearchOperationForSearchTerm:(NSString*)term andPage:(NSUInteger)page {

	// Utility method to set up the search operation with the right parameters.
	
	TextSearchOperation * operation = [[TextSearchOperation alloc]init];
	
    // Save the search term.
	
    self.currentSearchTerm = term;		
	
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
	operation.profile = profile;        // This is going to be ignored if you use the test_ version of the search.
	
	// Set the operation as the current one and add it to the operation queue.
	
	self.currentSearchOperation = operation;	
	[searchOperationQueue addOperation:operation];	
	
	[operation release];
}

-(void)startSearchOfTerm:(NSString *)term fromPage:(NSUInteger)aStartingPage {
	
    NSNotification * notification = nil;
    NSMutableArray * tmpArray = nil;
    
	// Start the sarch.
	
	// Save the sarch term and set the starting and current page to the page passed as argument. We will
	// cycle over the entire document until we get back to the starting page.
	
	self.searchTerm = term;
	
	startingPage = aStartingPage;
	currentPage = aStartingPage;
	
	// Set the status flags.
	
    FPK_SRCMGR_STATUS_GO_ON(status);
	
	// Allocate a new mutable array to not modify the precedent one in the case it has been
	// retained by another object.
	tmpArray = [[NSMutableArray alloc]init];
	self.searchResults = tmpArray;
	[tmpArray release];
	
	// Call the utility method to start a search operation and notify the event.
    
    notification = [NotificationFactory notificationSearchDidStartWithSearchTerm:searchTerm onPage:[NSNumber numberWithInt:aStartingPage] fromSender:self];
    
	[self startSearchOperationForSearchTerm:term andPage:aStartingPage];
	
    [[NSNotificationCenter defaultCenter]postNotification:notification];
    
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    
    self = [super init];
    if (self) {
		
		// Only a single search operation at time.
        searchOperationQueue = [[NSOperationQueue alloc]init];
		[searchOperationQueue setMaxConcurrentOperationCount:1];
		
		status = FPK_SRCMGR_STATUS_CANCELLED;
    }
    
    return self;
}


- (void)dealloc {
	
	MF_COCOA_RELEASE(document);
	
	MF_COCOA_RELEASE(searchTerm);
	MF_COCOA_RELEASE(searchResults);
	
	MF_COCOA_RELEASE(currentSearchOperation);
	MF_COCOA_RELEASE(searchOperationQueue);
	
	MF_COCOA_RELEASE(currentSearchTerm);
	
    [super dealloc];
}


@end
