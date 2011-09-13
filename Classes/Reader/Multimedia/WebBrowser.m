//
//  WebBrowser.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/03/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "WebBrowser.h"

@implementation WebBrowser

@synthesize closeButton;
@synthesize webView;
@synthesize uri;
@synthesize docViewController;
@synthesize local;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)anUri local:(BOOL)isLocal
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
		self.local = isLocal;
		self.uri = anUri;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    docViewController = nil;
    
    [closeButton release];
    [webView release];
    [uri release];
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
    
    NSURL * url = nil;
    NSURLRequest * request = nil;
    
    [super viewDidLoad];
    
    for (id subview in webView.subviews){
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    }
    
	if (local) {
		
        url = [[NSURL alloc] initFileURLWithPath:uri];
		
		request = [[NSURLRequest alloc ]initWithURL:url];
		[webView loadRequest:request];
		[url release];
		[request release];
		
	} else {
		
        url = [[NSURL alloc] initWithString:uri];
        
		request = [[NSURLRequest alloc ]initWithURL:url];
		[webView loadRequest:request];
		[url release];
		[request release];		
	}
}

-(IBAction)actionDismiss{
	
	docViewController.multimediaVisible = NO;
    
    if ([self respondsToSelector:@selector(presentingViewController)])
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    else
        [[self parentViewController] dismissModalViewControllerAnimated:YES];

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
