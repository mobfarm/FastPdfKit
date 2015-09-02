    //
//  MFSearchViewController.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "SearchViewController.h"
#import "MFDocumentManager.h"
#import "ReaderViewController.h"
#import "TextSearchOperation.h"
#import "SearchManager.h"
#import "SearchResultCellView.h"
#import "SearchResultView.h"

/* This parameter set the zoom level that will be performed when you choose the next result, there's another one in the MiniSearchView.m */
#define ZOOM_LEVEL 4.0

@interface SearchViewController()

-(void)stopSearch;
-(void)startSearchWithTerm:(NSString *)term;

@end

@implementation SearchViewController

#pragma mark - Notification listeners

-(void)handleSearchResultsAvailableNotification:(NSNotification *)notification {
 
    NSDictionary * userInfo = notification.userInfo;
    
    NSArray * searchResult = [userInfo objectForKey:kNotificationSearchInfoResults];
    
    if([searchResult count] > 0) {
        
        [self.searchTableView reloadData];
    }
}

-(void)handleSearchDidStopNotification:(NSNotification *)notification {
    
    NSString *title = NSLocalizedString(@"SEARCH_CANCEL_BTN_TITLE", @"Cancel");
    if ([title isEqualToString:@"SEARCH_CANCEL_BTN_TITLE"]){
        title = @"Cancel";
    }
    
    [self.cancelStopBarButtonItem setTitle:title];
	[self.activityIndicatorView stopAnimating];
}

-(void)handleSearchDidStartNotification:(NSNotification *)notification {
    
    // Clean up if there are old search results.
    
    [self.searchTableView reloadData];
		
	// Set up the view status accordingly.
	
    NSString *title = NSLocalizedString(@"SEARCH_STOP_BTN_TITLE", @"Cancel");
    if ([title isEqualToString:@"SEARCH_STOP_BTN_TITLE"]){
        title = @"Stop";
    }
    
	[self.cancelStopBarButtonItem setTitle:title];
	[self.activityIndicatorView startAnimating];
	[self.cancelStopBarButtonItem setEnabled:YES];
	[self.switchToMiniBarButtonItem setEnabled:YES];
}

-(void)handleSearchGotCancelledNotification:(NSNotification *)notification {
    // Setup the view accordingly.
	
	[self.searchBar setText:@""];
	[self.activityIndicatorView stopAnimating];
	[self.cancelStopBarButtonItem setEnabled:NO];
	[self.switchToMiniBarButtonItem setEnabled:NO];
}

#pragma mark -
#pragma mark Start and Stop

-(void)stopSearch {
	
	// Tell the manager to stop the search and let the delegate's methods to refresh this view.

    [self.searchManager stopSearch];
}

-(void)startSearchWithTerm:(NSString *)aSearchTerm {
	
	// Tell the manager to start the search  and let the delegate's methods to refresh this view.
    // Create a new search manager with the search term
    SearchManager * searchManager = [SearchManager new];
    self.searchManager = searchManager;
    
    self.searchManager.searchTerm = aSearchTerm;
    self.searchManager.startingPage = [self.delegate pageForSearchViewController:self];
    self.searchManager.document = [self.delegate documentForSearchViewController:self];
    self.searchManager.ignoreCase = self.ignoreCase;
    self.searchManager.exactMatch = self.exactMatch;
    
    // Start the search
    [self.searchManager startSearch];
    
    // Inform the delegate of the search in progress
    [self.delegate searchViewController:self addSearch:self.searchManager];

}

-(void)cancelSearch {
	
    // Tell the manager to cancel the search and let the delegate's  methods to refresh this view.
    if(self.searchManager) {
        [self.searchManager stopSearch];
        [self.delegate searchViewController:self removeSearch:self.searchManager];
        self.searchManager = nil;
        [self.searchTableView reloadData];
    }
}

#pragma mark -
#pragma mark Actions

-(IBAction)actionCancelStop:(id)sender {
    
    if(!self.searchManager) {
        return; // Nothing to do here
    }
    
    // If the search is running, stop it. Otherwise, cancel the
    // search entirely.
    
    if(self.searchManager.running) {
        
        [self stopSearch];
        
    } else {
        
        [self cancelSearch];
    }
}


-(IBAction)actionBack:(id)sender {
	
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)actionMinimize:(id)sender {
	
    // We are going to use the first item to initialize the mini view.
    
    NSIndexPath * visibleIndexPath = nil;
    
    FPKSearchMatchItem * firstItem = nil;
    
    NSArray * results = [self.searchManager allSearchResults];
    
    if(results.count > 0) {
        
        visibleIndexPath = [[self.searchTableView indexPathsForVisibleRows]objectAtIndex:0];
        firstItem = [[results objectAtIndex:visibleIndexPath.section] objectAtIndex:visibleIndexPath.row];
        
        if(firstItem!=nil) {
            
            [self.delegate searchViewController:self switchToMiniSearchView:firstItem];
        }
    }
}
		
#pragma mark -
#pragma mark UISearchBarDelegate methods

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	
	[searchBar resignFirstResponder];
	
	return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Dismiss the keyboard and cancel the search.
    
    [searchBar resignFirstResponder];
    [self cancelSearch];
}


-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {

	// Let the startSearch helper function handle the spawning of the operation.

	[searchBar resignFirstResponder];
	
    NSString * searchTerm = self.searchBar.text;
    [self startSearchWithTerm:searchTerm];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    [self cancelSearch];
    
    return YES;
}
		 
