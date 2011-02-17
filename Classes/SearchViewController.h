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

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SearchResultDelegate, UISearchBarDelegate> {

	// UI elements.
	IBOutlet UISearchBar *searchBar;
	IBOutlet UITableView *searchTableView;
	
	UIActivityIndicatorView *activityIndicatorView;
	
	IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
	IBOutlet UIBarButtonItem *cancelStopBarButtonItem;
	
	// Data.
	NSMutableArray *searchResults;	// Local copy. It is an array of array.
	NSUInteger totalItems;		// Counter of the total amount of item.
	NSUInteger maxItems;		// Max number of items.
	
	DocumentViewController *delegate; // A delegate to change the page.
	
	SearchManager * searchManager;	// Data source.
}

@property (assign) SearchManager * searchManager;
@property (assign) DocumentViewController *delegate;

-(IBAction)actionCancelStop:(id)sender;
-(IBAction)actionMinimize:(id)sender;
-(IBAction)actionBack:(id)sender;

@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) IBOutlet UITableView *searchTableView;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
@end
