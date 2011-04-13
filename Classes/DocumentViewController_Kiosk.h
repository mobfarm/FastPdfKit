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
#import "MediaPlayer/MediaPlayer.h"

@class BookmarkViewController;
@class SearchViewController;
@class TextDisplayViewController;
@class SearchManager;
@class MiniSearchView;
@class MFTextItem;

@interface DocumentViewController_Kiosk : MFDocumentViewController <MFSliderDelegate,MFDocumentViewControllerDelegate,UIPopoverControllerDelegate,TextDisplayViewControllerDelegate,SearchViewControllerDelegate,BookmarkViewControllerDelegate,OutlineViewControllerDelegate> {
	
	// Thumbnail view and stuff.
	UIImageView * thumbnailView;
	
	// Text extraction controller and stuff.
	MFHorizontalSlider * thumbsliderHorizontal;
	UIView * thumbSliderViewHorizontal;
	
	NSMutableArray * thumbImgArray;
	
	BOOL pdfIsOpen;
	BOOL thumbsViewVisible;
	
	UIBarButtonItem *changeModeBarButtonItem;
	UIBarButtonItem *zoomLockBarButtonItem;
	UIBarButtonItem *changeDirectionBarButtonItem;
	UIBarButtonItem *changeLeadBarButtonItem;
	UIBarButtonItem *searchBarButtonItem;
	
	UILabel * numberOfPageTitleToolbar;
	UILabel * pageNumLabel;
	
	id senderText;
	id senderSearch;
	
	UIImage * imgModeSingle;
	UIImage * imgModeDouble;
	
	UIImage * imgZoomLock;
	UIImage * imgZoomUnlock;
	
	UIImage * imgl2r;
	UIImage * imgr2l;
	
	UIImage * imgLeadRight;
	UIImage * imgLeadLeft;
	
	CGFloat toolbarHeight;
	CGFloat thumbSliderViewBorderWidth;
	CGFloat thumbSliderViewHeight;
	
	UIToolbar * rollawayToolbar;
	
	BOOL waitingForTextInput;
	
	NSString * documentId;
	
	// Text search controller and stuff.
	SearchViewController * searchViewController;
	SearchManager * searchManager;
	MiniSearchView * miniSearchView;
	TextDisplayViewController * textDisplayViewController;
	
	BOOL hudHidden;
	BOOL miniSearchViewVisible;
	BOOL bookmarkViewVisible;
	BOOL outlineViewVisible;
	BOOL searchViewVisible;
	BOOL textViewVisible;
    BOOL visibleMultimedia;
	
	UIPopoverController *bookmarkPopover;
	UIPopoverController *outlinePopover;
	UIPopoverController *searchPopover;
	UIPopoverController *textPopover;
	
	UILabel * pageLabel;
	UISlider * pageSlider;
}

@property (nonatomic,retain) UIImage * imgModeSingle;
@property (nonatomic,retain) UIImage * imgModeDouble;
@property (nonatomic,retain) UIImage * imgZoomLock;
@property (nonatomic,retain) UIImage * imgZoomUnlock;
@property (nonatomic,retain) UIImage * imgl2r;
@property (nonatomic,retain) UIImage * imgr2l;
@property (nonatomic,retain) UIImage * imgLeadRight;
@property (nonatomic,retain) UIImage * imgLeadLeft;

-(void)setNumberOfPageToolbar;

-(void)showToolbar;
-(void)hideToolbar;

@property (nonatomic, retain) UIToolbar * rollawayToolbar;
@property (nonatomic, retain) UILabel * pageNumLabel;
@property (nonatomic, copy) NSString * documentId;

@property (nonatomic, retain) UISlider * pageSlider;

@property (nonatomic, retain) UIBarButtonItem * searchBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * changeModeBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * zoomLockBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * changeDirectionBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * changeLeadBarButtonItem;

@property (nonatomic, retain) UIBarButtonItem * bookmarkBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * textBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * numberOfPageTitleBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * dismissBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem * outlineBarButtonItem;

@property (nonatomic, retain) UILabel * numberOfPageTitleToolbar;

@property (nonatomic, retain) NSMutableArray *thumbImgArray;

@property (nonatomic, retain) MFHorizontalSlider *thumbsliderHorizontal;
@property (nonatomic, retain) UIView *thumbSliderViewHorizontal;

@property (nonatomic, retain) SearchViewController * searchViewController;
@property (nonatomic, retain) SearchManager * searchManager;
@property (nonatomic, retain) MiniSearchView * miniSearchView;
@property (nonatomic, retain) TextDisplayViewController * textDisplayViewController;
@property BOOL visibleMultimedia;

-(void)showToolbar;
-(void)hideToolbar;
-(void)hideHorizontalThumbnails;
-(void)showHorizontalThumbnails;
-(void)playvideo:(NSString *)_path isLocal:(BOOL)_isLocal;
-(void)prepareToolbar;
-(void)prepareThumbSlider;

@end
