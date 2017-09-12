//
//  WebBrowser.m
//  FastPdfKit
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)anUri local:(BOOL)isLocal
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
		self.local = isLocal;
		self.uri = anUri;
    }
    
    return self;
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

		
	} else {
		
        url = [[NSURL alloc] initWithString:uri];
        
		request = [[NSURLRequest alloc ]initWithURL:url];
		[webView loadRequest:request];
	}
}

-(IBAction)actionDismiss{
	
	docViewController.multimediaVisible = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
