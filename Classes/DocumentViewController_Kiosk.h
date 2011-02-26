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

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class SearchManager;
@class MiniSearchView;
@class MFTextItem;

@interface DocumentViewController_Kiosk : MFDocumentViewController <MFDocumentViewControllerDelegate,MFSliderDelegate,UIPopoverControllerDelegate>{
	
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
	UILabel *numberOfPageTitleToolbar;
	UILabel *numPaginaLabel;
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
	
	MFHorizontalSlider *thumbsliderHorizontal;
	UIView *thumbSliderViewHorizontal;
	
	UIView *thumbSliderView;
	UIView *aTSVH;
	
	NSMutableArray *thumbImgArray;
	
	NSString *nomefile;
	BOOL pdfIsOpen;
	BOOL thumbsViewVisible;
	
	UIToolbar *toolbar;
	UIBarButtonItem *changeModeBarButtonItem;
	UIBarButtonItem *zoomLockBarButtonItem;
	UIBarButtonItem *changeDirectionButtonItem;
	UIBarButtonItem *changeLeadButtonItem;
	
	BOOL visibleBookmark;
	BOOL visibleOutline;
	BOOL visibleSearch;
	BOOL visibleText;
	
	id senderText;
	id senderSearch;
	
	UIPopoverController *popupBookmark;
	UIPopoverController *popupOutline;
	UIPopoverController *popupSearch;
	UIPopoverController *popupText;
	
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

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager;
-(void)initNumberOfPageToolbar;
-(void)setNumberOfPageToolbar;
-(void)showToolbar;
-(void)hideToolbar;
-(void)dismissBookmark:(id)sender;
-(void)dismissOutline:(id)sender;
-(void)dismissSearch:(id)sender;

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
@property  BOOL visibleBookmark;
@property  BOOL visibleOutline;
@property  BOOL visibleSearch;
@property  BOOL visibleText;
@property (nonatomic, retain) id senderSearch;
@property (nonatomic, retain) id senderText;
@property (nonatomic, retain) UIPopoverController *popupBookmark;
@property (nonatomic, retain) UIPopoverController *popupOutline;
@property (nonatomic, retain) UIPopoverController *popupSearch;
@property (nonatomic, retain) UIPopoverController *popupText;
@property CGFloat heightToolbar;
@property CGFloat widthborder;
@property CGFloat heightTSHV;

// Swapping search views.
-(void)switchToMiniSearchView:(MFTextItem *)index;
-(void)dismissMiniSearchView;
-(void)revertToFullSearchView;
-(void)showToolbar;
-(void)hideToolbar;
-(void)hideHorizontalThumbnails;
-(void)showHorizontalThumbnails;
-(void)dismissAllPopoversFrom:(id)sender;


@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) SearchManager *searchManager;
@property (nonatomic, retain) MiniSearchView *miniSearchView;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;
@end
