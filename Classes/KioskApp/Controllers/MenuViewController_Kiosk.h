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

	UIView * downloadProgressContainerView;
	
	UIProgressView * downloadProgressView;
	
	NSMutableArray * homeListPdfs;
	NSMutableDictionary * buttonRemoveDict;
	NSMutableDictionary * openButtons;
	NSMutableDictionary * progressViewDict;
	NSMutableDictionary * imgDict;
	
	NSMutableArray *documentsList;
    
    UIScrollView *scrollView;
	
	BOOL graphicsMode;
    BOOL interfaceLoaded;
}

-(IBAction)actionOpenPlainDocument:(NSString *)documentName;
-(void)buildInterface;
//-(void)showViewDownload;
//-(void)hideViewDownload;

//@property (nonatomic, retain) MFDocumentManager *document;
@property (nonatomic, retain) NSMutableArray *documentsList;
@property (nonatomic, retain) UIScrollView *scrollView;
//@property (nonatomic,retain ) UIProgressView *downloadProgressView;
//@property (nonatomic,retain ) UIView *downloadProgressContainerView;

//@property (nonatomic, assign) UIAlertView *passwordAlertView;
//@property (nonatomic, assign) NSString *documentName;
@property (nonatomic,retain ) NSDictionary *buttonRemoveDict;
@property (nonatomic,retain ) NSDictionary *openButtons;
@property (nonatomic,retain ) NSDictionary *progressViewDict;
@property (nonatomic,retain ) NSDictionary *imgDict;
@property (nonatomic,assign ) BOOL graphicsMode;
@property (nonatomic,assign ) BOOL interfaceLoaded;

@end
