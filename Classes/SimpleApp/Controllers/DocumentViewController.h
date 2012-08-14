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
#import "TextDisplayViewControllerDelegate.h"

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class SearchManager;
@class MiniSearchView;
@class MFTextItem;

#define FPK_REUSABLE_VIEW_NONE 0
#define FPK_REUSABLE_VIEW_SEARCH 1
#define FPK_REUSABLE_VIEW_TEXT 2
#define FPK_REUSABLE_VIEW_OUTLINE 3
#define FPK_REUSABLE_VIEW_BOOKMARK 4

#define FPK_SEARCH_VIEW_MODE_MINI 0
#define FPK_SEARCH_VIEW_MODE_FULL 1

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
	
	NSUInteger thumbPage;
	
	// Text extraction controller and stuff.
	BOOL waitingForTextInput;
	TextDisplayViewController *textDisplayViewController;
	
	// Text search controller and stuff.
	SearchViewController * searchViewController;
	SearchManager * searchManager;
	MiniSearchView * miniSearchView;
	
    // Document's ID. We use this as an unique id for bookmarks and other per-document data.
    
    NSString * nomefile;
	
	// Popover management.
	
	UIPopoverController *reusablePopover;   // This is a single popover controller that will be used to display alternate content view controller.
    NSUInteger currentReusableView;         // This flag is used to keep track of what alternate controller is displayed to the user.
    NSUInteger currentSearchViewMode;
    
    // Needed to support links between pdf documents: points to MenuViewController
    id delegate;
}


-(void)switchToMiniSearchView:(MFTextItem *)index;
-(void)dismissMiniSearchView;
-(void)revertToFullSearchView;
-(void)showMiniSearchView;
-(IBAction) actionDismiss:(id)sender;

@property (nonatomic, assign) id delegate;

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

@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) SearchManager *searchManager;
@property (nonatomic, retain) MiniSearchView *miniSearchView;

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;

@property (nonatomic, retain) UIPopoverController * reusablePopover;

@end
