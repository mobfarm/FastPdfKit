    //
//  TextDisplayViewController.m
//  FastPdfKit
//
//  Created by Nicolò Tosi on 10/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "TextDisplayViewController.h"
#import "MFDocumentManager.h"

@implementation TextDisplayViewController

#pragma mark -
#pragma mark Text extraction in background

-(void)updateTextToTextDisplayView:(NSString *)someText {
	
	// We got the text, now we can send it to the textView.
	self.textView.text = someText;
	self.text = someText;
	
	// Stop the activity indictor.
	[self.activityIndicatorView stopAnimating];
	
}

-(void)selectorWholeTextForPage:(NSNumber *)page {
	
	// Just call the -wholeTextForPage: method of MFDocumentManager. Pass NULL as profile to use the default profile.
	// If you want to use a different profile pass a reference to a MFProfile.
    
    // Use -(void)test_wholeTextForPage:(NSUInteger)page if you want to test the new text extraction engine instead.
    NSString * someText = [[self.documentManager wholeTextForPage:[page unsignedIntValue]]copy];
	
	// NSString *someText = [[documentManager wholeTextForPage:[page intValue] withProfile:NULL]copy];
	
	
	// Call back performed on the main thread.
	[self performSelectorOnMainThread:@selector(updateTextToTextDisplayView:) withObject:someText  waitUntilDone:YES];
}

-(void)clearText {
	
	// Clear both the view and the saved text.
	self.text = nil;
	self.textView.text = nil;
}

-(void)updateWithTextOfPage:(NSUInteger)page {
	
	// Clear the old text (if any), start the activity indicator and launch the selector in background.
	
	[self clearText];
	
	[self.activityIndicatorView startAnimating];
	
    [self performSelectorInBackground:@selector(selectorWholeTextForPage:) withObject:[NSNumber numberWithUnsignedInteger:page]];
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
	[self.textView setText:self.text];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

@end
