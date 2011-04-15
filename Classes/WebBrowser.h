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
    IBOutlet UIBarButtonItem *btnClose;
	IBOutlet UIWebView *webView;
	NSString *uri;
	DocumentViewController_Kiosk *docVc;
	BOOL isLocal;
}

@property (nonatomic,retain)IBOutlet UIBarButtonItem *btnClose;
@property (nonatomic,retain)IBOutlet UIWebView *webView;
@property (nonatomic,copy) NSString *uri;
@property (nonatomic,retain) DocumentViewController_Kiosk *docVc;
@property (nonatomic,assign) BOOL isLocal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)_uri isLocal:(BOOL)_isLocal;
- (IBAction)actionDismiss;
@end
