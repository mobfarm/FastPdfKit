//
//  MFSearchViewController.h
//  FastPdfKit
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

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, readwrite) BOOL ignoreCase;
@property (nonatomic, readwrite) BOOL exactMatch;

@property (assign) SearchManager * searchManager;
@property (assign) NSObject<SearchViewControllerDelegate> *delegate;

-(IBAction)actionCancelStop:(id)sender;
-(IBAction)actionMinimize:(id)sender;
-(IBAction)actionBack:(id)sender;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *searchTableView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelStopBarButtonItem;
@property (nonatomic, retain) IBOutlet UIToolbar * toolbar;
@end
