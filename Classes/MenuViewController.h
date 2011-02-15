//
//  MenuViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/26/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_PASSWORDFIELD 77

@class MFDocumentManager;

@interface MenuViewController : UIViewController {

	IBOutlet UIButton *referenceButton;
	IBOutlet UIButton *manualButton;
	IBOutlet UITextView *referenceTextView;
	IBOutlet UITextView *manualTextView;
	
	MFDocumentManager *document;
	
	UIAlertView *passwordAlertView;
	
	UIScrollView *scrollView;
	UIView *DownloadProgress;
	UIProgressView *downloadProgressView;
	NSDictionary *buttonRemoveDict;
	
	NSString *nomePdfDaAprire;
}

-(IBAction)actionOpenPlainDocument:(id)sender;
-(IBAction)actionOpenPlainDocumentFromNewMain:(id)sender;

-(IBAction)actionOpenEncryptedDocument:(id)sender;
-(void)showViewDownload;
-(void)hideViewDownload;

@property (nonatomic, retain) IBOutlet UIButton *referenceButton;
@property (nonatomic, retain) IBOutlet UIButton *manualButton;
@property (nonatomic, retain) IBOutlet UITextView *referenceTextView;
@property (nonatomic, retain) IBOutlet UITextView *manualTextView;

@property (nonatomic, retain) MFDocumentManager *document;
@property (nonatomic, assign) NSString *nomePdfDaAprire;
@property (nonatomic,retain ) UIProgressView *downloadProgressView;
@property (nonatomic,retain ) UIView *DownloadProgress;

@property (nonatomic, assign) UIAlertView *passwordAlertView;
@property (nonatomic,retain ) NSDictionary *buttonRemoveDict;

@end
