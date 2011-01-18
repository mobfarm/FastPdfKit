    //
//  DocumentViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/25/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "DocumentViewController.h"
#import "BookmarkViewController.h"
#import "OutlineViewController.h"
#import "MFDocumentManager.h"
#import "SearchViewController.h"
#import "TextDisplayViewController.h"
#import "SearchManager.h"
#import "MiniSearchView.h"

#define TITLE_MODE_SINGLE @"Single"
#define TITLE_MODE_DOUBLE @"Double"
#define TITLE_LEAD_LEFT @"L-Lead"
#define TITLE_LEAD_RIGHT @"R-Lead"
#define TITLE_DIR_L2R @"L2R"
#define TITLE_DIR_R2L @"R2L"
#define TITLE_AUTOMODE_YES @"Auto"
#define TITLE_AUTOMODE_NO @"User"
#define TITLE_AUTOZOOM_YES @"Zoom"
#define TITLE_AUTOZOOM_NO @"Zo/om"

@implementation DocumentViewController
@synthesize leadButton, modeButton, directionButton, autozoomButton, automodeButton;
@synthesize pageLabel, pageSlider;
@synthesize dismissButton, bookmarksButton, outlineButton;
@synthesize prevButton, nextButton;
@synthesize textButton, textDisplayViewController;
@synthesize searchViewController, searchButton, searchManager, miniSearchView;
@synthesize thumbnailView;

#pragma mark Thumbnail utility functions

-(void)hideThumbnailView {
	self.thumbnailView.hidden = YES;
}

-(void)showThumbnailView {
	
	CGSize thumbSize = CGSizeMake(60, 80);
	
	// Get the thumbnail image from the document. Remember to release the CGImage.
	CGImageRef img = [self.document createImageForThumbnailOfPageNumber:thumbPage ofSize:thumbSize andScale:1.0];
	UIImage *thumbImage = [[UIImage alloc]initWithCGImage:img];
	CGImageRelease(img);
	
	self.thumbnailView.image = thumbImage;
	self.thumbnailView.hidden = NO;
	
	[thumbImage release];
}

#pragma mark -
#pragma mark TextDisplayViewController lazy init and management

-(TextDisplayViewController *)textDisplayViewController {
	
	if(nil == textDisplayViewController) {
		textDisplayViewController = [[TextDisplayViewController alloc]initWithNibName:@"TextDisplayView" bundle:[NSBundle mainBundle]];
	}
	
	return textDisplayViewController;
}

#pragma mark -
#pragma mark SearchViewController lazy initialization and management

-(SearchViewController *)searchViewController {
	
	// Lazily allocation when required.
	
	if(nil==searchViewController) {
		
		// We use different xib on iPhone and iPad.
		
		BOOL isPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
		isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
			if(isPad) {
				searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView_pad" bundle:[NSBundle mainBundle]];
			} else {
				searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_phone" bundle:[NSBundle mainBundle]];
			}
	}
	
	return searchViewController;
}

#pragma mark -
#pragma mark SearchManager lazy initialization

-(void)presentFullSearchView {
	
	SearchManager *manager = self.searchManager;
	manager.document = self.document;
	
	SearchViewController *controller = self.searchViewController;
	controller.delegate = self;
	self.overlayDataSource = self.searchManager;
	self.overlayEnabled = YES;
	
	manager.delegate = controller;
	controller.searchManager = manager;
	
	[self presentModalViewController:(UIViewController *)controller animated:YES];
}

// Void
-(void)presentMiniSearchViewWithStartingItem:(MFTextItem *)item {
	
	if(miniSearchView == nil) {
		
		// If nil, allocate and initialize it.
		
		self.miniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake(20, 20, 280, 76)];
		
	} else {
		
		// If not nil, remove it from the superview.
		if([miniSearchView superview]!=nil)
			[miniSearchView removeFromSuperview];
	}
	
	// Set up the connections.
	miniSearchView.dataSource = self.searchManager;
	self.searchManager.delegate = miniSearchView;
	
	// TODO: fix this shit.
	// Update the view with the right index.
	[miniSearchView reloadData];
	[miniSearchView setCurrentTextItem:item];
	
	// Add the subview and referesh the superview.
	[[self view]addSubview:miniSearchView];
	[[self view]setNeedsLayout];
}

