    //
//  TextDisplayViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "TextDisplayViewController.h"
#import "MFDocumentManager.h"

@implementation TextDisplayViewController

-(void)updateTextToTextDisplayView:(NSString *)someText {
	
	// We got the text, now we can send it to the textView.
	self.textView.text = someText;
	self.text = someText;
	
	// Stop the activity indictor.
	[self.activityIndicatorView stopAnimating];
	
}

-(void)selectorWholeTextForPage:(NSNumber *)page {
	
	@autoreleasepool {
	
	// Just call the -wholeTextForPage: method of MFDocumentManager. Pass NULL as profile to use the default profile.
	// If you want to use a different profile pass a reference to a MFProfile.
    
    // Use -(void)test_wholeTextForPage:(NSUInteger)page if you want to test the new text extraction engine instead.
        NSString * text = [[self.documentManager wholeTextForPage:[page unsignedIntValue]]copy];
	
	    // Call back performed on the main thread.
        id __weak this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [this updateTextToTextDisplayView:text];
        });
	}
}

-(void)clearText {
    
	// Clear both the view and the saved text.
	self.text = @"";
	self.textView.text = @"";
}

-(void)updateWithTextOfPage:(NSUInteger)page {
	
	// Clear the old text (if any), start the activity indicator and launch the selector in background.
	
	[self clearText];
	
	[self.activityIndicatorView startAnimating];
	
    id __weak this = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [this selectorWholeTextForPage:@(page)];
    });
}

#pragma mark - Actions

-(IBAction)actionBack:(id)sender {
	[[self delegate] dismissTextDisplayViewController:self];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
	// Set up the view accordingly to the saved text (if any).
	[super viewDidLoad];
    
    // Restore the text if required.
    if(self.text.length > 0)
    {
        [self.textView setText:self.text];
    }
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
