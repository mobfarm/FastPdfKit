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
	int page;
	id delegate;
	id dataSource;
	id senderButton;
	UIImageView *corner;
	BOOL temp;
	
	ASIHTTPRequest *request;
	BOOL pdfInDownload;
	MenuViewController *mvc;
}

@property (nonatomic,assign) id object;
@property (nonatomic,assign) id dataSource;
@property (nonatomic,assign) id senderButton;
@property (nonatomic,retain) UIImageView *corner;
@property (nonatomic) BOOL temp;

- (id)initWithPageNumber:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size;
- (id)initWithPageNumberNoThumb:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source;
- (void)setSelected:(BOOL)selected;
- (void)updateCorner;

@end
