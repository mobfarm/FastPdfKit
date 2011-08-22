//
//  SearchViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 25/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFTextItem.h"

@class SearchViewController;

@protocol SearchViewControllerDelegate

-(NSUInteger)page;

-(void)switchToMiniSearchView:(MFTextItem *)item;

-(void)dismissSearchViewController:(SearchViewController *)svc;

-(void)setPage:(NSUInteger)page withZoomOfLevel:(float)zoomLevel onRect:(CGRect)rect;

@end
