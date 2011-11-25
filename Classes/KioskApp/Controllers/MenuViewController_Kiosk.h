//
//  MenuViewController_Kiosk.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController_Kiosk.h"
#import "ReaderViewController.h"

@class MFDocumentManager;


@interface MenuViewController_Kiosk : UIViewController {

	NSMutableArray * bookItemViews;
    
	NSMutableDictionary * buttonRemoveDict;
	NSMutableDictionary * openButtons;
	NSMutableDictionary * progressViewDict;
	NSMutableDictionary * imgDict;
	
	NSMutableArray *documentsList;
    
    UIScrollView *scrollView;
    
	UIView * downloadProgressContainerView;
	UIProgressView * downloadProgressView;
	
	BOOL graphicsMode;
    BOOL interfaceLoaded;
    
    BOOL xmlDirty;
}

-(IBAction)actionOpenPlainDocument:(NSString *)documentName;
-(void)buildInterface;

@property (nonatomic, retain) NSMutableArray *documentsList;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic,retain ) NSDictionary *buttonRemoveDict;
@property (nonatomic,retain ) NSDictionary *openButtons;
@property (nonatomic,retain ) NSDictionary *progressViewDict;
@property (nonatomic,retain ) NSDictionary *imgDict;
@property (nonatomic,assign ) BOOL graphicsMode;
@property (nonatomic,assign ) BOOL interfaceLoaded;

@end
