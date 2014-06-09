//
//  MFHomeListPdf.h
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController_Kiosk.h"
#import <Newsstandkit/NewsstandKit.h>
#import "AFNetworking.h"

@interface BookItemView : UIViewController <UIActionSheetDelegate,NSURLConnectionDownloadDelegate>{
	
	id __weak object;
	NSString *thumbName;
	CGSize size;
	NSString *page;
	NSString *downloadUrl;
    NSString *titleOfPdf;
	id delegate;
	id __weak dataSource;
	UIImageView *corner;
	BOOL temp;
	int documentNumber;
	
	AFHTTPRequestOperation *httpRequest;
	
	BOOL pdfInDownload;
    BOOL isPdfLink;
	MenuViewController_Kiosk * __weak menuViewController;
	NSString *pdfToDownload;
	UIButton *removeButton;
	UIButton *openButton;
	UIButton *openButtonFromImage;
	UIProgressView *progressDownload;
	UIImageView *thumbImage;
	
    BOOL downloadPdfStopped;
}

@property (nonatomic,copy) NSString *thumbName;
@property (nonatomic, weak) id object;
@property (nonatomic, weak) id dataSource;
@property (nonatomic,retain) UIImageView *corner;

@property (nonatomic,copy) NSString *downloadUrl;
@property (nonatomic) BOOL temp;
@property (nonatomic) BOOL isPdfLink;
@property (nonatomic) BOOL downloadPdfStopped;
@property (nonatomic, weak) MenuViewController_Kiosk *menuViewController;
@property (nonatomic, assign) int documentNumber;
@property (nonatomic,copy) NSString *page;
@property (nonatomic,copy) NSString *titleOfPdf;
@property (nonatomic,retain ) UIButton *removeButton;
@property (nonatomic,retain ) UIButton *openButton;
@property (nonatomic,retain ) UIButton *openButtonFromImage;
@property (nonatomic,retain ) UIProgressView *progressDownload;
@property (nonatomic,retain ) UIImageView *thumbImage;
@property (nonatomic,retain) AFHTTPRequestOperation * httpRequest;

- (id)initWithName:(NSString *)Page andTitoloPdf:(NSString *)titoloPdf andLinkPdf:(NSString *)linkpdf andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size;
- (void)setSelected:(BOOL)selected;
- (void)updateCorner;
- (void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf;
- (void)downloadImage:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf;
- (BOOL)checkIfPDfLink:(NSString *)url;
- (BOOL)handleFPKFile;
- (void)updateBtnDownload;

@end
