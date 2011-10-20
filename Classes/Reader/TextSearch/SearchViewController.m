    //
//  MFSearchViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "SearchViewController.h"
#import "MFTextItem.h"
#import "MFDocumentManager.h"
#import "DocumentViewController.h"
#import "ReaderViewController.h"
#import "TextSearchOperation.h"
#import "SearchManager.h"
#import "SearchResultCellView.h"
#import "NotificationFactory.h"

/* This parameter set the zoom level that will be performed when you choose the next result, there's another one in the MiniSearchView.m */
#define ZOOM_LEVEL 4.0

@interface SearchViewController()

-(void)stopSearch;
-(void)startSearchWithTerm:(NSString *)term;

@end

@implementation SearchViewController

@synthesize searchBar, searchTableView;
@synthesize switchToMiniBarButtonItem, activityIndicatorView;
@synthesize delegate;
@synthesize searchManager;

#pragma mark - Notification listeners

-(void)handleSearchResultsAvailableNotification:(NSNotification *)notification {
 
    NSDictionary * userInfo = [[notification userInfo]retain];
    
    NSArray * searchResult = [userInfo objectForKey:kNotificationSearchInfoResults];
    
    if([searchResult count] > 0) {
        
        [searchTableView reloadData];
    }
    
    [userInfo release];
}

-(void)handleSearchDidStopNotification:(NSNotification *)notification {
    NSString *title = NSLocalizedString(@"SEARCH_CANCEL_BTN_TITLE", @"Cancel");
    if ([title isEqualToString:@"SEARCH_CANCEL_BTN_TITLE"]){
        title = @"Cancel";
    }
    
    [cancelStopBarButtonItem setTitle:title];
	[activityIndicatorView stopAnimating];
}

-(void)handleSearchDidStartNotification:(NSNotification *)notification {
    
    // Clean up if there are old search results.
    
    [searchTableView reloadData];
		
	// Set up the view status accordingly.
	
    NSString *title = NSLocalizedString(@"SEARCH_STOP_BTN_TITLE", @"Cancel");
    if ([title isEqualToString:@"SEARCH_STOP_BTN_TITLE"]){
        title = @"Stop";
    }
    
	[cancelStopBarButtonItem setTitle:title];
	[activityIndicatorView startAnimating];
	[cancelStopBarButtonItem setEnabled:YES];
	[switchToMiniBarButtonItem setEnabled:YES];
}

-(void)handleSearchGotCancelledNotification:(NSNotification *)notification {
    // Setup the view accordingly.
	
	[searchBar setText:@""];
	[activityIndicatorView stopAnimating];
	[cancelStopBarButtonItem setEnabled:NO];
	[switchToMiniBarButtonItem setEnabled:NO];
//	[searchTableView reloadData];
	
	[[self delegate]dismissSearchViewController:self];
}

#pragma mark -
#pragma mark Start and Stop

-(void)stopSearch {
	
	// Tell the manager to stop the search and let the delegate's methods to refresh this view.
	
	[searchManager stopSearch];
}

-(void)startSearchWithTerm:(NSString *)aSearchTerm {
	
	// Tell the manager to start the search  and let the delegate's methods to refresh this view.
	
	[searchManager startSearchOfTerm:aSearchTerm fromPage:[delegate page]];
}

-(void)cancelSearch {
	
	// Tell the manager to cancel the search and let the delegate's  methods to refresh this view.
	
	[searchManager cancelSearch];
}

#pragma mark -
#pragma mark Actions

-(IBAction)actionCancelStop:(id)sender {
	
	// If the search is running, stop it. Otherwise, cancel the 
	// search entirely.
	
	if([searchManager isRunning]) {
	
		// Stop.
		[self stopSearch];
		
	} else {
		
		// Cancel.
		[delegate dismissSearchViewController:self];
	}
}


-(IBAction)actionBack:(id)sender {
	
    if ([self respondsToSelector:@selector(presentingViewController)])
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    else
        [[self parentViewController] dismissModalViewControllerAnimated:YES];

}

-(IBAction)actionMinimize:(id)sender {
	
	// We are going to use the first item to initialize the mini view.
	
    NSIndexPath * visibleIndexPath = nil;
    
	MFTextItem * firstItem = nil;
    
    if([[searchManager searchResults]count] > 0) {
        
        visibleIndexPath = [[searchTableView indexPathsForVisibleRows]objectAtIndex:0];
        firstItem = [[[searchManager searchResults] objectAtIndex:visibleIndexPath.section]objectAtIndex:visibleIndexPath.row];
        
        if(firstItem!=nil) {
            
            [delegate switchToMiniSearchView:firstItem];
        }
    }
}
		
#pragma mark -
#pragma mark UISearchBarDelegate methods


