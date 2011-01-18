//
//  MFSearchViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultDelegate.h"
#import "SearchResultDataSource.h"
#import "MFDocumentOverlayDataSource.h"

@class MFDocumentManager;
@class DocumentViewController;
@class SearchManager;

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SearchResultDelegate, UISearchBarDelegate,SearchResultDataSource, MFDocumentOverlayDataSource> {

	// UI.
	IBOutlet UISearchBar *searchBar;
	IBOutlet UITableView *searchTableView;
	
	UIActivityIndicatorView *activityIndicatorView;
	
	IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
	IBOutlet UIBarButtonItem *cancelStopBarButtonItem;
	
	// Data.
	NSMutableArray *searchResults;
	NSUInteger totalItems;
	NSUInteger maxItems;
	
	// Save status.
	NSString *savedSearchTerm;
	BOOL searchStatusSaved;
	
	DocumentViewController *delegate;
	
	SearchManager * searchManager;
}

@property (assign) SearchManager * searchManager;
@property (assign) DocumentViewController *delegate;

@property (readonly) NSUInteger currentSearchPage;
@property (readonly) NSUInteger startingSearchPage;
@property (nonatomic, readonly) NSString *searchTerm;

-(IBAction)actionCancelStop:(id)sender;
-(IBAction)actionMinimize:(id)sender;

@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) IBOutlet UITableView *searchTableView;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
@end
