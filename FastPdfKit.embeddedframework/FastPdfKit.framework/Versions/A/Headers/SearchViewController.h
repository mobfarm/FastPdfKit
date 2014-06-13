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

	BOOL ignoreCase;
    BOOL exactMatch;
}

@property (weak) SearchManager * searchManager;
@property (weak) NSObject<SearchViewControllerDelegate> *delegate;

-(IBAction)actionCancelStop:(id)sender;
-(IBAction)actionMinimize:(id)sender;
-(IBAction)actionBack:(id)sender;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *searchTableView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *switchToMiniBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelStopBarButtonItem;
@property (nonatomic, weak) IBOutlet UIToolbar * toolbar;
@end
