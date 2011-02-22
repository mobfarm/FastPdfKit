//
//  ThumbnailViewController.h
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MenuViewController.h"

@interface MFHomeListPdf : UIViewController {
	id object;
	NSString *thumbnail;
	CGSize size;
	NSString *page;
	NSString *linkDownloadPdf;
	id delegate;
	id dataSource;
	id senderButton;
	UIImageView *corner;
	BOOL temp;
	int numDocumento;
	ASIHTTPRequest *request;
	BOOL pdfInDownload;
	MenuViewController *mvc;
	NSString *pdfToDownload;
	UIButton *removeButton;
	UIButton *openButton;
	UIProgressView *progressDownload;
	
	CGFloat yProgressBar;
	CGFloat xBtnRemove;
	CGFloat yBtnRemove;
	CGFloat xBtnOpen;
	CGFloat yBtnOpen;
	CGFloat widthButton;
	CGFloat heightButton;
}

@property (nonatomic,assign) id object;
@property (nonatomic,assign) id dataSource;
@property (nonatomic,assign) id senderButton;
@property (nonatomic,retain) UIImageView *corner;
@property (nonatomic,retain) NSString *pdfToDownload;
@property (nonatomic,retain) NSString *linkDownloadPdf;
@property (nonatomic) BOOL temp;
@property (nonatomic, assign) MenuViewController *mvc;
@property (nonatomic, assign) int numDocumento;
@property (nonatomic,copy) NSString *page;
@property (nonatomic,retain ) UIButton *removeButton;
@property (nonatomic,retain ) UIButton *openButton;
@property (nonatomic,retain ) UIProgressView *progressDownload;
@property CGFloat yProgressBar;
@property CGFloat xBtnRemove;
@property CGFloat yBtnRemove;
@property CGFloat widthButton;
@property CGFloat heightButton;
@property CGFloat xBtnOpen;
@property CGFloat yBtnOpen;

- (id)initWithName:(NSString *)Page andLinkPdf:(NSString *)linkpdf andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size;
- (void)setSelected:(BOOL)selected;
- (void)updateCorner;

@end
