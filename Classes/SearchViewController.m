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
#import "TextSearchOperation.h"
#import "SearchManager.h"
#import "SearchResultCellView.h"

#define ZOOM_LEVEL 4.0

@interface SearchViewController()

@property (nonatomic,retain) NSMutableArray *searchResults;

-(void)stopSearch;
-(void)startSearchWithTerm:(NSString *)term;

@end

@implementation SearchViewController

@synthesize searchBar, searchTableView;
@synthesize searchResults;
@synthesize switchToMiniBarButtonItem, activityIndicatorView;
@synthesize delegate;
@synthesize searchManager;

#pragma mark -
#pragma mark MFSearchViewController() methods

// The nice thing about delegate callbacks is that we don't need to extensively check the status of the search
// manager or keep track of it. We just set the ui element accordingly to the event received by the search manager.

-(void)updateResults:(NSArray *)results withResults:(NSArray *)addedResult forPage:(NSUInteger)page {

	// If there is a new batch of result, let's add them to our local result storage array and update
	// the table view.
	if([addedResult count]>0) {
	
		
		[searchResults addObject:addedResult];
		[searchTableView reloadData];
		totalItems+= [addedResult count];
	}
}

-(void) searchGotCancelled {

	// Setup the view accordingly.
	
	[searchBar setText:@""];
	[searchResults removeAllObjects];
	[activityIndicatorView stopAnimating];
	[cancelStopBarButtonItem setEnabled:NO];
	[switchToMiniBarButtonItem setEnabled:NO];
	[searchTableView reloadData];
	
	// Dismiss this view controller and its view from the stack.
	
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[[self delegate]dismissAllPopoversFrom:self];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
	}
	
	//[[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(void) searchDidStop {
	
	// Set up the view status.
	
	[cancelStopBarButtonItem setTitle:@"Cancel"];
	[activityIndicatorView stopAnimating];
}

-(void) searchDidStart {
	
	// Clean up if there are old search results.
	
	if([searchResults count]>0){
		
		[searchResults removeAllObjects];
		[searchTableView reloadData];
	}
	
	// Set up the view status accordingly.
	
	[cancelStopBarButtonItem setTitle:@"Stop"];
	[activityIndicatorView startAnimating];
	[cancelStopBarButtonItem setEnabled:YES];
	[switchToMiniBarButtonItem setEnabled:YES];
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
		[self cancelSearch];
	}
}


-(IBAction)actionBack:(id)sender {
	
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(IBAction)actionMinimize:(id)sender {
	
	// We are going to use the first item to initialize the mini view.
	
	MFTextItem * firstItem = [[searchResults objectAtIndex:0]objectAtIndex:0];
	
	if(firstItem!=nil) {
	
	[delegate switchToMiniSearchView:firstItem];
		
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
	
	// Let the cancelSearch helper function stop the pending operation.
	
	[self stopSearch];
}

		 
#pragma mark -
#pragma mark UITableViewDelegate and DataSource methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Let's get the MFTextItem from its container array.
	
	NSArray *searchResult = [searchResults objectAtIndex:indexPath.section];
	MFTextItem * item = [searchResult objectAtIndex:indexPath.row];
	
	// Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page after
	// displaying the mini search view.
	
	[delegate switchToMiniSearchView:item];
	
	[delegate setPage:[item page] withZoomOfLevel:ZOOM_LEVEL onRect:CGPathGetBoundingBox([item highlightPath])];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"searchResultCellId";
	
	// Just costumize the cell with the content of the MFSearchItem for the right row in the right section.
	
	NSArray *searchResult = [searchResults objectAtIndex:indexPath.section];
	MFTextItem *searchItem = [searchResult objectAtIndex:indexPath.row];
	
	// This is a custom view cell that display an MFTextItem directly.
	
	SearchResultCellView *cell = (SearchResultCellView *)[tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
	
		// Simple initialization.
		
		cell = [[[SearchResultCellView alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId]autorelease];
		
	}
	
	[cell setTextSnippet:[searchItem text]];
	[cell setPage:[searchItem page]];
	[cell setBoldRange:[searchItem searchTermRange]];
	
	return cell;
	
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	
	// Nothing special here.
	NSArray *searchResult = [searchResults objectAtIndex:section];
	return [searchResult count];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	// Nothing special here.
	return [searchResults count];
}

#pragma mark UIViewController methods


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
       
		searchResults = [[NSMutableArray alloc]init];
		switchToMiniBarButtonItem.enabled = NO;
		
	}
    return self;
}


-(void) viewDidDisappear:(BOOL)animated {
	
	// Stop the operation and save the search term. Search results are stored in the searchResults array
	// and are not touched.
	//[self stopSearch];
}

-(void)viewWillAppear:(BOOL)animated {

	// Different setup if search is running or not.
	
	if([searchManager isRunning]) {
		
		[activityIndicatorView startAnimating];
		[cancelStopBarButtonItem setTitle:@"Stop"];
		
	} else {
	
		[cancelStopBarButtonItem setTitle:@"Cancel"];
		
	} 
	
	// Common setup.
	
	[searchBar setText:[searchManager searchTerm]];
	self.searchResults = [[searchManager searchResults]mutableCopy];
	[searchTableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
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
}


- (void)dealloc {
	
	searchManager = nil;
	
	[switchToMiniBarButtonItem release],switchToMiniBarButtonItem = nil;
	[cancelStopBarButtonItem release],cancelStopBarButtonItem = nil;
	
	[searchResults release],searchResults = nil;
	
	[searchBar release],searchBar = nil;
	[searchTableView release], searchTableView = nil;
	[activityIndicatorView release],activityIndicatorView = nil;
	
    [super dealloc];
}


@end
