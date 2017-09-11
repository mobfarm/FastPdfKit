//
//  MFHomeListPdf.h
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MenuViewController_Kiosk.h"
#import <Newsstandkit/NewsstandKit.h>

@interface BookItemView : UIViewController <UIActionSheetDelegate,NSURLConnectionDownloadDelegate>

@property (nonatomic,copy) NSString *thumbName;
@property (nonatomic,weak) id object;
@property (nonatomic,weak) id dataSource;
@property (nonatomic,strong) UIImageView *corner;

@property (nonatomic,copy) NSString *downloadUrl;
@property (nonatomic) BOOL temp;
@property (nonatomic) BOOL isPdfLink;
@property (nonatomic) BOOL downloadPdfStopped;
@property (nonatomic, weak) MenuViewController_Kiosk *menuViewController;
@property (nonatomic, readwrite) int documentNumber;
@property (nonatomic,copy) NSString *page;
@property (nonatomic,copy) NSString *titleOfPdf;
@property (nonatomic,strong) UIButton *removeButton;
@property (nonatomic,strong) UIButton *openButton;
@property (nonatomic,strong) UIButton *openButtonFromImage;
@property (nonatomic,strong) UIProgressView *progressDownload;
@property (nonatomic,strong) UIImageView *thumbImage;
@property (nonatomic,strong) ASIHTTPRequest * httpRequest;

- (id)initWithName:(NSString *)Page andTitoloPdf:(NSString *)titoloPdf andLinkPdf:(NSString *)linkpdf andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size;
- (void)setSelected:(BOOL)selected;
- (void)updateCorner;
- (void)downloadPDF:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf;
- (void)downloadImage:(id)sender withUrl:(NSString *)_url andName:(NSString *)nomefilepdf;
- (BOOL)checkIfPDfLink:(NSString *)url;
- (BOOL)handleFPKFile;
- (void)updateBtnDownload;

@end
