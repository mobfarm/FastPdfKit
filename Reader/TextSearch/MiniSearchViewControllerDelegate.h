//
//  MiniSearchViewControllerDelegate.h
//  FastPdfKit
//
//  Created by Mac Book Pro on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPKSearchMatchItem.h"

@class MiniSearchView;

@protocol MiniSearchViewControllerDelegate

-(void)dismissMiniSearchView:(MiniSearchView *)view;
-(void)miniSearchView:(MiniSearchView *)view setPage:(NSUInteger)page zoomLevel:(float)zoomLevel rect:(CGRect)rect;
-(void)revertToFullSearchViewFromMiniSearchView:(MiniSearchView *)view;
-(NSUInteger )numberOfSearchResults:(MiniSearchView *)view;
-(FPKSearchMatchItem *)miniSearchView:(MiniSearchView *)view searchResultAtIndex:(NSUInteger)index;
-(void)cancelSearch:(MiniSearchView *)view;

@end
