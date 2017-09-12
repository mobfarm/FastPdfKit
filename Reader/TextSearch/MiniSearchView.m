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
#import "SearchManager.h"
#import "SearchResultView.h"
#import "NotificationFactory.h"
#import "SearchManager.h"

#define ZOOM_LEVEL 4.0

@interface MiniSearchView()
@property (nonatomic, readwrite) NSUInteger searchResultsCount;
@property (nonatomic, strong) FPKSearchMatchItem * currentItem;
@end

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
	
    self.searchResultsCount = [self.delegate numberOfSearchResults:self]; // Get the number of results
    
    self.currentSearchResultIndex = 0; // Reset the index
    
    [self updateButtons];
    [self loadItem];
}

-(void)setCurrentItem:(FPKSearchMatchItem *)currentItem {
    if(_currentItem != currentItem) {
        _currentItem = currentItem;
        
        [self updateSearchResultViewWithItem:_currentItem];
    }
}

-(void)loadItem {
    // This method basically set the current appaerance of the view to
    // present the content of the Search Result pointed by currentSearchResultIndex.
    FPKSearchMatchItem * item = [self.delegate miniSearchView:self searchResultAtIndex:self.currentSearchResultIndex];
    
    self.currentItem = item;
    [self.delegate miniSearchView:self setPage:item.textItem.page zoomLevel:1.0 rect:CGRectZero];
}

-(void)updateButtons {
    
    if(self.searchResultsCount > 0) {
        self.nextButton.enabled = YES;
        self.prevButton.enabled = YES;
    } else {
        self.nextButton.enabled = NO;
        self.prevButton.enabled = NO;
    }
}

-(void)setCurrentSearchResultIndex:(NSInteger)index {
    if(_currentSearchResultIndex != index) {
        _currentSearchResultIndex = index;
     
        [self loadItem];
    }
}

-(void) moveToNextResult {
	
    self.currentSearchResultIndex = (self.currentSearchResultIndex + 1) % self.searchResultsCount;
}

-(void) moveToPrevResult {
    
	// As the above method, but it decrease the index instead.
    self.currentSearchResultIndex = ((self.currentSearchResultIndex - 1) + self.searchResultsCount) % self.searchResultsCount;
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
	
    [self.delegate cancelSearch:self];
}

-(void)actionFull:(id)sender {
	
    [self.delegate revertToFullSearchViewFromMiniSearchView:self];
}

#pragma mark - View lifecycle
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self.subviews.lastObject removeFromSuperview];
        
        // Initialization code.
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        // Background.
        UIImageView * backgroundImageView = [UIImageView new];
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        backgroundImageView.backgroundColor = [UIColor clearColor];
        self.backgroundImageView = backgroundImageView;
        [self addSubview:backgroundImageView];
        
        // Previous result button.
        UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
        previousButton.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage * previousImage = [UIImage imageNamed:@"Reader/prew" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        [previousButton setImage:previousImage forState:UIControlStateNormal];
        [previousButton addTarget:self
                           action:@selector(actionPrev:)
                 forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:previousButton];
        
        // Next result button.
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
                nextButton.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage * nextImage = [UIImage imageNamed:@"Reader/next" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        [nextButton setImage:nextImage forState:UIControlStateNormal];
        [nextButton addTarget:self
                       action:@selector(actionNext:)
             forControlEvents:UIControlEventTouchUpInside];
                [self addSubview: nextButton];
        
        // Cancel search button.
        UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
                cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        // Go back to full search button.
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeSystem];
                backButton.translatesAutoresizingMaskIntoConstraints = NO;
        [backButton setTitle:@"Advanced" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(actionFull:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        // Search result "button".
        SearchResultView * resultView = [SearchResultView new];
                resultView.translatesAutoresizingMaskIntoConstraints = NO;
        resultView.pageNumberLabel.textColor = [UIColor whiteColor];
        resultView.snippetLabel.textColor = [UIColor whiteColor];
        self.searchResultView = resultView;
        [self addSubview:resultView];
        
        // Padding view used to align the other views without becoming insane with VFL.
        UIView * topPaddingView = [UIView new];
        topPaddingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:topPaddingView];
        
        UIView * bottomPaddingView = [UIView new];
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:bottomPaddingView];
        
        // Layout.
        NSDictionary * views = @{@"back":backButton,
                                 @"cancel":cancelButton,
                                 @"next":nextButton,
                                 @"prev":previousButton,
                                 @"result":resultView,
                                 @"topPadding":topPaddingView,
                                 @"bottomPadding":bottomPaddingView,
                                 @"background":backgroundImageView
                                 };
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[back]-[result(>=20)]-[prev]-[next]-[cancel]-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topPadding]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomPadding]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[background]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPadding(>=1)][back][bottomPadding(==topPadding)]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPadding(>=1)][result][bottomPadding(==topPadding)]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPadding(>=1)][prev][bottomPadding(==topPadding)]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPadding(>=1)][next][bottomPadding(==topPadding)]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPadding(>=1)][cancel][bottomPadding(==topPadding)]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background]|" options:0 metrics:nil views:views]];
    }
    
    return self;
}

@end
