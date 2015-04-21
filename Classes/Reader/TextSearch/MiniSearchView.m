//
//  MiniSearchView.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 1/17/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "MiniSearchView.h"
#import "NotificationFactory.h"
#import "Stuff.h"
#import "DocumentViewController.h"
#import "SearchManager.h"
#import "SearchResultView.h"
#import "NotificationFactory.h"
#import "SearchManager.h"

#define ZOOM_LEVEL 4.0

@implementation MiniSearchView

- (void)segmentSwitch:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [self actionPrev:segmentedControl];
    }
    else{
        [self actionNext:segmentedControl];
    }
}

-(void)updateSearchResultViewWithItem:(FPKSearchMatchItem *)item {
    
    [self.searchResultView setSnippet:item.textItem.text boldRange:item.textItem.searchTermRange];
    self.searchResultView.pageNumberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)item.textItem.page];
}

-(void)reloadData {
	
	// This method basically set the current appaerance of the view to 
	// present the content of the Search Result pointed by currentSearchResultIndex.
    
    
	NSArray * searchResults = self.dataSource.allSearchResults;
	
    if(self.currentSearchResultIndex >= searchResults.count) {
        self.currentSearchResultIndex = searchResults.count - 1;
    }
    
	FPKSearchMatchItem * item = searchResults[self.currentSearchResultIndex];
    
	if(!item)
		return;
	
	// Update the content view.
	[self updateSearchResultViewWithItem:item];
    
}

-(void)setCurrentResultIndex:(NSUInteger)index {
	
	// This is more or less the same as the method above, just set the index
	// passed as parameter as the current index and then proceed accordingly.
	
    NSArray * searchResults = [self.dataSource allSearchResults];
	
	if(index >= searchResults.count) {
		index = searchResults.count - 1;
	}
	
	self.currentSearchResultIndex = index;
	
	    FPKSearchMatchItem * item = searchResults[self.currentSearchResultIndex];
	
    if(!item) {
		return;
    }
	
	[self updateSearchResultViewWithItem:item];
}

-(void)setCurrentTextItem:(FPKSearchMatchItem *)item {
	
	// Just an utility method to set the current index when just the item is know.
	
	NSUInteger index = [[self.dataSource allSearchResults] indexOfObject:item];
	
	[self setCurrentResultIndex:index];
}

-(void) moveToNextResult {
	
	
	// The same as the two similar methods above. It only differs in the fact that increase
	// the index by one, then proceed the same.
	NSArray * searchResults = [self.dataSource allSearchResults];

    
	self.currentSearchResultIndex++;
	
    if(self.currentSearchResultIndex == searchResults.count) {
		self.currentSearchResultIndex = 0;
    }
	
    FPKSearchMatchItem * item = [searchResults objectAtIndex:self.currentSearchResultIndex];
	
    if(!item) {
		return;
    }
	
	[self updateSearchResultViewWithItem:item];
	
    [self.delegate miniSearchView:self setPage:item.textItem.page zoomLevel:ZOOM_LEVEL rect:item.boundingBox];
}

-(void) moveToPrevResult {
    
	// As the above method, but it decrease the index instead.
	NSArray * searchResults = [self.dataSource allSearchResults];

    self.currentSearchResultIndex--;
	
    if(self.currentSearchResultIndex < 0) {
		self.currentSearchResultIndex = searchResults.count - 1;
    }
    
    FPKSearchMatchItem * item = [searchResults objectAtIndex:self.currentSearchResultIndex];
	
    if(!item) {
		return;
    }
	
	[self updateSearchResultViewWithItem:item];
	
    [self.delegate miniSearchView:self setPage:item.textItem.page zoomLevel:ZOOM_LEVEL rect:item.boundingBox];
}

#pragma mark - Search notification listeners

-(void)handleSearchDidStopNotification:(NSNotification *)notification {
    
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

-(void)handleSearchGotCancelledNotification:(NSNotification *)notification {
    // Setup the view accordingly.
	
    [self.delegate dismissMiniSearchView:self];
}

#pragma mark Actions

-(void)actionNext:(id)sender {
	
	// Tell the delegate to show the next result, eventually moving to a different page.
	
	[self moveToNextResult];
}

-(void)actionPrev:(id)sender {
	
	// Show the previous result, eventually moving to another page.
	
	[self moveToPrevResult];
}

-(void)actionCancel:(id)sender {
	
	// Tell the data source to stop the search.
	
	if(self.dataSource.running) {
		[self.dataSource stopSearch];
	}
}

-(void)actionFull:(id)sender {
	
    [self.delegate revertToFullSearchViewFromMiniSearchView:self];
}

#pragma mark -
#pragma mark View lifecycle
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
	
    if (self) {
        
        [self.subviews.lastObject removeFromSuperview];
        
        // Initialization code.
		
		self.autoresizesSubviews = YES;		// Yes.
		self.opaque = NO;					// Otherwise background transparencies will be flat black.
		// Layout subviews.
		
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        bar.barStyle = UIBarStyleBlack;
        bar.translucent = YES;
		
        UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 30)];
        
        [btnPrev setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"prew",@"png")] forState:UIControlStateNormal];
        
        [btnPrev addTarget:self action:@selector(actionPrev:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithCustomView:btnPrev];
        
        UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 30)];
        
        [btnNext setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"next",@"png")] forState:UIControlStateNormal];
        
        [btnNext addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:btnNext];
        
        
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(actionCancel:)];
		
        UIBarButtonItem *fullItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(actionFull:)];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
        
        [bar setItems:@[doneItem, flexibleSpace, prevItem,nextItem, fixedSpace, fullItem] animated:NO];
        
        [self addSubview:bar];
    }
	
    return self;
}

@end
