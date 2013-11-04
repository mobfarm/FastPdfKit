//
//  MiniSearchViewController.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 31/10/13.
//
//

#import "MiniSearchViewController.h"
#import "NotificationFactory.h"
#import "ReaderViewController.h"

#define ZOOM_LEVEL 4.0

@interface MiniSearchViewController () {
    long int currentSearchResultIndex;	// Current index of the search result.
}

@end

@implementation MiniSearchViewController
@synthesize dataSource;
@synthesize documentDelegate;

@synthesize cancelButton, nextButton, prevButton, fullButton;
@synthesize pageLabel, snippetLabel;
@synthesize toolbar;

+(NSAttributedString *)attributedTextSnippet:(MFTextItem *)item {
    
    static NSDictionary *attributes = nil;
    if(!attributes) {
        UIFont * regularFont = [UIFont systemFontOfSize:13];
        attributes = @{NSFontAttributeName:regularFont,
                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
    static NSDictionary *subAttributes = nil;
    if(!subAttributes) {
        UIFont * boldFont = [UIFont boldSystemFontOfSize:13];
        subAttributes = @{NSFontAttributeName:boldFont,
                          NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
    
    NSMutableAttributedString * attributedTextSnippet = [[NSMutableAttributedString alloc] initWithString:item.text
                                                                                               attributes:attributes];
    [attributedTextSnippet setAttributes:subAttributes
                                   range:item.searchTermRange];
    return attributedTextSnippet;
}

-(void)updateSearchResultViewWithItem:(MFTextItem *)item {
    
	self.pageLabel.text = [NSString stringWithFormat:@"%d", item.page];
    
    NSAttributedString * attributedTextSnippeet = [MiniSearchViewController attributedTextSnippet:item];
	self.snippetLabel.attributedText = attributedTextSnippeet;
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
    
    [cancelButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"dismiss", @"png")] forState:UIControlStateNormal];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.toolbar setBackgroundImage:[ReaderViewController defaultToolbarBackgroundImage]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    
    // Do any additional setup after loading the view from its nib.
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(0, 0, 42, 33);
    [nextButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"next", @"png")] forState:UIControlStateNormal];
    [nextButton addTarget:self
                   action:@selector(actionNext:)
         forControlEvents:UIControlEventTouchUpInside];
    
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    prevButton.frame = CGRectMake(0, 0, 42, 33);
    [prevButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"prev", @"png")] forState:UIControlStateNormal];
    [prevButton addTarget:self
                   action:@selector(actionPrev:)
         forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 42, 33);
    [cancelButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"dismiss", @"png")] forState:UIControlStateNormal];
    [cancelButton addTarget:self
                     action:@selector(actionCancel:)
           forControlEvents:UIControlEventTouchUpInside];
    
    self.fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullButton.frame = CGRectMake(0, 0, 42, 33);
    [fullButton setImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"search", @"png")] forState:UIControlStateNormal];
    [fullButton addTarget:self
                   action:@selector(actionFull:)
         forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * pLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 54, 33)];
    pLabel.backgroundColor = [UIColor clearColor];
    pLabel.textColor = [UIColor whiteColor];
    pLabel.font = [UIFont boldSystemFontOfSize:13];
    self.pageLabel = pLabel;
    
    UIBarButtonItem * nextBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:nextButton];
    UIBarButtonItem * prevBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:prevButton];
    UIBarButtonItem * cancelBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    UIBarButtonItem * searchBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:fullButton];
    UIBarButtonItem * pageBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:pageLabel];
    
    UIBarButtonItem * flexibleSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray * barButtonItems = @[searchBarButtonItem, pageBarButtonItem, flexibleSpaceItem, prevBarButtonItem, nextBarButtonItem, cancelBarButtonItem];
    
    [toolbar setItems:barButtonItems animated:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchDidStopNotification:) name:kNotificationSearchDidStop object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchGotCancelledNotification:) name:kNotificationSearchGotCancelled object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
