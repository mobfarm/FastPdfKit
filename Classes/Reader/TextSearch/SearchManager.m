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
#import "FPKSearchMatchItem.h"
#import "MFDocumentViewController.h"
#import "MFDocumentManager.h"

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

@property (nonatomic, readwrite) NSUInteger currentPage;
@property (nonatomic, readwrite) NSArray * allSearchResults;
@end

@implementation SearchManager

#pragma mark - FPKOverlayViewDataSource

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page {
    
    NSArray * results = self.pagedSearchResults[@(page)];
    
    if(!results) {
        return nil;
    }
    
    NSMutableArray * newViews = [NSMutableArray new];
    
    for(FPKSearchMatchItem * item in results) {
        UIView * view = item.highlightView;
        [newViews addObject:view];
    }
    
    return [NSArray arrayWithArray:newViews];
}

-(CGRect)documentViewController:(MFDocumentViewController *)dvc rectForOverlayView:(UIView *)view onPage:(NSUInteger)page {

    NSArray * results = self.pagedSearchResults[@(page)];
    
    if(!results) {
        return CGRectNull;
    }
    
    for(FPKSearchMatchItem * item in results) {
        if(view == item.highlightView) {
            return item.boundingBox;
        }
    }
    
    return CGRectNull;
}

#pragma mark - SearchResultDelegate

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page {
    
    return self.pagedSearchResults[@(page)];
}

-(BOOL)isRunning {
    return self.running;
}

-(BOOL)isCancelled {
    return (!self.running);
}

-(BOOL)isStopped {
    return (!self.running);
}

-(void)setDocument:(MFDocumentManager *)document {
    if(_document != document) {
        _document = document;
        self.maxPage = document.numberOfPages;
    }
}

-(NSArray *)searchResultOnPage:(NSUInteger)page {
    return self.pagedSearchResults[@(page)];
}

-(NSArray *)searchResultsAsPlainArray {
    return [self allSearchResults];
}

-(NSArray *)allSearchResults {

    if(_allSearchResults == nil) {
        
        NSMutableArray *allResults = [NSMutableArray array];
        
        for (NSArray * results in self.sequentialSearchResults) {
            [allResults addObjectsFromArray:results];
        }
        
        _allSearchResults = allResults;
    }
    
    return _allSearchResults;
}

#pragma mark - Search methods

/**
 * Same sa calling stop.
 */
-(void)cancelSearch {

    [self stopSearch];
}

/**
 * Stop the search.
 */
-(void)stopSearch {
    
    if(self.running) {
        
        self.running = NO;
        
        NSDictionary *  info = @{kNotificationSearchInfoSearchTerm:self.searchTerm};
        
        NSNotification * notification = [NSNotification notificationWithName:kNotificationSearchDidStop object:self userInfo:info];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

-(void)continueSearchIfNeeded {
    
    // If we endend up on the starting page we can stop, otherwise take the next page and
    // search on it too.
    NSUInteger nextPage = self.currentPage + 1;
    if(nextPage == self.maxPage) {
        if(self.loop) {
            nextPage = 1;
        } else {
            [self stopSearch];
            return;
        }
    }
    
    if(nextPage == self.currentPage || nextPage == self.startingPage) {
        [self stopSearch];
        return;
    }
    
    self.currentPage = nextPage;
    [self searchForTerm:self.searchTerm page:self.currentPage];
}

// Callback for the op.
-(void)handleSearchResult:(NSArray *)searchResult page:(NSUInteger)page {
    
    if(!self.running) {
        return;
    }
    
    if(searchResult && (page == self.currentPage)) {
        
        NSArray * matches = [FPKSearchMatchItem searchMatchItemsWithTextItems:searchResult];
        
        self.pagedSearchResults[@(page)] = matches;
        [self.sequentialSearchResults addObject:matches];
        self.allSearchResults = nil;
        
        NSDictionary * info = @{ kNotificationSearchInfoPage:@(page),
                                 kNotificationSearchInfoResults:matches,
                                 kNotificationSearchInfoSearchTerm:self.searchTerm
                                 };
        
        NSNotification * notification = [NSNotification notificationWithName:kNotificationSearchResultAvailable
                                                                      object:self
                                                                    userInfo:info];
        
        [[NSNotificationCenter defaultCenter]postNotification:notification];
    }
    
    [self continueSearchIfNeeded];
}

-(void)searchForTerm:(NSString*)term page:(NSUInteger)page {

    SearchManager __weak * this = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        // 1. If the search has been stopped while enqueue, return immediately
        if(!this.running) {
            return;
        }
        
        // 2. Get the results
        NSArray * results = [this.document searchResultOnPage:page
                                               forSearchTerms:term
                                                         mode:FPKSearchModeSoft
                                                   ignoreCase:self.ignoreCase
                                                   exactMatch:self.exactMatch];
        
        // 3. Handle the results on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [this handleSearchResult:results page:page];
        });
    });
}

-(void)startSearch {
    
    if(self.running) {
        return; // Already running
    }

    self.running = true;
    self.currentPage = self.startingPage;
    
    // Notify that search is starting
    NSDictionary * info = @{kNotificationSearchInfoPage:@(self.startingPage),
                            kNotificationSearchInfoSearchTerm:self.searchTerm};
    NSNotification * notification = [NSNotification notificationWithName:kNotificationSearchDidStart object:self userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    // Start the search
	[self searchForTerm:self.searchTerm page:self.currentPage];
}

#pragma mark - Lifecycle

-(instancetype)init {
    self = [super init];
    if(self) {
        self.pagedSearchResults = [NSMutableDictionary new];
        self.sequentialSearchResults = [NSMutableArray new];
        self.allSearchResults = nil; // Lazy
    }
    return self;
}

-(void)dealloc {
    
    [self stopSearch];
}

@end