-(void)dismissMiniSearchView {
	
	if(miniSearchView!=nil) {
		
		[miniSearchView removeFromSuperview];
		MF_COCOA_RELEASE(miniSearchView);
	}
}

-(SearchManager *)searchManager {

	if(nil == searchManager) {
		
		searchManager = [[SearchManager alloc]init];
	}
	
	return searchManager;
}

-(void)revertToFullSearchView {

	// Dismiss the minimized view and present the full one.
	
	[self dismissMiniSearchView];
	[self presentFullSearchView];
}

-(void)switchToMiniSearchView:(MFTextItem *)item {

	// Dismiss the full view and present the minimized one.
	
	[self dismissModalViewControllerAnimated:YES];
	[self presentMiniSearchViewWithStartingItem:item];
}

#pragma mark -
#pragma mark Actions

-(IBAction)actionText:(id)sender {
	
	if(!waitingForTextInput) {
		
		// We set the flag to YES and enable the documenter interaction. The flag is used to discard unwanted
		// user interaction on the document elsewhere, while the document interaction will allow the document
		// manager to notify its delegate (in this case itself) of user generated event on the document, like
		// the tap on a certain page.
		
		waitingForTextInput = YES;
		self.documentInteractionEnabled = YES;
		
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Text" message:@"Select the page you want the text of." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} else {
		waitingForTextInput = NO;
	}
	
}

-(IBAction)actionSearch:(id)sender {
	
	// Get the SearchViewController lazily, set it as the overlay data source for the docment view controller
	// and enable the overlay to display the search result. The document view controller will query the data
	// source for overlay objects to draw when displaying the document's pages.
	
	SearchManager *manager = self.searchManager;
	manager.document = self.document;
	
	SearchViewController *controller = self.searchViewController;
	controller.delegate = self;
	self.overlayDataSource = self.searchManager;
	self.overlayEnabled = YES;
	
	manager.delegate = controller;
	controller.searchManager = manager;
	
	[self presentModalViewController:(UIViewController *)controller animated:YES];
}

-(IBAction)actionNext:(id)sender {
	[self moveToNextPage];
}

-(IBAction)actionPrev:(id)sender {
	[self moveToPreviousPage];
}


-(IBAction) actionBookmarks:(id)sender {
	
	//
//	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
//	you can also push the controller with the navigation controller or use an UIActionSheet.
	
	BookmarkViewController *bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
	[bookmarksVC setDelegate:self];
	[self presentModalViewController:(UIViewController *)bookmarksVC animated:YES];
	[bookmarksVC release];
}

-(IBAction) actionOutline:(id)sender {
	
	// We create an instance of the OutlineViewController and push it onto the stack like we did with the 
	// BookmarksViewController. However, you can show them in the same view with a segmented control, just
	// switch datasources and take it into account in the various tableView delegate methods. Another thing
	// to consider is that the view will be resetted once removed, and for an complex outline is not a nice thing.
	// So, it would be better to store the position in the outline somewhere to present it again the very same
	// view to the user or just retain the outlineVC and just let the application ditch only the view in case
	// of low memory warnings.
	
	OutlineViewController *outlineVC = [[OutlineViewController alloc]initWithNibName:@"OutlineView" bundle:[NSBundle mainBundle]];
	[outlineVC setDelegate:self];
	
	// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
	// this array and the openentries array somewhere and set them again before present the view to the user again.
	[outlineVC setOutlineEntries:[[self document] outline]];
	
	[self presentModalViewController:outlineVC animated:YES];
	[outlineVC release];
}

