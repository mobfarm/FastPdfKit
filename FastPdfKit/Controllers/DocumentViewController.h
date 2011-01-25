//
//  DocumentViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/25/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentViewController.h"
#import "MFDocumentViewControllerDelegate.h"

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class SearchManager;
@class MiniSearchView;
@class MFTextItem;

@interface DocumentViewController : MFDocumentViewController <MFDocumentViewControllerDelegate>{

	// UI elements.
	UIButton *leadButton;
	UIButton *modeButton;
	UIButton *directionButton;
	UIButton *autozoomButton;
	UIButton *automodeButton;
	
	UIButton *dismissButton;
	UIButton *bookmarksButton;
	UIButton *outlineButton;
	
	UIButton *nextButton;
	UIButton *prevButton;
	
	UIButton *searchButton;
	
	UIButton *textButton;
	
	UILabel *pageLabel;
	UISlider *pageSlider;
	
	BOOL hudHidden; // HUD status flag.
	
	// Thumbnail view and stuff.
	UIImageView *thumbnailView;
	NSUInteger thumbPage;
	
	// Text extraction controller and stuff.
	BOOL waitingForTextInput;
	TextDisplayViewController *textDisplayViewController;
	
	// Text search controller and stuff.
	SearchViewController *searchViewController;
	SearchManager *searchManager;
	MiniSearchView *miniSearchView;
	
	
}

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager;

@property (nonatomic, retain) UIImageView *thumbnailView;

@property (nonatomic, retain) UIButton *textButton;
@property (nonatomic, retain) TextDisplayViewController *textDisplayViewController;

@property (nonatomic, retain) UIButton *leadButton;
@property (nonatomic, retain) UIButton *modeButton;
@property (nonatomic, retain) UIButton *directionButton;
@property (nonatomic, retain) UIButton *autozoomButton;
@property (nonatomic, retain) UIButton *automodeButton;
@property (nonatomic, retain) UIButton *dismissButton;
@property (nonatomic, retain) UILabel *pageLabel;
@property (nonatomic, retain) UISlider *pageSlider;
@property (nonatomic, retain) UIButton *bookmarksButton;
@property (nonatomic, retain) UIButton *outlineButton;

// Swapping search views.
-(void)switchToMiniSearchView:(MFTextItem *)index;
-(void)dismissMiniSearchView;
-(void)revertToFullSearchView;

@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) SearchManager *searchManager;
@property (nonatomic, retain) MiniSearchView *miniSearchView;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;
@end
