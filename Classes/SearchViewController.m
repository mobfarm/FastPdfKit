    //
//  MFSearchViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "SearchViewController.h"
#import "MFTextItem.h"
#import "MFSearchResult.h"
#import "MFDocumentManager.h"
#import "DocumentViewController.h"
#import "TextSearchOperation.h"

@interface SearchViewController()

@property (nonatomic, retain) NSOperation *searchOperation;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (readwrite) NSUInteger startingSearchPage;
@property (readwrite) NSUInteger currentSearchPage;

-(void)stopSearch;
-(void)saveSearchStatus;
-(void)restoreSearchStatus;
-(void)startSearch;

@end


@implementation SearchViewController

@synthesize searchBar, searchTableView;
@synthesize searchResults;
@synthesize searchOperation;
@synthesize savedSearchTerm;
@synthesize searchTerm;
@synthesize startingSearchPage, currentSearchPage;
@synthesize rightButtonItem, activityIndicatorView;
@synthesize delegate;

#pragma mark -
#pragma mark SearchResultsDataSource methods

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page {
	
	// Work on a copy of the current search results.

	NSArray *results = [searchResults copy];
	NSMutableArray *drawables = [[NSMutableArray alloc]init];
	
	// Put each item in the array that will be returned.
	for(MFSearchResult * result in results) {
		if([result page] == page) {
			[drawables addObjectsFromArray:[result searchItems]];
		}
	}
	
	[results release];
	
	return [drawables autorelease];
}

-(NSArray *)searchItemsForPage:(NSUInteger)page {
	
	NSArray *searchItems = nil;
	NSMutableArray *tmp = [[NSMutableArray alloc]init];
	for (MFSearchResult *sr in searchResults) {
		if([sr page] == page) {
			[tmp addObjectsFromArray:[sr searchItems]];
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
-(void)handleSearchResult:(MFSearchResult *)searchResult {
	
	[activityIndicatorView stopAnimating];
	
	if([searchResult size]>0) {
		[searchResults addObject:searchResult];
		[searchTableView reloadData];
		totalItems+= [searchResult size];
	}
	
	//
	// Automatically spawn another operation if the limit is not reached yet.
	
	if(totalItems < maxItems) {
	
		// 
		// Abort if we reached the last page. If you want to start from the beginning avoid updating the
		// currentSearchPage from the documentViewController.
		
		if(currentSearchPage < [[delegate document]numberOfPages]) {
			
			currentSearchPage++;
			[self startSearch];	
		}
	}	
}

-(void)saveSearchStatus {
	// Save the status.
	[self setSavedSearchTerm:[searchBar text]];
}

-(void)restoreSearchStatus {
	
	// Reload the saved status.
	[searchBar setText:savedSearchTerm];
}

-(void)stopSearch {
	
	if([self searchOperation]) {
		[activityIndicatorView stopAnimating];
		[searchOperation cancel];
		[self setSearchOperation:nil];
	}
}

-(void)startSearch {
	
	TextSearchOperation *op = [[TextSearchOperation alloc]init];
	[op setPage:currentSearchPage];
	[op setDelegate:self];
	[op setSearchTerm:[searchBar text]];
	[op setDocument:[delegate document]];
	[self setSearchOperation:op];
	[operationQueue addOperation:op];
	[op release];
		
	[activityIndicatorView startAnimating];
}

-(void)cancelSearch {
	
	// Standard stop.
	[self stopSearch];
	
	// Also release the result obtained until now and reload the data.
	[searchResults removeAllObjects];
	[searchTableView reloadData];
}
		 
-(void)continueSearch {
	// TODO: coming soon.
	
}

#pragma mark -
#pragma mark UITableViewDelegate and DataSource methods

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	// We are setting up a title for the header of the section, just to make the table a little
	// less asettic.
	
	NSString *headerTitle = nil;
	MFSearchResult *searchResult = [searchResults objectAtIndex:section];
	NSUInteger page = [searchResult page];
	
	headerTitle = [NSString stringWithFormat:@"Page %u",page];
	
	return headerTitle;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// We don't care about the search item, just the search result that contains the page.
	MFSearchResult *searchResult = [searchResults objectAtIndex:indexPath.section];
	
	// Dismiss this viewcontroller and tell the DocumentViewController to move to the selected page.
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
	[delegate setPage:[searchResult page]];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"searchResultCellId";
	
	// Just costumize the cell with the content of the MFSearchItem for the right row in the right section.
	
	MFSearchResult *searchResult = [searchResults objectAtIndex:indexPath.section];
	MFTextItem *searchItem = [[searchResult searchItems]objectAtIndex:indexPath.row];
	
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
	MFSearchResult *searchResult = [searchResults objectAtIndex:section];
	return [[searchResult searchItems] count];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	// Nothing special here.
	return [searchResults count];
}

#pragma mark -
#pragma mark MFSearchResultDelegate methods

-(IBAction)actionBack:(id)sender {
	
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
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
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)sBar {
	
	// Get the current page form the document as a starting point.
	NSUInteger currentShownPage = [delegate page];
	[self setStartingSearchPage:currentShownPage];
	[self setCurrentSearchPage:currentShownPage];
	
	[sBar resignFirstResponder];
	
	// Let the startSearch helper function handle the spawning of the operation.
	[self startSearch];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)sBar {
	
	// Let the cancelSearch helper function stop the pending operation.
	[self cancelSearch];
}

#pragma mark UIViewController methods


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
       
		searchResults = [[NSMutableArray alloc]init];
		
		operationQueue =  [[NSOperationQueue alloc]init];
		[operationQueue setMaxConcurrentOperationCount:1];
		
		maxItems = 20;
		
    }
    return self;
}


-(void) viewDidDisappear:(BOOL)animated {
	
	// Stop the operation and save the search term. Search results are stored in the searchResults array
	// and are not touched.
	[self stopSearch];
	
	if(!searchStatusSaved) {
		
		[self saveSearchStatus];
		searchStatusSaved = YES;
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[[self rightButtonItem]setCustomView:aiv];
	[self setActivityIndicatorView:aiv];
	[aiv release];
	
	// Restore the appearance of the view, if it has been saved.
	if(searchStatusSaved) {
		[self restoreSearchStatus];
		[searchTableView reloadData];	
		searchStatusSaved = NO;
	}
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
	[self setRightButtonItem:nil];
	[self setActivityIndicatorView:nil];
}


- (void)dealloc {
	
	delegate = nil;
	
	[operationQueue release],operationQueue = nil;
	[searchOperation release],searchOperation = nil;

	[savedSearchTerm release],savedSearchTerm = nil;
	
	[searchResults release],searchResults = nil;
	
	[searchBar release],searchBar = nil;
	[searchTableView release], searchTableView = nil;
	[activityIndicatorView release],activityIndicatorView = nil;
	[rightButtonItem release], rightButtonItem = nil;
	
    [super dealloc];
}


@end
