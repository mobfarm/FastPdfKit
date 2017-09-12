//
//  ReaderViewController.h
//  FastPDFKit
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
@class SearchManager;
@class MiniSearchView;

@interface ReaderViewController : MFDocumentViewController <MFDocumentViewControllerDelegate,UIPopoverControllerDelegate,TextDisplayViewControllerDelegate,SearchViewControllerDelegate,BookmarkViewControllerDelegate,OutlineViewControllerDelegate,MiniSearchViewControllerDelegate,UIToolbarDelegate>
    
/**
 This block will be executed inside the actionDismiss action. If not defined,
 the ReaderViewController will try to guesstimate the appropriate action.
 */
@property (nonatomic, copy) void (^dismissBlock) ();

@property (nonatomic,retain) UIImage * imgModeSingle;
@property (nonatomic,retain) UIImage * imgModeDouble;
@property (nonatomic,retain) UIImage * imgZoomLock;
@property (nonatomic,retain) UIImage * imgZoomUnlock;
@property (nonatomic,retain) UIImage * imgl2r;
@property (nonatomic,retain) UIImage * imgr2l;
@property (nonatomic,retain) UIImage * imgLeadRight;
@property (nonatomic,retain) UIImage * imgLeadLeft;
@property (nonatomic,retain) UIImage * imgModeOverflow;
@property (nonatomic,retain) UIImage * imgDismiss;
@property (nonatomic,retain) UIImage * imgBookmark;
@property (nonatomic,retain) UIImage * imgSearch;
@property (nonatomic,retain) UIImage * imgOutline;
@property (nonatomic,retain) UIImage * imgText;
@property (nonatomic, readwrite) CGFloat toolbarHeight;

-(void)updatePageNumberLabel;

-(void)showToolbar;
-(void)hideToolbar;

@property (nonatomic, retain) UIToolbar * rollawayToolbar;
@property (nonatomic, retain) UILabel * pageNumLabel;

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

@property (nonatomic, retain) OutlineViewController * outlineViewController;
@property (nonatomic, retain) BookmarkViewController * bookmarksViewController;

@property (nonatomic, retain) SearchViewController * searchViewController;
@property (nonatomic, retain) MiniSearchView * miniSearchView;
@property (nonatomic, retain) TextDisplayViewController * textDisplayViewController;

@property (nonatomic, readwrite, getter = isMultimediaVisible) BOOL multimediaVisible;

@property (nonatomic, retain) UIPopoverController * reusablePopover;

@property (nonatomic, readwrite) CGSize popoverContentSize;

@property (copy, nonatomic, readwrite) NSString * pageLabelFormat;

-(void)dismissAlternateViewController;
-(void)playVideo:(NSString *)path local:(BOOL)isLocal;
-(void)playAudio:(NSString *)path local:(BOOL)isLocal;
-(void)showWebView:(NSString *)path local:(BOOL)isLocal;

@end
