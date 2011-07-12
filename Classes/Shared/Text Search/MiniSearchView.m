//
//  MiniSearchView.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/17/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "MiniSearchView.h"
#import "Stuff.h"
#import "DocumentViewController.h"
#import "SearchManager.h"
#import "MFTextItem.h"
#import "SearchResultView.h"
#import "NotificationFactory.h"

#define ZOOM_LEVEL 4.0

@interface MiniSearchView()

-(void)moveToNextResult;
-(void)moveToPrevResult;

@end


@implementation MiniSearchView

@synthesize nextButton;
@synthesize prevButton;
@synthesize cancelButton;
@synthesize fullButton;

@synthesize pageLabel;
@synthesize snippetLabel;

@synthesize documentDelegate, dataSource;
@synthesize searchResultView;

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
		
        // Initialization code.
		
		self.autoresizesSubviews = YES;		// Yes.
		self.opaque = NO;					// Otherwise background transparencies will be flat black.
		// Layout subviews.
		
		UIButton *aButton = nil;
		
		CGSize size = frame.size;
		UIFont *smallFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		
		UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width,size.height)];
		[image setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_back",@"png")]];
		[image setUserInteractionEnabled:NO];
		[image setBackgroundColor:[UIColor clearColor]];
		[self addSubview:image];
		[image release];
		
		
		// Next button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(size.width-30-2, 24, 30, 20);
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_next",@"png")] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_next",@"png")] forState:UIControlStateDisabled];
		[aButton setBackgroundColor:[UIColor clearColor]];
		[[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchUpInside];
		
		self.nextButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		// Prev button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(2, 24, 30, 20);
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_prev",@"png")] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_prev",@"png")] forState:UIControlStateDisabled];
		[aButton setBackgroundColor:[UIColor clearColor]];
		 //[aButton setTitle:@"<<" forState:UIControlStateNormal];
		//[aButton setTitle:@"<<" forState:UIControlStateDisabled];
		[[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionPrev:) forControlEvents:UIControlEventTouchUpInside];
		
		self.prevButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		
		// Cancel button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(size.width-30-2, 0, 30, 20);
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_cancel",@"png")] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_cancel",@"png")] forState:UIControlStateDisabled];
		[aButton setBackgroundColor:[UIColor clearColor]];
		 [[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
		
		self.cancelButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		
		// Full button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(2, 0, 30, 20);
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_full",@"png")] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"minisearch_full",@"png")] forState:UIControlStateDisabled];
		[aButton setBackgroundColor:[UIColor clearColor]];
		 [[aButton titleLabel]setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionFull:) forControlEvents:UIControlEventTouchUpInside];
		
		self.fullButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		SearchResultView *aSRV = [[SearchResultView alloc]initWithFrame:CGRectMake(30+2,2, size.width-30*2-2*4,size.height-5)];
		[aSRV setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		self.searchResultView = aSRV;
		[aSRV setBackgroundColor:[UIColor clearColor]];
		[self addSubview:aSRV];
		[aSRV release];
        
        
        // Register notification listeners.
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchDidStopNotification:) name:kNotificationSearchDidStop object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchGotCancelledNotification:) name:kNotificationSearchGotCancelled object:nil];
	}
	
    return self;
}

-(void) drawRect:(CGRect)rect {

	// We are going to draw a white rounded rect with a middle gray stroke color (like
	// the default rounded rect button).
	
	// Get the current context.
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Set fill and stroke colors.
	
	CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
	CGContextSetAllowsAntialiasing(ctx, 1);
	
	CGFloat radius = 10;	// Radius of the corners.
	
	// Draw a path resembling a rounded rect.
	
	CGContextBeginPath(ctx);
	CGContextAddArc(ctx, radius, radius, radius, M_PI, M_PI*3*0.5, 0);
	CGContextAddArc(ctx, rect.size.width-radius, radius, radius, M_PI*3*0.5, 0,0);
	CGContextAddArc(ctx, rect.size.width-radius, rect.size.height-radius, radius, 0, M_PI*0.5, 0);
	CGContextAddArc(ctx, radius, rect.size.height-radius, radius, M_PI*0.5, M_PI, 0);
	CGContextClosePath(ctx);
	CGContextDrawPath(ctx, kCGPathFillStroke);
	
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
