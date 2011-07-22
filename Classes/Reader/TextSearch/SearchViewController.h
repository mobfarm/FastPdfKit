//
//  MFSearchViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultDataSource.h"
#import "MFDocumentOverlayDataSource.h"
#import "SearchViewControllerDelegate.h"

@class MFDocumentManager;
@class DocumentViewController;
@class SearchManager;

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {

	// UI elements.
	IBOutlet UISearchBar *searchBar;
	IBOutlet UITableView *searchTableView;
	
	UIActivityIndicatorView *activityIndicatorView;
	
	IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
	IBOutlet UIBarButtonItem *cancelStopBarButtonItem;
	
	NSObject<SearchViewControllerDelegate> *delegate; // A delegate to change the page.
	
	SearchManager * searchManager;	// Data source.
}

@property (assign) SearchManager * searchManager;
@property (assign) NSObject<SearchViewControllerDelegate> *delegate;

-(IBAction)actionCancelStop:(id)sender;
-(IBAction)actionMinimize:(id)sender;
-(IBAction)actionBack:(id)sender;

@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) IBOutlet UITableView *searchTableView;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
@end
