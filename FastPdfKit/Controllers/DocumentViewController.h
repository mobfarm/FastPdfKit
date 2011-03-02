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
#import "MFHorizontalSlider.h"
#import "BookmarkViewControllerDelegate.h"
#import "SearchViewControllerDelegate.h"
#import "MiniSearchViewControllerDelegate.h"
#import "OutlineViewControllerDelegate.h"
#import "TextDisplayViewControllerDelegate.h"

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class SearchManager;
@class MiniSearchView;
@class MFTextItem;

@interface DocumentViewController : MFDocumentViewController <TextDisplayViewControllerDelegate,MFDocumentViewControllerDelegate,MFSliderDelegate,UIPopoverControllerDelegate,BookmarkViewControllerDelegate,SearchViewControllerDelegate,MiniSearchViewControllerDelegate,OutlineViewControllerDelegate>{

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
	UILabel *numPaginaLabel;
	UISlider *pageSlider;
	
	BOOL hudHidden; // HUD status flag.
	BOOL miniSearchVisible;
	
	NSUInteger thumbPage;
	
	// Text extraction controller and stuff.
	BOOL waitingForTextInput;
	TextDisplayViewController *textDisplayViewController;
	
	// Text search controller and stuff.
	SearchViewController *searchViewController;
	SearchManager *searchManager;
	MiniSearchView *miniSearchView;
	
	NSString *nomefile;
	BOOL pdfIsOpen;
	
		

}

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager;
//-(void)dismissBookmark:(id)sender;
-(void)dismissOutline:(id)sender;
-(void)dismissSearch:(id)sender;
// Swapping search views.
-(void)switchToMiniSearchView:(MFTextItem *)index;
-(void)dismissMiniSearchView;
-(void)revertToFullSearchView;
-(void)actionDone:(id)sender;

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
@property (nonatomic, retain) UILabel *numPaginaLabel;
@property (nonatomic, retain) UISlider *pageSlider;
@property (nonatomic, retain) UIButton *bookmarksButton;
@property (nonatomic, retain) UIButton *outlineButton;

@property (nonatomic, retain) NSMutableArray *thumbImgArray;


@property (nonatomic, retain) NSString *nomefile;
@property (nonatomic) BOOL pdfIsOpen;
@property (nonatomic,assign) BOOL miniSearchVisible;

@property (nonatomic, retain) id senderSearch;
@property (nonatomic, retain) id senderText;


@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) SearchManager *searchManager;
@property (nonatomic, retain) MiniSearchView *miniSearchView;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;
@end