#pragma mark -
#pragma mark UITableViewDelegate and DataSource methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSArray *searchResult = self.searchManager.sequentialSearchResults[indexPath.section];
    FPKSearchMatchItem * item = [searchResult objectAtIndex:indexPath.row];
    
    // Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page after
    // displaying the mini search view.
    
    [self.delegate searchViewController:self switchToMiniSearchView:item];
    
    [self.delegate searchViewController:self setPage:item.textItem.page withZoomOfLevel:ZOOM_LEVEL onRect:item.boundingBox];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"searchResultCellId";
	
	// Just costumize the cell with the content of the MFSearchItem for the right row in the right section.
	
    NSArray *searchResult = self.searchManager.sequentialSearchResults[indexPath.section];
	FPKSearchMatchItem *searchItem = [searchResult objectAtIndex:indexPath.row];
    
	// This is a custom view cell that display an FPKSearchMatchItem directly.
    
	SearchResultCellView *cell = (SearchResultCellView *)[tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
	
		// Simple initialization.
        
        cell = [[SearchResultCellView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
    
    [cell.searchResultView setSnippet:searchItem.textItem.text boldRange:searchItem.textItem.searchTermRange];
    cell.searchResultView.pageNumberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)searchItem.textItem.page];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    // Let's get the FPKSearchMatchItem from its container array.
	
    NSArray *searchResult = self.searchManager.sequentialSearchResults[indexPath.section];
	FPKSearchMatchItem * item = [searchResult objectAtIndex:indexPath.row];
	
	// Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page after
	// displaying the mini search view.
	
	[self.delegate searchViewController:self switchToMiniSearchView:item];
	
    [self.delegate searchViewController:self
                           setPage:item.textItem.page
                   withZoomOfLevel:ZOOM_LEVEL
                            onRect:item.boundingBox];

}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	
	// Nothing special here.
    NSArray *searchResult = self.searchManager.sequentialSearchResults[section];
    
    return searchResult.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	// Nothing special here.
    return self.searchManager.sequentialSearchResults.count;
}

#pragma mark UIViewController methods


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
		self.switchToMiniBarButtonItem.enabled = NO;
        self.ignoreCase = YES;
        self.exactMatch = NO;
        
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(handleSearchDidStartNotification:) name:kNotificationSearchDidStart object:nil];
        [notificationCenter addObserver:self selector:@selector(handleSearchDidStopNotification:) name:kNotificationSearchDidStop object:nil];
        [notificationCenter addObserver:self selector:@selector(handleSearchResultsAvailableNotification:) name:kNotificationSearchResultAvailable object:nil];
	}
    return self;
}

-(void)viewWillAppear:(BOOL)animated 
{
	// Different setup if search is running or not.
	[super viewWillAppear:animated];
    
    self.searchManager = [self.delegate searchForSearchViewController:self]; // Retrieve the searh currently displayed
    
	if(self.searchManager.running) {
		
		[self.activityIndicatorView startAnimating];
        NSString *title = NSLocalizedString(@"SEARCH_STOP_BTN_TITLE", @"Cancel");
        if ([title isEqualToString:@"SEARCH_STOP_BTN_TITLE"]){
            title = @"Stop";
        }

		[self.cancelStopBarButtonItem setTitle:title];
		
	} else {
	    NSString *title = NSLocalizedString(@"SEARCH_CANCEL_BTN_TITLE", @"Cancel");
        if ([title isEqualToString:@"SEARCH_CANCEL_BTN_TITLE"]){
            title = @"Cancel";
        }
        
		[self.cancelStopBarButtonItem setTitle:title];
	} 
	
	// Common setup.
	
	[self.searchBar setText:[self.searchManager searchTerm]];
	
	[self.searchTableView reloadData];
    
    if(self.searchManager.sequentialSearchResults.count == 0) {
		[self.searchBar becomeFirstResponder];
    }
}

-(IBAction)actionToggleIgnoreCase:(id)sender
{
    self.ignoreCase=!self.ignoreCase;
}

-(IBAction)actionToggleExactMatch:(id)sender
{
    self.exactMatch=!self.exactMatch;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{	
    [super viewDidLoad];
    
    /* Setup bottom toolbar with label and switches */
    
    // Ignore case label and switch.
    
    UILabel * ignoreCaseLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
    ignoreCaseLabel.text = @"Ignore case";
    ignoreCaseLabel.textColor = [UIColor lightTextColor];
    ignoreCaseLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * ignoreCaseLabelBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:ignoreCaseLabel];
    
    UISwitch * ignoreCaseSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    ignoreCaseSwitch.on = self.ignoreCase;
    [ignoreCaseSwitch addTarget:self action:@selector(actionToggleIgnoreCase:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem * ignoreCaseSwitchBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:ignoreCaseSwitch];
    
    // Exact match label and switch.
    UILabel * exactMatchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
    exactMatchLabel.text = @"Exact phrase";
    exactMatchLabel.textColor = [UIColor lightTextColor];
    exactMatchLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * exactMatchLabelBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:exactMatchLabel];
    
    UISwitch * exactMatchSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    exactMatchSwitch.on = self.exactMatch;
    [exactMatchSwitch addTarget:self action:@selector(actionToggleExactMatch:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem * exactMatchSwitchBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:exactMatchSwitch];
    
    // Toolbar.
    [self.toolbar setItems: [NSArray arrayWithObjects: ignoreCaseLabelBarButtonItem,ignoreCaseSwitchBarButtonItem,exactMatchLabelBarButtonItem, exactMatchSwitchBarButtonItem, nil] animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
