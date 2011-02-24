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

#define ZOOM_LEVEL 4.0

@interface MiniSearchView()

-(void)moveToNextResult;
-(void)moveToPrevResult;

@property (nonatomic,retain) NSMutableArray * searchResults;

@end


@implementation MiniSearchView

@synthesize nextButton;
@synthesize prevButton;
@synthesize cancelButton;
@synthesize fullButton;

@synthesize pageLabel;
@synthesize snippetLabel;

@synthesize documentDelegate, dataSource;
@synthesize searchResults;
@synthesize searchResultView;

-(void)updateSearchResultViewWithItem:(MFTextItem *)item {

	self.searchResultView.page = item.page;
	self.searchResultView.text = item.text;
	self.searchResultView.boldRange = item.searchTermRange;
}

-(void)reloadData {
	
	// This method basically set the current appaerance of the view to 
	// present the content of the Search Result pointed by currentSearchResultIndex.

	self.searchResults = [[dataSource searchResultsAsPlainArray]mutableCopy];
	
	MFTextItem *item = [searchResults objectAtIndex:currentSearchResultIndex];
	if(item==nil)
		return;
	
	// Update the content view.
	[self updateSearchResultViewWithItem:item];
	
	
	// Disable/enabled the next and previous button depeding on the current index
	// inside the result array.
	
	if(currentSearchResultIndex + 1 < [searchResults count]) {
		
		[nextButton setEnabled:YES];
	} else {
		
		[nextButton setEnabled:NO];
	}
	if(currentSearchResultIndex > 0) {
		[prevButton setEnabled:YES];
	} else {
		[prevButton setEnabled:NO];
	}	
}

-(void)setCurrentResultIndex:(NSUInteger)index {
	
	// This is more or less the same as the method above, just set the index
	// passed as parameter as the current index and then proceed accordingly.
	
	if(index >= [searchResults count]) {
		return;
	}
	
	currentSearchResultIndex = index;
	
	MFTextItem *item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(item==nil)
		return;
	
	[self updateSearchResultViewWithItem:item];
	
	if(currentSearchResultIndex + 1 < [searchResults count]) {
		
		[nextButton setEnabled:YES];
	} else {
		
		[nextButton setEnabled:NO];
	}
	if(currentSearchResultIndex > 0) {
		
		[prevButton setEnabled:YES];
	} else {
		
		[prevButton setEnabled:NO];
	}
}

-(void)setCurrentTextItem:(MFTextItem *)item {
	
	// Just an utility method to set the current index when just the item is know.
	
	NSUInteger index = [searchResults indexOfObject:item];
	
	[self setCurrentResultIndex:index];
}

-(void) moveToNextResult {
	
	
	// The same as the two similar methods above. It only differs in the fact that increase
	// the index by one, then proceed the same.
	
	currentSearchResultIndex++;
	
	MFTextItem *item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(item==nil)
		return;
	
	[self updateSearchResultViewWithItem:item];
	
	[documentDelegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];
	
	// Update prev/next buttons.
	
	if(currentSearchResultIndex + 1 < [searchResults count]) {
		
		
		[nextButton setEnabled:YES];
	} else {
		
		[nextButton setEnabled:NO];
	}
	if(currentSearchResultIndex > 0) {
		[prevButton setEnabled:YES];
	} else {
		[prevButton setEnabled:NO];
	}
}

-(void) moveToPrevResult {

	// As the above method, but it decrease the index instead.
	
	currentSearchResultIndex--;
	
	MFTextItem *item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(item==nil)
		return;
	
	[self updateSearchResultViewWithItem:item];
	
	[documentDelegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];
	
	
	// Update prev/next buttons.
	
	if(currentSearchResultIndex + 1 < [searchResults count]) {
		
		
		[nextButton setEnabled:YES];
	} else {
		
		[nextButton setEnabled:NO];
	}
	if(currentSearchResultIndex > 0) {
		[prevButton setEnabled:YES];
	} else {
		[prevButton setEnabled:NO];
	}
}

#pragma mark SearchResultDelegate

-(void) updateResults:(NSArray *)aSearchResult withResults:(NSArray *)addedResult forPage:(NSUInteger)page {
	
	// When a new array of results arrives, its content is added to searchResults array, then the view is updated.
	
	if([addedResult count] > 0) {
		
		[searchResults addObjectsFromArray:addedResult];
		
		// Update prev/next buttons, for example by enabling buttons disabled
		// due to being on the bound before the update.
		
		if(currentSearchResultIndex + 1 < [searchResults count]) {
			
			
			[nextButton setEnabled:YES];
		} else {
			
			[nextButton setEnabled:NO];
		}
		if(currentSearchResultIndex > 0) {
			[prevButton setEnabled:YES];
		} else {
			[prevButton setEnabled:NO];
		}
		
	} else {
			// Do nothing.
	}
}

#pragma mark -
#pragma mark SearchManager callbacks

-(void) searchDidPause {
	// Unsupported.
}

-(void) searchDidStart {
	// Never called with the mini view in place.
}

-(void) searchDidResume {
	// Unsupported.
}

-(void) searchGotCancelled {
	
	// We are going to remove this view from the stack.
	
	[documentDelegate dismissMiniSearchView];
}

-(void) searchDidStop {
	
	// Searching is going on no more, set the cancel button title accordingly.
	
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
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
		searchResults = [[NSMutableArray alloc]init];
		
		self.autoresizesSubviews = YES;		// Yes.
		self.opaque = NO;					// Otherwise background transparencies will be flat black.
		
		// Layout subviews.
		
		UIButton *aButton = nil;
		
		CGSize size = frame.size;
		UIFont *smallFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		
		UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width,size.height)];
		[image setImage:[UIImage imageNamed:@"minisearch_back.png"]];
		[image setUserInteractionEnabled:NO];
		[self addSubview:image];
		[image release];
		
		
		// Next button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(size.width-38, size.height-28, 30, 20);
		[aButton setImage:[UIImage imageNamed:@"minisearch_next.png"] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageNamed:@"minisearch_next.png"] forState:UIControlStateDisabled];
		[[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchUpInside];
		
		self.nextButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		// Prev button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(8, size.height-28, 30, 20);
		[aButton setImage:[UIImage imageNamed:@"minisearch_prev.png"] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageNamed:@"minisearch_prev.png"] forState:UIControlStateDisabled];
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
		aButton.frame = CGRectMake(size.width*0.5-(2+60), size.height-28, 60, 20);
		[aButton setImage:[UIImage imageNamed:@"minisearch_cancel.png"] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageNamed:@"minisearch_cancel.png"] forState:UIControlStateDisabled];
		[[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
		
		self.cancelButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		
		// Full button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(size.width*0.5+2, size.height-28, 60, 20);
		[aButton setImage:[UIImage imageNamed:@"minisearch_full.png"] forState:UIControlStateNormal];
		[aButton setImage:[UIImage imageNamed:@"minisearch_full.png"] forState:UIControlStateDisabled];
		[[aButton titleLabel]setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionFull:) forControlEvents:UIControlEventTouchUpInside];
		
		self.fullButton = aButton;
		
		[self addSubview:aButton];
		[aButton release];
		
		SearchResultView *aSRV = [[SearchResultView alloc]initWithFrame:CGRectMake(4, 4, size.width-8, size.height-(4+4+4+20))];
		[aSRV setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		self.searchResultView = aSRV;
		[aSRV setBackgroundColor:[UIColor clearColor]];
		[self addSubview:aSRV];
		[aSRV release];
		
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
	
	MF_COCOA_RELEASE(searchResults);
	
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
