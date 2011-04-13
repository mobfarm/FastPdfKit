//
//  WebBrowser.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 06/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
