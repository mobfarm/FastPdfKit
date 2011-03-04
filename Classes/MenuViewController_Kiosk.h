//
//  MenuViewController_Kiosk.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MenuViewController_Kiosk.h"
#import "DocumentViewController_Kiosk.h"

@class MFDocumentManager;


@interface MenuViewController_Kiosk : UIViewController {

	IBOutlet UIButton *referenceButton;
	IBOutlet UIButton *manualButton;
	IBOutlet UITextView *referenceTextView;
	IBOutlet UITextView *manualTextView;
	
	MFDocumentManager *document;
	
	UIAlertView *passwordAlertView;
	
	UIScrollView * scrollView;
	
	UIView * DownloadProgress;
	
	UIProgressView * downloadProgressView;
	
	NSDictionary * buttonRemoveDict;
	NSDictionary * buttonOpenDict;
	NSDictionary * progressViewDict;
	NSDictionary * imgDict;
	
	NSMutableArray *pdfHome;
	
	NSString *documentName;
	
	CGFloat thumbWidth;
	CGFloat thumbHeight;
	CGFloat buttonWidth;
	CGFloat buttonHeight;
	CGFloat scrollViewWidth;
	CGFloat scrollViewHeight;
	CGFloat detailViewHeight;
	CGFloat thumbHOffsetLeft;
	CGFloat thumHOffsetRight;
	CGFloat frameHeight;
	CGFloat scrollViewVOffset;
	
	BOOL graphicsMode;
}

-(IBAction)actionOpenPlainDocumentFromNewMain:(id)sender;
-(void)showViewDownload;
-(void)hideViewDownload;

@property (nonatomic, retain) IBOutlet UIButton *referenceButton;
@property (nonatomic, retain) IBOutlet UIButton *manualButton;
@property (nonatomic, retain) IBOutlet UITextView *referenceTextView;
@property (nonatomic, retain) IBOutlet UITextView *manualTextView;

@property (nonatomic, retain) MFDocumentManager *document;
@property (nonatomic, assign) NSMutableArray *pdfHome;
@property (nonatomic,retain ) UIProgressView *downloadProgressView;
@property (nonatomic,retain ) UIView *DownloadProgress;

@property (nonatomic, assign) UIAlertView *passwordAlertView;
@property (nonatomic, assign) NSString *documentName;
@property (nonatomic,retain ) NSDictionary *buttonRemoveDict;
@property (nonatomic,retain ) NSDictionary *buttonOpenDict;
@property (nonatomic,retain ) NSDictionary *progressViewDict;
@property (nonatomic,retain ) NSDictionary *imgDict;
@property (nonatomic,assign ) BOOL graphicsMode;

@property CGFloat thumbWidth;
@property CGFloat thumbHeight;
@property CGFloat buttonWidth;
@property CGFloat buttonHeight;
@property CGFloat scrollViewWidth;
@property CGFloat scrollViewHeight;
@property CGFloat detailViewHeight;
@property CGFloat thumbHOffsetLeft;
@property CGFloat thumHOffsetRight;
@property CGFloat frameHeight;
@property CGFloat scrollViewVOffset;

@end
