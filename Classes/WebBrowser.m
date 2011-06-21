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
@synthesize isLocal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)_uri isLocal:(BOOL)_isLocal
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		isLocal = _isLocal;
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
    
    //Enable this line for bounce locked .
    //[[[webView subviews] lastObject]setScrollEnabled:NO];
    
    //[[[webView subviews] lastObject]bounces:NO];
    
    for (id subview in webView.subviews){
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    }
    
	if (isLocal) {
		NSURL *url = [[NSURL alloc] initFileURLWithPath:uri];
		NSLog(@"url %@",uri);
		NSURLRequest *request = [[NSURLRequest alloc ]initWithURL:url];
		[webView loadRequest:request];
		[url release];
		[request release];
		
	}else {
		NSURL *url = [[NSURL alloc] initWithString:uri];
		NSLog(@"url %@",uri);
		NSURLRequest *request = [[NSURLRequest alloc ]initWithURL:url];
		[webView loadRequest:request];
		[url release];
		[request release];		
	}

	
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
