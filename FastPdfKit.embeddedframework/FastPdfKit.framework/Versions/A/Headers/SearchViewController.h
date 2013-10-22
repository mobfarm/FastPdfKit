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
	
	NSObject<SearchViewControllerDelegate> *__weak delegate; // A delegate to change the page.
	
	SearchManager * __weak searchManager;	// Data source.
    
    BOOL ignoreCase;
    BOOL exactMatch;
}

@property (weak) SearchManager * searchManager;
@property (weak) NSObject<SearchViewControllerDelegate> *delegate;

-(IBAction)actionCancelStop:(id)sender;
-(IBAction)actionMinimize:(id)sender;
-(IBAction)actionBack:(id)sender;

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
@property (nonatomic, strong) IBOutlet UIToolbar * toolbar;
@end
