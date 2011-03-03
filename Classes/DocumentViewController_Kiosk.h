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
#import "BookmarkViewControllerDelegate.h"
#import "SearchViewControllerDelegate.h"
#import "MiniSearchViewControllerDelegate.h"
#import "OutlineViewControllerDelegate.h"
#import "MFHorizontalSlider.h"
#import "TextDisplayViewControllerDelegate.h"

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class SearchManager;
@class MiniSearchView;
@class MFTextItem;

@interface DocumentViewController_Kiosk : MFDocumentViewController <MFDocumentViewControllerDelegate,MFSliderDelegate,UIPopoverControllerDelegate>{
	
	// UI elements.
	
	UILabel * pageLabel;
	UILabel * numberOfPageTitleToolbar;
	UILabel * numPaginaLabel;
	UISlider * pageSlider;
	
	BOOL hudHidden; // HUD status flag.
	
	// Thumbnail view and stuff.
	UIImageView * thumbnailView;
	NSUInteger thumbPage;
	
	// Text extraction controller and stuff.
	BOOL waitingForTextInput;
	TextDisplayViewController * textDisplayViewController;
	
	// Text search controller and stuff.
	SearchViewController * searchViewController;
	SearchManager * searchManager;
	MiniSearchView * miniSearchView;
	
	MFHorizontalSlider * thumbsliderHorizontal;
	UIView * thumbSliderViewHorizontal;
	
	UIView * thumbSliderView;
	UIView * aTSVH;
	
	NSMutableArray * thumbImgArray;
	
	NSString * nomefile;
	
	BOOL pdfIsOpen;
	BOOL thumbsViewVisible;
	BOOL miniSearchVisible;
	
	UIToolbar *toolbar;
	UIBarButtonItem *changeModeBarButtonItem;
	UIBarButtonItem *zoomLockBarButtonItem;
	UIBarButtonItem *changeDirectionButtonItem;
	UIBarButtonItem *changeLeadButtonItem;
	
	id senderText;
	id senderSearch;
	
	UIImage *imgChangeMode;
	UIImage *imgChangeModeDouble;
	
	UIImage *imgZoomLock;
	UIImage *imgZoomUnlock;
	
	UIImage *imgl2r;
	UIImage *imgr2l;
	
	UIImage *imgChangeLead;
	UIImage *imgChangeLeadClick;
	
	CGFloat heightToolbar;
	CGFloat widthborder;
	CGFloat heightTSHV;
}

-(void)initNumberOfPageToolbar;
-(void)setNumberOfPageToolbar;

-(void)showToolbar;
-(void)hideToolbar;

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

@property (nonatomic, retain) MFHorizontalSlider *thumbsliderHorizontal;
@property (nonatomic, retain) UIView *thumbSliderViewHorizontal;
@property (nonatomic, retain) UIView *thumbSliderView;
@property (nonatomic, retain) UIView *aTSVH;

@property (nonatomic, retain) NSString *nomefile;
@property (nonatomic) BOOL pdfIsOpen;
@property (nonatomic) BOOL thumbsViewVisible;
@property  BOOL visibleBookmarkView;
@property  BOOL visibleOutlineView;
@property  BOOL visibleSearchView;
@property  BOOL visibleTextView;
@property (assign) BOOL miniSearchVisible;
@property (nonatomic, retain) id senderSearch;
@property (nonatomic, retain) id senderText;
@property (nonatomic, retain) UIPopoverController *bookmarkPopover;
@property (nonatomic, retain) UIPopoverController *outlinePopover;
@property (nonatomic, retain) UIPopoverController *searchPopover;
@property (nonatomic, retain) UIPopoverController *textPopover;
@property CGFloat heightToolbar;
@property CGFloat widthborder;
@property CGFloat heightTSHV;

// Swapping search views.
-(void)showToolbar;
-(void)hideToolbar;
-(void)hideHorizontalThumbnails;
-(void)showHorizontalThumbnails;


@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) SearchManager *searchManager;
@property (nonatomic, retain) MiniSearchView *miniSearchView;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;
@end
