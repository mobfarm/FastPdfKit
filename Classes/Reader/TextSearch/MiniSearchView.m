//
//  MiniSearchView.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/17/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "MiniSearchView.h"
#import "NotificationFactory.h"
#import "Stuff.h"
#import "DocumentViewController.h"
#import "SearchManager.h"
#import "MFTextItem.h"
#import "SearchResultView.h"
#import "NotificationFactory.h"

#define ZOOM_LEVEL 4.0

@implementation MiniSearchView

@synthesize nextButton;
@synthesize prevButton;
@synthesize cancelButton;
@synthesize fullButton;

@synthesize pageLabel;
@synthesize snippetLabel;

@synthesize documentDelegate, dataSource;
@synthesize searchResultView;

- (void)segmentSwitch:(id)sender {
    NSLog(@"Action");
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [self actionPrev:segmentedControl];
    }
    else{
        [self actionNext:segmentedControl];
    }
}

-(void)updateSearchResultViewWithItem:(MFTextItem *)item {
    
	self.searchResultView.page = item.page;
	self.searchResultView.text = item.text;
	self.searchResultView.boldRange = item.searchTermRange;
}

-(void)reloadData {
	
	// This method basically set the current appaerance of the view to 
	// present the content of the Search Result pointed by currentSearchResultIndex.
    
    MFTextItem * item = nil;
	NSArray * searchResults = nil;
    
    searchResults = [dataSource searchResultsAsPlainArray];
	
    if(currentSearchResultIndex >= [searchResults count]) {
        currentSearchResultIndex = [searchResults count] - 1;
    }
    
	item = [searchResults objectAtIndex:currentSearchResultIndex];
    
	if(!item)
		return;
	
	// Update the content view.
	[self updateSearchResultViewWithItem:item];
    
}

-(void)setCurrentResultIndex:(NSUInteger)index {
	
	// This is more or less the same as the method above, just set the index
	// passed as parameter as the current index and then proceed accordingly.
	
    MFTextItem * item = nil;
    NSArray * searchResults = nil;
    
    searchResults = [dataSource searchResultsAsPlainArray];
	
	if(index >= [searchResults count]) {
		index = [searchResults count] - 1;
	}
	
	currentSearchResultIndex = index;
	
	item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(!item)
		return;
	
	[self updateSearchResultViewWithItem:item];
}

-(void)setCurrentTextItem:(MFTextItem *)item {
	
	// Just an utility method to set the current index when just the item is know.
	
	NSUInteger index = [[dataSource searchResultsAsPlainArray] indexOfObject:item];
	
	[self setCurrentResultIndex:index];
}

-(void) moveToNextResult {
	
	
	// The same as the two similar methods above. It only differs in the fact that increase
	// the index by one, then proceed the same.
	NSArray * searchResults = [dataSource searchResultsAsPlainArray];
    MFTextItem * item = nil;
    
	currentSearchResultIndex++;
	
	if(currentSearchResultIndex == [searchResults count])
		currentSearchResultIndex = 0;
	
	item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(!item)
		return;
	
	[self updateSearchResultViewWithItem:item];
	
	[documentDelegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];
	
}

-(void) moveToPrevResult {
    
	// As the above method, but it decrease the index instead.
	NSArray * searchResults = [dataSource searchResultsAsPlainArray];
    MFTextItem * item = nil;
    
	currentSearchResultIndex--;
	
	if(currentSearchResultIndex < 0)
		currentSearchResultIndex = [searchResults count]-1;
	
	item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(!item)
		return;
	
	[self updateSearchResultViewWithItem:item];
	
	[documentDelegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];
}

#pragma mark - Search notification listeners

-(void)handleSearchDidStopNotification:(NSNotification *)notification {
    
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

-(void)handleSearchGotCancelledNotification:(NSNotification *)notification {
    // Setup the view accordingly.
	
	[documentDelegate dismissMiniSearchView];
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
	
	if([dataSource isRunning]) {
		[dataSource stopSearch];
	} else {
		[dataSource cancelSearch];
	}
}

-(void)actionFull:(id)sender {
	
	// Tell the delegate to dismiss this mini view and present the full table view.
	
	[documentDelegate revertToFullSearchView];
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
        [bar setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
        [bar setBarStyle:UIBarStyleBlack];
        [bar setTranslucent:YES];
		
        /*NSArray *items = [NSArray arrayWithObjects:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"prew",@"png")], [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"next",@"png")], nil];
        UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:items];
        [segControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [segControl addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventValueChanged];
        [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segControl setMomentary:YES];
        [self addSubview:segControl];
        [segControl release];
         */
        
        UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 30)];
        
        [btnPrev setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"prew",@"png")] forState:UIControlStateNormal];
        
        [btnPrev addTarget:self action:@selector(actionPrev:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithCustomView:btnPrev];
        
        UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 30)];
        
        [btnNext setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"next",@"png")] forState:UIControlStateNormal];
        
        [btnNext addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:btnNext];
        
        
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(actionCancel:)];
		
        UIBarButtonItem *fullItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(actionFull:)];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        
        [bar setItems:[NSArray arrayWithObjects:doneItem, flexibleSpace, prevItem,nextItem, fixedSpace, fullItem, nil] animated:NO];
        [flexibleSpace release];
        [fixedSpace release];
        [prevItem release];
        [nextItem release];
        [doneItem release];
        [fullItem release];
        [btnNext release];
        [btnPrev release];
        
        [self addSubview:bar];
        [bar release];
        
        
        // Register notification listeners.
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchDidStopNotification:) name:kNotificationSearchDidStop object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchGotCancelledNotification:) name:kNotificationSearchGotCancelled object:nil];
    }
	
    return self;
}


- (void)dealloc {
	
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
	MF_COCOA_RELEASE(nextButton);
	MF_COCOA_RELEASE(prevButton);
	MF_COCOA_RELEASE(fullButton);
	MF_COCOA_RELEASE(cancelButton);
    
	MF_COCOA_RELEASE(pageLabel);
	MF_COCOA_RELEASE(snippetLabel);
	
	MF_COCOA_RELEASE(searchResultView);
	
    [super dealloc];
}


@end
