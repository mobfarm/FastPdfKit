//
//  MiniSearchView.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/17/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniSearchViewControllerDelegate.h"

@class SearchManager;
@class DocumentViewController;
@class MFTextItem;
@class SearchResultView;

@interface MiniSearchView : UIView {
	
	// UI elements.
	UIButton *nextButton;
	UIButton *prevButton;
	UIButton *cancelButton;
	UIButton *fullButton;
	
	// This is the same content view presented in the search result table view.
	SearchResultView *searchResultView;
 	
	SearchManager *__weak dataSource;	// Data sources for the serarch.
	NSObject<MiniSearchViewControllerDelegate> *__weak documentDelegate;	// Delegate.
	
	long int currentSearchResultIndex;	// Current index of the search result.
}

@property (nonatomic,weak) NSObject<MiniSearchViewControllerDelegate> * documentDelegate;
@property (nonatomic,weak) SearchManager *dataSource;

@property (nonatomic,strong) UIButton *nextButton;
@property (nonatomic,strong) UIButton *prevButton;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *fullButton;

@property (nonatomic,strong) UILabel *pageLabel;
@property (nonatomic,strong) UILabel *snippetLabel;

@property (nonatomic,strong) SearchResultView *searchResultView;

-(void)reloadData;
-(void)setCurrentResultIndex:(NSUInteger)index;
-(void)setCurrentTextItem:(MFTextItem *)item;
-(void)actionNext:(id)sender;
-(void)actionPrev:(id)sender;
-(void)moveToPrevResult;
-(void)moveToNextResult;

@end
