    //
//  TextDisplayViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "TextDisplayViewController.h"
#import "DocumentViewController.h"
#import "MFDocumentManager.h"

@implementation TextDisplayViewController

@synthesize textView, activityIndicatorView;
@synthesize text;
@synthesize delegate;
@synthesize documentManager;

#pragma mark -
#pragma mark Text extraction in background

-(void)updateTextToTextDisplayView:(NSString *)someText {
	
	// We got the text, now we can send it to the textView.
	self.textView.text = someText;
	self.text = someText;
	
	// Stop the activity indictor.
	[activityIndicatorView stopAnimating];
	
}

-(void)selectorWholeTextForPage:(NSNumber *)page {
	
	// This is going to be run in the background, so we need to create an autorelease pool for the thread.
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	// Just call the -wholeTextForPage: method of MFDocumentManager. Pass NULL as profile to use the default profile.
	// If you want to use a different profile pass a reference to a MFProfile.
    
    // Use -(void)test_wholeTextForPage:(NSUInteger)page if you want to test the new text extraction engine instead.
    NSString * someText = [[documentManager wholeTextForPage:[page unsignedIntValue]]copy];
	
	// NSString *someText = [[documentManager wholeTextForPage:[page intValue] withProfile:NULL]copy];
	
	
	// Call back performed on the main thread.
	[self performSelectorOnMainThread:@selector(updateTextToTextDisplayView:) withObject:someText  waitUntilDone:YES];
	
	// Cleanup.
	[someText release];
	[pool release];
	
}

-(void)clearText {
	
	// Clear both the view and the saved text.
	self.text = nil;
	textView.text = nil;	
}

-(void)updateWithTextOfPage:(NSUInteger)page {
	
	// Clear the old text (if any), start the activity indicator and launch the selector in background.
	
	[self clearText];
	
	[activityIndicatorView startAnimating];
	
	[self performSelectorInBackground:@selector(selectorWholeTextForPage:) withObject:[NSNumber numberWithInt:page]];
}

#pragma mark -
#pragma mark Actions

-(IBAction)actionBack:(id)sender {
	[[self delegate] dismissTextDisplayViewController:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	// Set up the view accordingly to the saved text (if any).
	[super viewDidLoad];
	[textView setText:text];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.activityIndicatorView = nil;
	
	self.text = self.textView.text;
	self.textView = nil;
}


- (void)dealloc {
	
	delegate = nil;
	[textView release],textView = nil;
	[activityIndicatorView release],activityIndicatorView = nil;
	[text release],text = nil;
	[documentManager release];
	
    [super dealloc];
}


@end
