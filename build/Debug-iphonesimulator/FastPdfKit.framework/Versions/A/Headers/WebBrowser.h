//
//  WebBrowser.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/03/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderViewController.h"

@interface WebBrowser : UIViewController {
    IBOutlet UIBarButtonItem *closeButton;
	IBOutlet UIWebView *webView;
	NSString *uri;
	ReaderViewController *docViewController;
	BOOL local;
}

@property (nonatomic,retain)IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic,retain)IBOutlet UIWebView *webView;
@property (nonatomic,copy) NSString *uri;
@property (nonatomic,assign) ReaderViewController *docViewController;
@property (nonatomic,readwrite,getter = isLocal) BOOL local;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)uri local:(BOOL)isLocal;
- (IBAction)actionDismiss;

@end
