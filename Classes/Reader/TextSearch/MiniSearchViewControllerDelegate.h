//
//  MiniSearchViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MiniSearchView;

@protocol MiniSearchViewControllerDelegate

-(void)dismissMiniSearchView;
-(void)setPage:(NSUInteger)page withZoomOfLevel:(float)zoomLevel onRect:(CGRect)rect;
-(void)revertToFullSearchView;

@end
