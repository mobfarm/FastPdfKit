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
	id delegate;
	id dataSource;
	id senderButton;
	UIImageView *corner;
	BOOL temp;
	int numDocumento;
	ASIHTTPRequest *request;
	BOOL pdfInDownload;
	MenuViewController *mvc;
	NSString *PdfToDownload;
}

@property (nonatomic,assign) id object;
@property (nonatomic,assign) id dataSource;
@property (nonatomic,assign) id senderButton;
@property (nonatomic,retain) UIImageView *corner;
@property (nonatomic,retain) NSString *PdfToDownload;
@property (nonatomic) BOOL temp;
@property (nonatomic, assign) MenuViewController *mvc;
@property (nonatomic, assign) int numDocumento;

- (id)initWithName:(NSString *)Page andnumOfDoc:(int)numDoc andImage:(NSString *)_image andSize:(CGSize)_size;
- (void)setSelected:(BOOL)selected;
- (void)updateCorner;

@end
