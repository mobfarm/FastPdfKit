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
#import "MediaPlayer/MediaPlayer.h"

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class MiniSearchViewController;
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

@interface ReaderViewController : MFDocumentViewController <MFDocumentViewControllerDelegate,UIPopoverControllerDelegate,TextDisplayViewControllerDelegate,SearchViewControllerDelegate,BookmarkViewControllerDelegate,OutlineViewControllerDelegate,MiniSearchViewControllerDelegate> {
	
	UILabel * numberOfPageTitleToolbar;
	UILabel * pageNumLabel;
	
	id senderText;
	id senderSearch;
    
    CGFloat navigationbarHeight;
	
    NSUInteger currentReusableView;         // This flag is used to keep track of what alternate controller is displayed to the user
    NSUInteger currentSearchViewMode;       // This flag keep track of which search view is currently in use, full or mini
    
    // Flags
    
    BOOL willFollowLink;
    BOOL hudHidden; // General HUD visible flag
	BOOL multimediaVisible;
    BOOL pdfOpen;
	BOOL thumbsViewVisible;
    BOOL waitingForTextInput;
    
    void (^dismissBlock) ();
}

/**
 * If set to YES, this controller will populate the navigation bar with its own
 * item.
 */
@property (nonatomic, readwrite) BOOL useNavigationControllerNavigationbar;

/**
 * This is the navigation bar used as top toolbar, unless you choose to populate
 * the navigation controller navigation bar.
 */
@property (nonatomic, strong) UINavigationBar * navigationbar;

/**
 * This value is used to determine where to place the top bar.
 */
@property (nonatomic, readwrite) CGFloat topBarMarginFroTop;

/**
 This block will be executed inside the actionDismiss action. If not defined,
 the ReaderViewController will try to guesstimate the appropriate action.
 */
@property (nonatomic, copy) void (^dismissBlock) ();

@property (nonatomic,strong) UIButton *changeModeButton;
@property (nonatomic,strong) UIButton *zoomLockButton;
@property (nonatomic,strong) UIButton *changeDirectionButton;
@property (nonatomic,strong) UIButton *changeLeadButton;

@property (nonatomic,strong) UIImage * imgModeSingle;
@property (nonatomic,strong) UIImage * imgModeDouble;
@property (nonatomic,strong) UIImage * imgZoomLock;
@property (nonatomic,strong) UIImage * imgZoomUnlock;
@property (nonatomic,strong) UIImage * imgl2r;
@property (nonatomic,strong) UIImage * imgr2l;
@property (nonatomic,strong) UIImage * imgLeadRight;
@property (nonatomic,strong) UIImage * imgLeadLeft;
@property (nonatomic,strong) UIImage * imgModeOverflow;
@property (nonatomic,strong) UIImage * imgDismiss;
@property (nonatomic,strong) UIImage * imgBookmark;
@property (nonatomic,strong) UIImage * imgSearch;
@property (nonatomic,strong) UIImage * imgOutline;
@property (nonatomic,strong) UIImage * imgText;
@property (nonatomic, readwrite) CGFloat navigationbarHeight;

-(void)updatePageNumberLabel;

-(void)showToolbar;
-(void)hideToolbar;

@property (nonatomic, strong) UINavigationBar * rollawayNavigationbar;
@property (nonatomic, strong) UILabel * pageNumLabel;

@property (nonatomic, strong) UIBarButtonItem * searchBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * changeModeBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * zoomLockBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * changeDirectionBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * changeLeadBarButtonItem;

@property (nonatomic, strong) UIBarButtonItem * bookmarkBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * textBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * numberOfPageTitleBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * dismissBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem * outlineBarButtonItem;

@property (nonatomic, strong) UILabel * numberOfPageTitleToolbar;

@property (nonatomic, strong) SearchViewController * searchViewController;
@property (nonatomic, strong) SearchManager * searchManager;
@property (nonatomic, strong) MiniSearchView * miniSearchView;
@property (nonatomic, strong) TextDisplayViewController * textDisplayViewController;
@property (nonatomic, strong) MiniSearchViewController * miniSearchViewController;

@property (nonatomic, readwrite, getter = isMultimediaVisible) BOOL multimediaVisible;

/**
 * This is a single popover controller that will be used to display alternate content view controller.
 */
@property (nonatomic, strong) UIPopoverController * reusablePopover;

@property (copy, nonatomic, readwrite) NSString * pageLabelFormat;

-(void)dismissAlternateViewController;
-(void)playVideo:(NSString *)path local:(BOOL)isLocal;
-(void)playAudio:(NSString *)path local:(BOOL)isLocal;
-(void)showWebView:(NSString *)path local:(BOOL)isLocal;

@end
