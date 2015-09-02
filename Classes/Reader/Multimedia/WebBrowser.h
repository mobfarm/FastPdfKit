//
//  WebBrowser.h
//  FastPdfKit
//
//  Created by Gianluca Orsini on 28/03/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderViewController.h"

@interface WebBrowser : UIViewController

@property (nonatomic, strong)IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, strong)IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, weak) ReaderViewController *docViewController;
@property (nonatomic, readwrite,getter = isLocal) BOOL local;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)uri local:(BOOL)isLocal;
- (IBAction)actionDismiss;

@end
