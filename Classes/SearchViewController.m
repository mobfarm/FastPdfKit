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
#pragma mark SearchResultsDataSource methods

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page {
	
	// Work on a copy of the current search results.

	NSArray *results = [searchResults copy];
	NSMutableArray *drawables = [[NSMutableArray alloc]init];
	
	// Put each item in the array that will be returned.
	for(NSArray * result in results) {
		for(MFTextItem * item in result) {
			if([item page] == page) {
				[drawables addObject:item];
			}	
		}
	}
	
	[results release];
	
	return [drawables autorelease];
}

-(NSArray *)searchItemsForPage:(NSUInteger)page {
	
	NSArray *searchItems = nil;
	NSMutableArray *tmp = [[NSMutableArray alloc]init];
	for (NSArray *sr in searchResults) {
		for(MFTextItem * item in sr) {
			if([item page] == page) {
				[tmp addObject:item];
			}	
		}
	}
	
	searchItems = [NSArray arrayWithArray:tmp];
	[tmp release];
	return searchItems;
}

#pragma mark -
#pragma mark MFSearchViewController() methods

/*	
*	Add the MFSearchResult object to the array if it is not empty and update the table. Spawn a new operation
*	for the next page if necessary.
*/

-(void)updateResults:(NSArray *)results withResults:(NSArray *)addedResult forPage:(NSUInteger)page {

	if([addedResult count]>0) {
		
		[searchResults addObject:addedResult];
		[searchTableView reloadData];
		totalItems+= [addedResult count];
	}
}

-(void) searchGotCancelled {

	[searchBar setText:@""];
	[searchResults removeAllObjects];
	[activityIndicatorView stopAnimating];
	[cancelStopBarButtonItem setEnabled:NO];
	[switchToMiniBarButtonItem setEnabled:NO];
	[searchTableView reloadData];
	
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(void) searchDidStop {
	
	[cancelStopBarButtonItem setTitle:@"Cancel"];
	[activityIndicatorView stopAnimating];
}

-(void) searchDidStart {
	
	if([searchResults count]>0){
	[searchResults removeAllObjects];
	[searchTableView reloadData];
	}
	[cancelStopBarButtonItem setTitle:@"Stop"];
	[activityIndicatorView startAnimating];
	[cancelStopBarButtonItem setEnabled:YES];
	[switchToMiniBarButtonItem setEnabled:YES];
}

#pragma mark -
#pragma mark Start and Stop

-(void)stopSearch {
	
	[searchManager stopSearch];
}

-(void)startSearchWithTerm:(NSString *)aSearchTerm {
	
	[searchManager startSearchOfTerm:aSearchTerm fromPage:[delegate page]];
}

-(void)cancelSearch {
	
	[searchManager cancelSearch];
}

#pragma mark -
#pragma mark Actions

-(IBAction)actionCancelStop:(id)sender {
	
	if([searchManager isRunning]) {
	
		// Stop.
		[self stopSearch];
		
	} else {
		
		[self cancelSearch];
	}
}

-(IBAction)actionMinimize:(id)sender {
	
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
	
	// Dismiss the keyboard.
	[sBar resignFirstResponder];
	[self cancelSearch];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)sBar {
	
	[sBar resignFirstResponder];
	
	// Let the startSearch helper function handle the spawning of the operation.
	[self startSearchWithTerm:[sBar text]];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)sBar {
	
	// Let the cancelSearch helper function stop the pending operation.
	[self stopSearch];
}

		 
#pragma mark -
#pragma mark UITableViewDelegate and DataSource methods

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	// We are setting up a title for the header of the section, just to make the table a little
	// less asettic.
	
	NSString *headerTitle = nil;
	NSArray *searchResult = [searchResults objectAtIndex:section];
	NSUInteger page = [[searchResult objectAtIndex:0]page];
	
	headerTitle = [NSString stringWithFormat:@"Page %u",page];
	
	return headerTitle;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// We don't care about the search item, just the search result that contains the page.
	NSArray *searchResult = [searchResults objectAtIndex:indexPath.section];
	MFTextItem * item = [searchResult objectAtIndex:indexPath.row];
	
	// Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page.
	[delegate switchToMiniSearchView:item];
	
	[delegate setPage:[item page] withZoomOnRect:CGPathGetBoundingBox([item highlightPath])];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"searchResultCellId";
	
	// Just costumize the cell with the content of the MFSearchItem for the right row in the right section.
	
	NSArray *searchResult = [searchResults objectAtIndex:indexPath.section];
	MFTextItem *searchItem = [searchResult objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
		
		// Create the cell.
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[cell setSelectionStyle:UITableViewCellSeparatorStyleNone];
	}
	
	// Setup the cell.
	[[cell textLabel]setText:[searchItem text]];
	
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