-(IBAction) actionDismiss:(id)sender {

	// For simplicity, the DocumentViewController will remove itself. If you need to pass some
	// values you can just set up a delegate and implement in a delegate method both the
	// removal of the DocumentViweController and the processing of the values.
	
	// Call this function to stop the worker threads and release the associated resources.
	[self cleanUp];
	
	//
	//	Just remove this controller from the navigation stack.
	[[self navigationController]popViewControllerAnimated:YES];	
	
	// Or, if presented as modalviewcontroller, tell the parent to dismiss it.
	// [[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(IBAction) actionPageSliderStopped:(id)sender {
	
	// We move to the page only if the user release the slider (on UITouchUpInside).
	
	// Cancel the previous request for thumbnail, we don't need it.
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showThumbnailView) object:nil];
	[self hideThumbnailView];
	
	// Get the requested page number from the slider.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Go to the page.
	[self setPage:pageNumber];

}

-(IBAction) actionPageSliderSlided:(id)sender {

	// When the user move the slider, we update the label and queue a selector to generate a thumbnail for the page if
	// the user hold the slider for at least 1 second without moving it.
	
	// Cancel the previous request if any.
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showThumbnailView) object:nil];
	[self hideThumbnailView];
	
	// Start a new one.
	[self performSelector:@selector(showThumbnailView) withObject:nil afterDelay:1.0];
	
	// Get the slider value.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	//We use the instance's thumbPage variable to avoid passing a number to the selector each time.
	thumbPage = pageNumber;
	
	// Update the label.
	[pageLabel setText:[NSString stringWithFormat:@"%u/%u",pageNumber,[[self document]numberOfPages]]];
	
}


-(IBAction)actionChangeMode:(id)sender {
	
	//
//	Find the mode used by the documentviewcontroller and change it depending on you needs. In this example we can
//	arbitrarly change from single to double, so we can immediatly call the setMode: selector. Always use selectors
//	and do not access or change value directly to avoid inconsitencies in the internal state of the viewer.
//	You can also use your own state variables or combination of states, check on them and then perform
//	changes to the internal state of the viewer according to your own rules.
	
	MFDocumentMode mode = [self mode];
	
	if(mode == MFDocumentModeSingle) {
		[self setMode:MFDocumentModeDouble];
	} else if (mode == MFDocumentModeDouble) {
		[self setMode:MFDocumentModeSingle];
	}
}

-(IBAction)actionChangeLead:(id)sender {
	
	// Look at actionChangeMode:
	
	MFDocumentLead lead = [self lead];
	
	if(lead == MFDocumentLeadLeft) {
		[self setLead:MFDocumentLeadRight];
	} else if (lead == MFDocumentLeadRight) {
		[self setLead:MFDocumentLeadLeft];
	}
}

-(IBAction)actionChangeDirection:(id)sender {
	
	// Look at actionChangeMode:
	
	MFDocumentDirection direction = [self direction];
	if(direction == MFDocumentDirectionL2R) {
		[self setDirection:MFDocumentDirectionR2L];
	} else if (direction == MFDocumentDirectionR2L) {
		[self setDirection:MFDocumentDirectionL2R];
	}
}

-(void)actionChangeAutozoom:(id)sender {
	
	BOOL autozoom = [self autozoomOnPageChange];
	if(autozoom) {
		[self setAutozoomOnPageChange:NO];
		[autozoomButton setTitle:TITLE_AUTOZOOM_NO forState:UIControlStateNormal];
	} else {
		[self setAutozoomOnPageChange:YES];
		[autozoomButton setTitle:TITLE_AUTOZOOM_YES forState:UIControlStateNormal];
	}
}

-(void)actionChangeAutomode:(id)sender {
	
	BOOL automode = [self automodeOnRotation];
	if(automode) {
		[self setAutomodeOnRotation:NO];
	} else {
		[self setAutomodeOnRotation:YES];
	}
}


#pragma mark -
#pragma mark MFDocumentViewControllerDelegate methods implementation

