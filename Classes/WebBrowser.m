//
//  WebBrowser.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/03/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "WebBrowser.h"

@implementation WebBrowser

@synthesize btnClose;
@synthesize webView;
@synthesize uri;
@synthesize docVc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)_uri
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		uri = _uri;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	docVc.visibleMultimedia = NO;
	
	NSURL *url = [[NSURL alloc] initWithString:uri];
	NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
	[webView loadRequest:request];
	[url release];
	[request release];
}

-(IBAction)actionDismiss{
	//docVc.visibleWebView = NO;
	docVc.visibleMultimedia=NO;
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
