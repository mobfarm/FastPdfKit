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

@interface DocumentViewController : MFDocumentViewController <MFDocumentViewControllerDelegate>{

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
	
	UIButton *textButton;
	
	UILabel *pageLabel;
	UISlider *pageSlider;
	
	BOOL hudHidden;
	
	UIImageView *thumbnailView;
	NSUInteger thumbPage;
}

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager;

@property (nonatomic, retain) UIImageView *thumbnailView;

@property (nonatomic, retain) UIButton *textButton;

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

@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *prevButton;
@end