-(BOOL)searchBarShouldEndEditing:(UISearchBar *)sBar {
	
	[sBar resignFirstResponder];
	
	return YES;
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)sBar {
	
	// Dismiss the keyboard and cancel the search.
	
	[sBar resignFirstResponder];
	[self cancelSearch];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)sBar {

	// Let the startSearch helper function handle the spawning of the operation.

	[sBar resignFirstResponder];
	
	[self startSearchWithTerm:[sBar text]];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)sBar {
	
	// Let the stopSearch helper function stop the pending operation.
	
	[self stopSearch];
}

		 
#pragma mark -
#pragma mark UITableViewDelegate and DataSource methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Let's get the MFTextItem from its container array.
	
	NSArray *searchResult = [[searchManager searchResults] objectAtIndex:indexPath.section];
	MFTextItem * item = [searchResult objectAtIndex:indexPath.row];
	
	// Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page after
	// displaying the mini search view.
	
	[delegate switchToMiniSearchView:item];
	
	[delegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];
	
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"searchResultCellId";
	
	// Just costumize the cell with the content of the MFSearchItem for the right row in the right section.
	
	NSArray *searchResult = [[searchManager searchResults] objectAtIndex:indexPath.section];
	MFTextItem *searchItem = [searchResult objectAtIndex:indexPath.row];
    
	
	// This is a custom view cell that display an MFTextItem directly.
	
	SearchResultCellView *cell = (SearchResultCellView *)[tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
	
		// Simple initialization.
		
		cell = [[[SearchResultCellView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[searchItem page]];
    
	[cell setTextSnippet:[searchItem text]];
	[cell setPage:[searchItem page]];
	[cell setBoldRange:[searchItem searchTermRange]];
	
     
    /*
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId]autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	}
	
    cell.textLabel.text = [searchItem text];
    cell.textLabel.minimumFontSize = 12;

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",[searchItem page]];
     
     */

    return cell;
    
	
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    // Let's get the MFTextItem from its container array.
	
	NSArray *searchResult = [[searchManager searchResults] objectAtIndex:indexPath.section];
	MFTextItem * item = [searchResult objectAtIndex:indexPath.row];
	
	// Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page after
	// displaying the mini search view.
	
	[delegate switchToMiniSearchView:item];
	
	[delegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];

}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	
	// Nothing special here.
	NSArray *searchResult = [[searchManager searchResults] objectAtIndex:section];
    
	return [searchResult count];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	// Nothing special here.
	return [[searchManager searchResults] count];
}

#pragma mark UIViewController methods


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        searchManager = nil;
		switchToMiniBarButtonItem.enabled = NO;
	}
    return self;
}

-(void)viewWillAppear:(BOOL)animated {

	// Different setup if search is running or not.
	[super viewWillAppear:animated];
    
	if([searchManager isRunning]) {
		
		[activityIndicatorView startAnimating];
        NSString *title = NSLocalizedString(@"SEARCH_STOP_BTN_TITLE", @"Cancel");
        if ([title isEqualToString:@"SEARCH_STOP_BTN_TITLE"]){
            title = @"Stop";
        }

		[cancelStopBarButtonItem setTitle:title];
		
	} else {
	    NSString *title = NSLocalizedString(@"SEARCH_CANCEL_BTN_TITLE", @"Cancel");
        if ([title isEqualToString:@"SEARCH_CANCEL_BTN_TITLE"]){
            title = @"Cancel";
        }
        
		[cancelStopBarButtonItem setTitle:title];
		
	} 
	
	// Common setup.
	
	[searchBar setText:[searchManager searchTerm]];
	
	[searchTableView reloadData];
    
	if([[searchManager searchResults] count] <= 0)
		[searchBar becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleSearchDidStartNotification:) name:kNotificationSearchDidStart object:nil];
    [notificationCenter addObserver:self selector:@selector(handleSearchDidStopNotification:) name:kNotificationSearchDidStop object:nil];
    [notificationCenter addObserver:self selector:@selector(handleSearchGotCancelledNotification:) name:kNotificationSearchGotCancelled object:nil];
    [notificationCenter addObserver:self selector:@selector(handleSearchResultsAvailableNotification:) name:kNotificationSearchResultAvailable object:nil];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}


- (void)didReceiveMemoryWarning {
   
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
	[self setSearchBar:nil];
	[self setSearchTableView:nil];
	[self setSwitchToMiniBarButtonItem:nil];
	[self setActivityIndicatorView:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)dealloc {
	
	searchManager = nil;
	
	[switchToMiniBarButtonItem release],switchToMiniBarButtonItem = nil;
	[cancelStopBarButtonItem release],cancelStopBarButtonItem = nil;
	
	[searchBar release],searchBar = nil;
	[searchTableView release], searchTableView = nil;
	[activityIndicatorView release],activityIndicatorView = nil;
	
    [super dealloc];
}


@end
