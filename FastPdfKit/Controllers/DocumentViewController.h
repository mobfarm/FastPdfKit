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

@interface DocumentViewController : MFDocumentViewController <TextDisplayViewControllerDelegate,MFDocumentViewControllerDelegate,UIPopoverControllerDelegate,BookmarkViewControllerDelegate,SearchViewControllerDelegate,MiniSearchViewControllerDelegate,OutlineViewControllerDelegate> {
	
	@protected
	
	// UI elements.
	UIButton * leadButton;
	UIButton * modeButton;
	UIButton * directionButton;
	UIButton * autozoomButton;
	UIButton * automodeButton;
	 
	UIButton * dismissButton;
	UIButton * bookmarksButton;
	UIButton * outlineButton;
	
	UIButton * nextButton;
	UIButton * prevButton;
	
	UIButton * searchButton;
	
	UIButton * textButton;
	
	UILabel * pageLabel;
	UISlider * pageSlider;
	
	BOOL hudHidden; // HUD status flag.
	BOOL miniSearchVisible;
	
	NSUInteger thumbPage;
	
	// Text extraction controller and stuff.
	BOOL waitingForTextInput;
	TextDisplayViewController *textDisplayViewController;
	
	// Text search controller and stuff.
	SearchViewController * searchViewController;
	SearchManager * searchManager;
	MiniSearchView * miniSearchView;
	
    // Document's ID. We use this as an unique id for bookmarks and other per-document data.
    NSString * documentId;
	
	NSString * nomefile;
	
	// Popover management.
	
	BOOL visibleBookmarkView;
	BOOL visibleOutlineView;
	BOOL visibleSearchView;
	BOOL visibleTextView;
	
	UIPopoverController *bookmarkPopover;
	UIPopoverController *outlinePopover;
	UIPopoverController *searchPopover;
	UIPopoverController *textPopover;

}

-(void)dismissAllPopovers;

-(void)switchToMiniSearchView:(MFTextItem *)index;
-(void)dismissMiniSearchView;
-(void)revertToFullSearchView;
-(void)showMiniSearchView;

@property (nonatomic, copy) NSString * documentId;

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

@property (nonatomic, retain) UIPopoverController *bookmarkPopover;
@property (nonatomic, retain) UIPopoverController *outlinePopover;
@property (nonatomic, retain) UIPopoverController *searchPopover;
@property (nonatomic, retain) UIPopoverController *textPopover;

@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) SearchManager *searchManager;
@property (nonatomic, retain) MiniSearchView *miniSearchView;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;

@end