-(void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page {
	
	//
//	Page has changed, either by user input or an internal change upon an event: update the label and the 
//	slider to reflect that. If you save the current page as a bookmark to it is a good idea to store the value
//	in this callback.
	[pageLabel setText:[NSString stringWithFormat:@"%u/%u",page,[[self document]numberOfPages]]];
	
	[pageSlider setValue:[[NSNumber numberWithUnsignedInteger:page]floatValue] animated:YES];
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeModeTo:(MFDocumentMode)mode automatic:(BOOL)automatically {
	
	//
//	The mode has changed, for example from single to double. Update the UI with the right title, image, etc for
//	the right componenets: in this case a button.
//	You can also choose to change/update the UI when the setter is called instead, just be sure that you keep track
//	of the changes in your own variables and check for inconsitencies in the internal state somewhere in your code.
	
	if(automatically) {
		[automodeButton setTitle:TITLE_AUTOMODE_YES forState:UIControlStateNormal];
	} else {
		[automodeButton setTitle:TITLE_AUTOMODE_NO  forState:UIControlStateNormal];
	}
	
	if(mode == MFDocumentModeSingle) {
		[modeButton setTitle:TITLE_MODE_SINGLE forState:UIControlStateNormal];
	} else if (mode == MFDocumentModeDouble) {
		[modeButton setTitle:TITLE_MODE_DOUBLE forState:UIControlStateNormal];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction {
	
	//
//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(direction == MFDocumentDirectionL2R) {
		
		[directionButton setTitle:TITLE_DIR_L2R forState:UIControlStateNormal];
		
	} else if (direction == MFDocumentDirectionR2L) {
		
		[directionButton setTitle:TITLE_DIR_R2L forState:UIControlStateNormal];
	}
	
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead {
	
	//
//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(lead == MFDocumentLeadLeft) {
		
		[leadButton setTitle:TITLE_LEAD_LEFT forState:UIControlStateNormal];
		
	} else if (lead == MFDocumentLeadRight) {
		
		[leadButton setTitle:TITLE_LEAD_RIGHT forState:UIControlStateNormal];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnPage:(NSUInteger)page atPoint:(CGPoint)point {
	
	if(waitingForTextInput) {
		
		waitingForTextInput = NO;
		
		// Get the text display controller lazily, set up the delegate that will provide the document (this instance)
		// and show it.
		TextDisplayViewController *controller = self.textDisplayViewController;
		controller.delegate = self;
		[controller updateWithTextOfPage:page];
		
		[self presentModalViewController:controller animated:YES];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
	// If the flag waitingForTextInput is enabled, we use the
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
		
		if(hudHidden) {
			
			// Show
			
			[nextButton setHidden:NO];
			[prevButton setHidden:NO];
			
			[autozoomButton setHidden:NO];
			[automodeButton setHidden:NO];
			
			[leadButton setHidden:NO];
			[modeButton setHidden:NO];
			[directionButton setHidden:NO];
			
			hudHidden = NO;
			
		} else {
			
			// Hide
			[nextButton setHidden:YES];
			[prevButton setHidden:YES];
			
			[autozoomButton setHidden:YES];
			[automodeButton setHidden:YES];
			
			[leadButton setHidden:YES];
			[modeButton setHidden:YES];
			[directionButton setHidden:YES];
			
			hudHidden = YES;
		}		
	}
}

#pragma mark -
#pragma mark UIViewController lifcecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// Create the view of the right size. Keep into consideration height of the status bar and the navigation bar.
	UIView * aView = nil;
	
	BOOL isPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
 	if(isPad) {
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20 + 44, 768, 1024-20-44)];
	} else {
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20 + 44, 320, 480-20-44)];
	}
	
	[aView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[aView setAutoresizesSubviews:YES];
	
	if ([UIColor respondsToSelector:@selector(scrollViewTexturedBackgroundColor)]) {
		[aView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	} else {
		[aView setBackgroundColor:[UIColor grayColor]];
	}
	[self setView:aView];
	
	[aView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	// 
//	Let the superclass do its stuff (setting up the views), then you can begin to add your own custom subviews
//	like buttons.
	
	[super viewDidLoad];
	
	
	UIButton *aButton = nil;
	
	CGSize viewSize = [[self view]bounds].size;
	
	CGFloat buttonHeight = 20;
	CGFloat buttonWidth = 60;
	CGFloat padding = 10;
	
	UIFont *font = nil;

	BOOL isPad = NO;

#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif

 	if(isPad) {
		font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	} else {
		font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	}
	
	//
//	Now we can add our custom button to the view. Default values are MFDocumentModeSingle, MFDocumentLeadRight
//	MFDocumentDirectionL2R with both Autozoom and Automode disabled. If you want to change some of them, is
//	better to do it when the DocumentViewController is istanciated and set the values ere accordingly.
	
	//
//	The buttons here are normal rounded rect buttons, are large and quite ugly. You can use image instead and
//	icon-like buttons 32x32 (64x64 on iPhone4) are small, good looking and quite effective on both iphone and ipad.
	
	// Mode button
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(padding, padding, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_MODE_SINGLE forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton addTarget:self action:@selector(actionChangeMode:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setModeButton:aButton];
	[[self view] addSubview:aButton];
	
	// Lead button
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(padding*2 + buttonWidth, padding, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_LEAD_RIGHT forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton addTarget:self action:@selector(actionChangeLead:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setLeadButton:aButton];
	[[self view] addSubview:aButton];
	
	// Direction button
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(padding*3 + buttonWidth * 2, padding, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_DIR_L2R forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton addTarget:self action:@selector(actionChangeDirection:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setDirectionButton:aButton];
	[[self view] addSubview:aButton];
	
	// Automode button	
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, padding, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_AUTOMODE_NO forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
	[aButton addTarget:self action:@selector(actionChangeAutomode:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setAutomodeButton:aButton];
	[[self view]addSubview:aButton];
	
	// Autozoom button
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, padding*2 + buttonHeight, buttonWidth, buttonHeight)];
	[aButton setTitle:TITLE_AUTOZOOM_NO forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
	[aButton addTarget:self action:@selector(actionChangeAutozoom:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setAutozoomButton:aButton];
	[[self view]addSubview:aButton];
	
	
	// Text button.
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, viewSize.height-padding*4-buttonHeight*4, buttonWidth, buttonHeight)];
	[aButton setTitle:@"Text" forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
	[aButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	self.textButton = aButton;
	[[self view]addSubview:aButton];
	
	// Search button.
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, viewSize.height-padding*5-buttonHeight*5, buttonWidth, buttonHeight)];
	[aButton setTitle:@"Search" forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
	[aButton addTarget:self action:@selector(actionSearch:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	self.searchButton = aButton;
	[[self view]addSubview:aButton];
	
	
	// Dismiss button
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, viewSize.height-padding*2-buttonHeight*2, buttonWidth, buttonHeight)];
	[aButton setTitle:@"Dismiss" forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
	[aButton addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setDismissButton:aButton];
	[[self view]addSubview:aButton];
	
	// Bookmarks
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(padding, viewSize.height-padding*2-buttonHeight*2, buttonWidth, buttonHeight)];
	[aButton setTitle:@"Bookmarks" forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton addTarget:self action:@selector(actionBookmarks:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setBookmarksButton:aButton];
	[[self view]addSubview:aButton];
	
	// Outline
	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[aButton setFrame:CGRectMake(padding, viewSize.height-padding*3-buttonHeight*3, buttonWidth, buttonHeight)];
	[aButton setTitle:@"Outline" forState:UIControlStateNormal];
	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
	[aButton addTarget:self action:@selector(actionOutline:) forControlEvents:UIControlEventTouchUpInside];
	[[aButton titleLabel]setFont:font];
	[self setBookmarksButton:aButton];
	[[self view]addSubview:aButton];
	

//	// The controller now detect taps on the edge to perform page flipping. If you prefer button, uncomment these lines and set the property
//	// pageFlipOnEdgeTouch to NO.
//	// Previous page.
//	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	[aButton setFrame:CGRectMake(padding, viewSize.height*0.5 - buttonHeight*0.5, buttonWidth, buttonHeight)];
//	[aButton setTitle:@"Prev" forState:UIControlStateNormal];
//	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
//	[aButton addTarget:self action:@selector(actionPrev:) forControlEvents:UIControlEventTouchUpInside];
//	[[aButton titleLabel]setFont:font];
//	[self setPrevButton:aButton];
//	[[self view]addSubview:aButton];
//	
//	// Next page.
//	aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, viewSize.height*0.5-buttonHeight*0.5, buttonWidth, buttonHeight)];
//	[aButton setTitle:@"Next" forState:UIControlStateNormal];
//	[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
//	[aButton addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchUpInside];
//	[[aButton titleLabel]setFont:font];
//	[self setNextButton:aButton];
//	[[self view]addSubview:aButton];
	
	
	// Page sliders and label, bottom margin
	// |<-- 20 px -->| Label (80 x 40 px) |<-- 20 px -->| Slider ((view_width - labelwidth - padding) x 40 px) |<-- 20 px -->|
	
	// Label
	UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, viewSize.height-padding-buttonHeight, buttonWidth, buttonHeight)];
	[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
	[aLabel setBackgroundColor:[UIColor clearColor]];
	[aLabel setFont:font];
	[aLabel setText:[NSString stringWithFormat:@"%u/%u",[self page],[[self document]numberOfPages]]];
	[aLabel setTextAlignment:UITextAlignmentCenter];
	[self setPageLabel:aLabel];
	[[self view]addSubview:aLabel];
	[aLabel release];
	
	// Slider
	UISlider *aSlider = [[UISlider alloc]initWithFrame:CGRectMake(padding*2+buttonWidth, viewSize.height-padding-buttonHeight, viewSize.width-padding*3-buttonWidth, buttonHeight)];
	[aSlider setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
	[aSlider setMinimumValue:1.0];
	[aSlider setMaximumValue:[[self document] numberOfPages]];
	[aSlider setContinuous:YES];
	[aSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
	[aSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
	[self setPageSlider:aSlider];
	[[self view]addSubview:aSlider];
	[aSlider release];

	UIImageView *anImageView = [[UIImageView alloc]initWithFrame:CGRectMake((viewSize.width-60)*0.5, viewSize.height-80-40, 60, 80)];
	[anImageView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
	[anImageView setContentMode:UIViewContentModeScaleAspectFit];
	[anImageView setBackgroundColor:[UIColor darkGrayColor]];
	[anImageView setHidden:YES];
	self.thumbnailView = anImageView;
	[[self view]addSubview:anImageView];
	[anImageView release];
	
	//MiniSearchView *aMiniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake(20, 80, 280, 76)];
//	[aMiniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin];
//	self.miniSearchView = aMiniSearchView;
//	[[self view]addSubview:aMiniSearchView];
//	[aMiniSearchView release];
	
 }

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager {
	
	//
//	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
//	we used to initialize this class. However, since you probably want to track which document are
//	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
//	as long as you pass an instance of it to the superclass initializer
	if(self = [super initWithDocumentManager:aDocumentManager]) {
		[self setDocumentDelegate:self];
	}
	return self;
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
}


- (void)dealloc {
	
	[searchManager release], searchManager = nil;
	
	[searchButton release], searchButton = nil;
	[searchViewController release],searchViewController = nil;
	
	[textButton release];
	[textDisplayViewController release],textDisplayViewController = nil;
	
	[thumbnailView release];
	
	[modeButton release];
	[leadButton release];
	[directionButton release];
	
	[pageLabel release];
	[pageSlider release];
	
	[autozoomButton release];
	[automodeButton release];
	
	[outlineButton release];
	[bookmarksButton release];
	[dismissButton release];
	
	[nextButton release];
	[prevButton release];
	
    [super dealloc];
}

@end
