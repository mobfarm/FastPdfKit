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
}

@property (nonatomic,retain)IBOutlet UIBarButtonItem *btnClose;
@property (nonatomic,retain)IBOutlet UIWebView *webView;
@property (nonatomic,retain) NSString *uri;
@property (nonatomic,retain) DocumentViewController_Kiosk *docVc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)_uri;
-(IBAction)actionDismiss;
@end
