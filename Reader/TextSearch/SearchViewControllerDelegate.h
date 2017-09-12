//
//  SearchViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 25/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPKSearchMatchItem.h"

@class SearchViewController;
@class SearchManager;
@class MFDocumentManager;

@protocol SearchViewControllerDelegate <NSObject>

-(MFDocumentManager *)documentForSearchViewController:(SearchViewController *)controller;
-(NSUInteger)pageForSearchViewController:(SearchViewController *)controller;
-(void)searchViewController:(SearchViewController *)controller switchToMiniSearchView:(FPKSearchMatchItem *)item;
-(void)dismissSearchViewController:(SearchViewController *)controller;
-(void)searchViewController:(SearchViewController *)controller setPage:(NSUInteger)page withZoomOfLevel:(float)zoomLevel onRect:(CGRect)rect;
-(void)searchViewController:(SearchViewController *)controller addSearch:(SearchManager *)searchManager;
-(void)searchViewController:(SearchViewController *)controller removeSearch:(SearchManager *)searchManager;
-(SearchManager *)searchForSearchViewController:(SearchViewController *)controller;

@end
