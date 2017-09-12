//
//  MiniSearchView.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 1/17/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniSearchViewControllerDelegate.h"
#import "FPKSearchMatchItem.h"

@class SearchManager;
@class DocumentViewController;
@class SearchResultView;

@interface MiniSearchView : UIView

@property (nonatomic, weak) NSObject<MiniSearchViewControllerDelegate> * delegate;

@property (nonatomic, readwrite) NSInteger currentSearchResultIndex;

@property (nonatomic,weak) UIButton *nextButton;
@property (nonatomic,weak) UIButton *prevButton;
@property (nonatomic,weak) UIButton *cancelButton;
@property (nonatomic,weak) UIButton *fullButton;

@property (nonatomic,weak) UILabel *pageLabel;
@property (nonatomic,weak) UILabel *snippetLabel;
@property (nonatomic,weak) UIImageView *backgroundImageView;

/**
 * Used to tell the view that the data set has changed, for example when
 * there are new results.
 */
-(void)reloadData;

@property (nonatomic,weak) SearchResultView *searchResultView;

-(void)actionNext:(id)sender;
-(void)actionPrev:(id)sender;

@end
