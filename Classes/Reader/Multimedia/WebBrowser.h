//
//  WebBrowser.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/03/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentViewController_Kiosk.h"

@interface WebBrowser : UIViewController {
    IBOutlet UIBarButtonItem *closeButton;
	IBOutlet UIWebView *webView;
	NSString *uri;
	DocumentViewController_Kiosk *docViewController;
	BOOL local;
}

@property (nonatomic,retain)IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic,retain)IBOutlet UIWebView *webView;
@property (nonatomic,copy) NSString *uri;
@property (nonatomic,assign) DocumentViewController_Kiosk *docViewController;
@property (nonatomic,readwrite,getter = isLocal) BOOL local;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)uri local:(BOOL)isLocal;
- (IBAction)actionDismiss;

@end
