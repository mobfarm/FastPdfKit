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
#import "mfprofile.h"

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
@synthesize pageLabel, pageSlider,numPaginaLabel;
@synthesize dismissButton, bookmarksButton, outlineButton;
@synthesize prevButton, nextButton;
@synthesize textButton, textDisplayViewController;
@synthesize searchViewController, searchButton, searchManager, pdfIsOpen,miniSearchView;
@synthesize thumbnailView;
@synthesize thumbSliderViewHorizontal,thumbsliderHorizontal;
@synthesize thumbImgArray;
@synthesize nomefile,thumbsViewVisible,visibleBookmark,visibleOutline,visibleSearch,visibleText,graphicsMode;
@synthesize thumbSliderView,aTSVH;
@synthesize popupBookmark,popupOutline,popupSearch,popupText;
@synthesize senderText;
@synthesize senderSearch;
@synthesize heightToolbar,widthborder,heightTSHV;

#pragma mark Thumbnail utility functions

-(void)hideThumbnailView {
	
	// Hide the thumbnail.
	
	self.thumbnailView.hidden = YES;
}

-(void)showThumbnailView {
	
	CGSize thumbSize = CGSizeMake(60, 80);
	
	// Get the thumbnail image from the document. Remember to release the CGImage.
	
	CGImageRef img = [self.document createImageForThumbnailOfPageNumber:thumbPage ofSize:thumbSize andScale:1.0];
	UIImage *thumbImage = [[UIImage alloc]initWithCGImage:img];
	CGImageRelease(img);
	
	// Set the image as the data of the thumbnail image view and hunide it.
	
	self.thumbnailView.image = thumbImage;
	self.thumbnailView.hidden = NO;
	
	[thumbImage release];
}

#pragma mark -
#pragma mark TextDisplayViewController lazy init and management

-(TextDisplayViewController *)textDisplayViewController {
	
	// Show the text display view controller to the user.
	
	if(nil == textDisplayViewController) {
		textDisplayViewController = [[TextDisplayViewController alloc]initWithNibName:@"TextDisplayView" bundle:[NSBundle mainBundle]];
	}
	
	return textDisplayViewController;
}

#pragma mark -
#pragma mark SearchViewController lazy initialization and management

// The entire search is a bit tricky, and it is not the best implementation out of there: we are likely to move most of the
// code inside the document view controller or the future MFDocumentView and have the developer only handle the striclty
// necessary.
// For now, it works like this: present a search view controller that will get a search term from the user and ask the
// document manager to perform the search on every page. Store each result inside a search manager and use it as a data
// source to present the result to the user. Anytime the user can "minimized" the full search view controller to a mini
// search view to navigate the document while looking for matches. Details are here, in the SearchViewController, SearchManager
// and MiniSearchView.

-(SearchViewController *)searchViewController {
	
	// Lazily allocation when required.
	
	if(nil==searchViewController) {
		
		// We use different xib on iPhone and iPad.
		
		BOOL isPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
		isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
			if(isPad) {
				searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_pad" bundle:[NSBundle mainBundle]];
			} else {
				searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_phone" bundle:[NSBundle mainBundle]];
			}
	}
	
	return searchViewController;
}

-(void)presentFullSearchView:(id)sender {
	
	// Get the full search view controller lazily, set it upt as the delegate for
	// the search manager and present it to the user modally.
	
	// Get the search manager lazily and set up the document.
	
	SearchManager *manager = self.searchManager;
	manager.document = self.document;
	
	// Get the search view controller lazily, set the delegate at self to handle
	// document action and the search manager as data source.
	
	SearchViewController *controller = self.searchViewController;
	controller.delegate = self;
	controller.searchManager = manager;
	
	// Set the search view controller as the data source delegate.
	
	manager.delegate = controller;
	
	// Enable overlay and set the search manager as the data source for
	// overlay items.
	self.overlayDataSource = self.searchManager;
	self.overlayEnabled = YES;
	

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			//se è aperto il popover slide verticale va chiuso
		popupSearch = [[UIPopoverController alloc] initWithContentViewController:(UIViewController *)controller];
		[popupSearch setPopoverContentSize:CGSizeMake(450, 650)];
		[popupSearch presentPopoverFromBarButtonItem:senderSearch permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		visibleSearch=YES;
	}else {
		[self presentModalViewController:(UIViewController *)controller animated:YES];
			visibleSearch=YES;
	}
	
	
	//[self presentModalViewController:(UIViewController *)controller animated:YES];
}

// Void
-(void)presentMiniSearchViewWithStartingItem:(MFTextItem *)item {
	
	// This could be rather tricky.
	
	// This method is called only when the (Full) SearchViewController. It first instantiate the
	// mini search view if necessary, then set the mini search view as the delegate for the current
	// search manager - associated until now to the full SVC - then present it to the user.
	
	if(miniSearchView == nil) {
		
		// If nil, allocate and initialize it.
		
		self.miniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake(10, 50, 270, 96)];
		
	} else {
		
		// If not nil, remove it from the superview.
		if([miniSearchView superview]!=nil)
			[miniSearchView removeFromSuperview];
	}
	
	// Set up the connections.
	miniSearchView.dataSource = self.searchManager;
	miniSearchView.documentDelegate = self;
	self.searchManager.delegate = miniSearchView;
	
	// Update the view with the right index.
	[miniSearchView reloadData];
	[miniSearchView setCurrentTextItem:item];
	
	// Add the subview and referesh the superview.
	[[self view]addSubview:miniSearchView];
	[[self view]setNeedsLayout];
}

-(void)dismissMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	if(miniSearchView!=nil) {
		
		[miniSearchView removeFromSuperview];
		MF_COCOA_RELEASE(miniSearchView);
	}
}

-(SearchManager *)searchManager {

	// Lazily allocate and instantiate the search manager.
	
	if(nil == searchManager) {
		
		searchManager = [[SearchManager alloc]init];
	}
	
	return searchManager;
}

-(void)revertToFullSearchView {

	// Dismiss the minimized view and present the full one.
	
	[self dismissMiniSearchView];
	[self presentFullSearchView:self];
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
		
		senderText = sender;
		
	} else {
		waitingForTextInput = NO;
	}
	
}

-(IBAction)actionSearch:(id)sender {
	
	// Get the instance of the Search Manager lazily and then present a full sized search view controller
	// to the user. The full search view controller will allow the user to type in a search term and
	// start the search. Look at the details in the utility method implementation.
	senderSearch = sender;
	
	[self dismissAllPopoversFrom:sender];
	
	[self presentFullSearchView:sender];
}

-(IBAction)actionNext:(id)sender {
	
	// This would be connected to an hypotetical next page button. You can enable
	// pageFlipOnEdgeTouch instead.
	
	[self moveToNextPage];
}

-(IBAction)actionPrev:(id)sender {
	
	// Same as actionNext.
	
	[self moveToPreviousPage];
}

-(void)dismissAllPopoversFrom:(id)sender{
	if (visibleBookmark) {
		[popupBookmark dismissPopoverAnimated:YES];
		visibleBookmark=NO;
	}
	
	if (visibleOutline) {
		[popupOutline dismissPopoverAnimated:YES];
		visibleOutline=NO;

	}
	
	if (visibleSearch) {
		[popupSearch dismissPopoverAnimated:YES];
		visibleSearch=NO;
		
	}
	
	if (visibleText) {
		[popupText dismissPopoverAnimated:YES];
		visibleText=NO;
		
	}

}

-(IBAction) actionBookmarks:(id)sender {
	
	//
//	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
//	you can also push the controller with the navigation controller or use an UIActionSheet.
		
		
	
		if (visibleBookmark) {
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[popupBookmark dismissPopoverAnimated:YES];
				visibleBookmark=NO;
			}else {
				[[self parentViewController]dismissModalViewControllerAnimated:YES];
				visibleBookmark=NO;
			}

		}else {
			
			BookmarkViewController *bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
			bookmarksVC.delegate=self;
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[self dismissAllPopoversFrom:sender];
				//se è aperto il popover slide verticale va chiuso
				popupBookmark = [[UIPopoverController alloc] initWithContentViewController:bookmarksVC];
				[popupBookmark setPopoverContentSize:CGSizeMake(372, 650)];
				[popupBookmark presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				[popupBookmark setDelegate:self];
				visibleBookmark=YES;
			}else {
				[self presentModalViewController:bookmarksVC animated:YES];
				visibleBookmark=YES;
			}
			[bookmarksVC release];
		}
}

-(IBAction) actionThumbnail:(id)sender{
	
	if (thumbsViewVisible) {
		
		[self hideHorizontalThumbnails];
	}else {
		[self showHorizontalThumbnails];
	}

}

-(void)showHorizontalThumbnails{
	if (thumbSliderViewHorizontal.frame.origin.y >= self.view.bounds.size.height) {
		//toolbar.hidden = NO;
		[UIView beginAnimations:@"show" context:NULL];
		[UIView setAnimationDuration:0.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[thumbSliderViewHorizontal setFrame:CGRectMake(0, thumbSliderViewHorizontal.frame.origin.y-thumbSliderViewHorizontal.frame.size.height, thumbSliderViewHorizontal.frame.size.width, thumbSliderViewHorizontal.frame.size.height)];
		[UIView commitAnimations];
		thumbsViewVisible = YES;
	}
}

-(void)hideHorizontalThumbnails{
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[thumbSliderViewHorizontal setFrame:CGRectMake(0, thumbSliderViewHorizontal.frame.origin.y+thumbSliderViewHorizontal.frame.size.height, thumbSliderViewHorizontal.frame.size.width, thumbSliderViewHorizontal.frame.size.height)];
	[UIView commitAnimations];
	thumbsViewVisible = NO;
	
}

-(IBAction)actionDone:(id)sender {
	
	[[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(IBAction) actionOutline:(id)sender {
	
	// We create an instance of the OutlineViewController and push it onto the stack like we did with the 
	// BookmarksViewController. However, you can show them in the same view with a segmented control, just
	// switch datasources and take it into account in the various tableView delegate methods. Another thing
	// to consider is that the view will be resetted once removed, and for an complex outline is not a nice thing.
	// So, it would be better to store the position in the outline somewhere to present it again the very same
	// view to the user or just retain the outlineVC and just let the application ditch only the view in case
	// of low memory warnings.
	
	
	
	// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
	// this array and the openentries array somewhere and set them again before present the view to the user again.

	
	
	if (visibleOutline) {
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[popupOutline dismissPopoverAnimated:YES];
			visibleOutline=NO;
		}else {
			[[self parentViewController]dismissModalViewControllerAnimated:YES];
			visibleOutline=NO;
		}

	}else {
		
		OutlineViewController *outlineVC = [[OutlineViewController alloc]initWithNibName:@"OutlineView" bundle:[NSBundle mainBundle]];
		[outlineVC setDelegate:self];
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[self dismissAllPopoversFrom:sender];
			//se è aperto il popover slide verticale va chiuso
			popupOutline = [[UIPopoverController alloc] initWithContentViewController:outlineVC];
			[popupOutline setPopoverContentSize:CGSizeMake(372, 650)];
			[popupOutline presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			[popupOutline setDelegate:self];
			visibleOutline=YES;
		}else {
			[self presentModalViewController:outlineVC animated:YES];
			visibleOutline=YES;
		}
		[outlineVC release];
	}
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
		[changeLeadButtonItem setImage:imgChangeLead];
	} else if (lead == MFDocumentLeadRight) {
		[self setLead:MFDocumentLeadLeft];
		[changeLeadButtonItem setImage:imgChangeLeadClick];
	}
}

-(IBAction)actionChangeDirection:(id)sender {
	
	// Look at actionChangeMode:
	
	MFDocumentDirection direction = [self direction];
	if(direction == MFDocumentDirectionL2R) {
		[self setDirection:MFDocumentDirectionR2L];
		[changeDirectionButtonItem setImage:imgl2r];
	} else if (direction == MFDocumentDirectionR2L) {
		[self setDirection:MFDocumentDirectionL2R];
		[changeDirectionButtonItem setImage:imgr2l];
	}
}

-(void)actionChangeAutozoom:(id)sender {
	
	// If autozoom is enable, when the user move to a new page, the zoom will be restored as it
	// was on the last page.
	
	BOOL autozoom = [self autozoomOnPageChange];
	if(autozoom) {
		[self setAutozoomOnPageChange:NO];
		[autozoomButton setTitle:TITLE_AUTOZOOM_NO forState:UIControlStateNormal];
		[zoomLockBarButtonItem setImage:imgZoomUnlock];
	} else {
		[self setAutozoomOnPageChange:YES];
		[autozoomButton setTitle:TITLE_AUTOZOOM_YES forState:UIControlStateNormal];
		[zoomLockBarButtonItem setImage:imgZoomLock];
	}
}

-(void)actionChangeAutomode:(id)sender {
	
	// When automode is turned on, it will automatically change the mode to single page when in portrait
	// and double page when in landscape.
	
	BOOL automode = [self automodeOnRotation];
	if(automode) {
		[self setAutomodeOnRotation:NO];
	} else {
		[self setAutomodeOnRotation:YES];
	}
}


#pragma mark -
#pragma mark MFDocumentViewControllerDelegate methods implementation


// The nice things about delegate callbacks is that we can use them to update the UI when the internal status of
// the controller changes, rather than query or keep track of it when the user press a button. Just listen for
// the right event and update the UI accordingly.

-(void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page {
	
	//
//	Page has changed, either by user input or an internal change upon an event: update the label and the 
//	slider to reflect that. If you save the current page as a bookmark to it is a good idea to store the value
//	in this callback.
	
	[pageLabel setText:[NSString stringWithFormat:@"%u/%u",page,[[self document]numberOfPages]]];
	
	[pageSlider setValue:[[NSNumber numberWithUnsignedInteger:page]floatValue] animated:YES];
	
	[thumbsliderHorizontal goToPage:page-1 animated:YES];
	
	[self setNumberOfPageToolbar];
	
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
		[changeModeBarButtonItem setImage:imgChangeModeDouble];
	} else if (mode == MFDocumentModeDouble) {
		[modeButton setTitle:TITLE_MODE_DOUBLE forState:UIControlStateNormal];
		[changeModeBarButtonItem setImage:imgChangeMode];
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
	
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		[self dismissAllPopoversFrom:self];
	}
	
	if(waitingForTextInput) {
		
		waitingForTextInput = NO;
		
		// Get the text display controller lazily, set up the delegate that will provide the document (this instance)
		// and show it.
	/*	TextDisplayViewController *controller = self.textDisplayViewController;
		controller.delegate = self;
		[controller updateWithTextOfPage:page];
		
		[self presentModalViewController:controller animated:YES];*/
		
		
		
		if (visibleText) {
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[popupText dismissPopoverAnimated:YES];
				visibleText=NO;
			}
		}else {
			TextDisplayViewController *controller = self.textDisplayViewController;
			controller.delegate = self;
			[controller updateWithTextOfPage:page];
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				controller.modalPresentationStyle = UIModalPresentationFormSheet;
			}
			visibleText=YES;
			[self presentModalViewController:controller animated:YES];
			//[controller release];
		}
	}
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
	visibleBookmark=NO;
	visibleOutline=NO;
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		[self dismissAllPopoversFrom:self];
	}
	
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
		
		if(hudHidden) {
			
			// Show
			
			if (graphicsMode) {
				[self showToolbar];
				[self showHorizontalThumbnails];
			}else {
				[nextButton setHidden:NO];
				[prevButton setHidden:NO];
				
				[autozoomButton setHidden:NO];
				[automodeButton setHidden:NO];
				
				[leadButton setHidden:NO];
				[modeButton setHidden:NO];
				[directionButton setHidden:NO];
			}

			[miniSearchView setHidden:NO];
			hudHidden = NO;
			
		} else {
			
			// Hide
			
			if (graphicsMode) {
				[self hideToolbar];
				[self hideHorizontalThumbnails];
			}else {
				[nextButton setHidden:YES];
				[prevButton setHidden:YES];
				
				[autozoomButton setHidden:YES];
				[automodeButton setHidden:YES];
				
				[leadButton setHidden:YES];
				[modeButton setHidden:YES];
				[directionButton setHidden:YES];
				
				
			}
			
			[miniSearchView setHidden:YES];
			hudHidden = YES;
		}
	}
}

#pragma mark -
#pragma mark UIViewController lifcecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// Create the view of the right size. Keep into consideration height of the status bar and the navigation bar. If
	// you want to add a toolbar, use the navigation controller's one like you would with an UIImageView to not cover
	// the document.
	
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
	
	// Background color: a nice texture if available, otherwise plain gray.
	
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
	
	pdfIsOpen = YES;
	
	UIButton *aButton = nil;
	
	CGSize viewSize = [[self view]bounds].size;
	
	CGFloat buttonHeight = 20;
	CGFloat buttonWidth = 60;
	CGFloat padding = 10;
	
	UIFont *font = nil;

	// Slighty different font sizes on iPad and iPhone.
	
	BOOL isPad = NO;
	
	hudHidden=YES;
	visibleBookmark = NO;
	visibleOutline = NO;
	
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif

 	if(isPad) {
		font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	} else {
		font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	}
	
	if (!graphicsMode) {
		//
		//	Now we can add our custom button to the view. Default values are MFDocumentModeSingle, MFDocumentLeadRight
		//	MFDocumentDirectionL2R with both Autozoom and Automode disabled. If you want to change some of them, is
		//	better to do it when the DocumentViewController is istanciated and set the values ere accordingly.
	
		//
		//	The buttons here are normal rounded rect buttons, are large and quite ugly. You can use image instead and
		//	icon-like buttons 32x32 (64x64 on iPhone4) are small, good looking and quite effective on both iphone and ipad.
	
		// Mode button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(padding, padding, buttonWidth, buttonHeight)];
		[aButton setTitle:TITLE_MODE_SINGLE forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		[aButton addTarget:self action:@selector(actionChangeMode:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setModeButton:aButton];
		[[self view] addSubview:aButton];
	
		// Lead button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(padding*2 + buttonWidth, padding, buttonWidth, buttonHeight)];
		[aButton setTitle:TITLE_LEAD_RIGHT forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		[aButton addTarget:self action:@selector(actionChangeLead:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setLeadButton:aButton];
		[[self view] addSubview:aButton];
	
		// Direction button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(padding*3 + buttonWidth * 2, padding, buttonWidth, buttonHeight)];
		[aButton setTitle:TITLE_DIR_L2R forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
		[aButton addTarget:self action:@selector(actionChangeDirection:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setDirectionButton:aButton];
		[[self view] addSubview:aButton];
	
	
		// Automode button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, padding, buttonWidth, buttonHeight)];
		[aButton setTitle:TITLE_AUTOMODE_NO forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
		[aButton addTarget:self action:@selector(actionChangeAutomode:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setAutomodeButton:aButton];
		[[self view]addSubview:aButton];
	
		// Autozoom button.
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
	
	
		// Dismiss button.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(viewSize.width - padding - buttonWidth, viewSize.height-padding*2-buttonHeight*2, buttonWidth, buttonHeight)];
		[aButton setTitle:@"Dismiss" forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
		[aButton addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setDismissButton:aButton];
		[[self view]addSubview:aButton];
	
		// Bookmarks.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(padding, viewSize.height-padding*2-buttonHeight*2, buttonWidth, buttonHeight)];
		[aButton setTitle:@"Bookmarks" forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
		[aButton addTarget:self action:@selector(actionBookmarks:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setBookmarksButton:aButton];
		[[self view]addSubview:aButton];
	
		// Outline.
		aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[aButton setFrame:CGRectMake(padding, viewSize.height-padding*3-buttonHeight*3, buttonWidth, buttonHeight)];
		[aButton setTitle:@"Outline" forState:UIControlStateNormal];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
		[aButton addTarget:self action:@selector(actionOutline:) forControlEvents:UIControlEventTouchUpInside];
		[[aButton titleLabel]setFont:font];
		[self setBookmarksButton:aButton];
		[[self view]addSubview:aButton];
		
	
		// Page sliders and label, bottom margin
		// |<-- 20 px -->| Label (80 x 40 px) |<-- 20 px -->| Slider ((view_width - labelwidth - padding) x 40 px) |<-- 20 px -->|
	
		// Page label.
		UILabel *aLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, viewSize.height-padding-buttonHeight, buttonWidth, buttonHeight)];
		[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
		[aLabel setBackgroundColor:[UIColor clearColor]];
		[aLabel setFont:font];
		[aLabel setText:[NSString stringWithFormat:@"%u/%u",[self page],[[self document]numberOfPages]]];
		[aLabel setTextAlignment:UITextAlignmentCenter];
		[self setPageLabel:aLabel];
		[[self view]addSubview:aLabel];
		[aLabel release];
		
		//Page slider.
		UISlider *aSlider = [[UISlider alloc]initWithFrame:CGRectMake(padding*8, viewSize.height-padding-buttonHeight,self.view.frame.size.width-buttonWidth-40, buttonHeight)];
		[aSlider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
		[aSlider setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
		[aSlider setMinimumValue:1.0];
		[aSlider setMaximumValue:[[self document] numberOfPages]];
		[aSlider setContinuous:YES];
		[aSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
		[aSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
		[self setPageSlider:aSlider];
		[[self view]addSubview:aSlider];
		[aSlider release];
		
		
	}else {

		CGFloat ySlider = 0 ;
		CGFloat heightSlider = 0;
		CGFloat yToolbarThumb = 0;
		CGFloat heightToolbarThumb = 0;
	
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		aTSVH = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 195)];
			widthborder = 100;
			ySlider = 170;
			heightSlider = 20 ;
			yToolbarThumb = ySlider-15;
			heightToolbarThumb = 40;
		}else {
			aTSVH = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 95)];
			widthborder = 50;
			ySlider = 68 ;
			heightSlider = 10;
			yToolbarThumb = ySlider-8;
			heightToolbarThumb = 25;
		}

		[aTSVH setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
		[aTSVH setAutoresizesSubviews:YES];
		[aTSVH setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	
		UIToolbar *toolbarThumb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, yToolbarThumb, self.view.frame.size.width, heightToolbarThumb)];
		[toolbarThumb setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
		toolbarThumb.barStyle = UIBarStyleBlackTranslucent;
	
		[aTSVH addSubview:toolbarThumb];
		[toolbarThumb release];
	
		int paddingSlider = 0;
		if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
			paddingSlider = 10;
		}
	
	
		//Page slider.
		UISlider *aSlider = [[UISlider alloc]initWithFrame:CGRectMake((widthborder/2)-paddingSlider, ySlider, aTSVH.frame.size.width-widthborder-(paddingSlider*2),heightSlider)];
		[aSlider setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
		[aSlider setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
		[aSlider setMinimumValue:1.0];
		[aSlider setMaximumValue:[[self document] numberOfPages]];
		[aSlider setContinuous:YES];
		[aSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
		[aSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
		[self setPageSlider:aSlider];
		[aTSVH addSubview:aSlider];
		[aSlider release];
		
	
		if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
			numPaginaLabel = [[UILabel alloc]initWithFrame:CGRectMake((widthborder/2)+(aTSVH.frame.size.width-widthborder)-28, ySlider+6, 55, heightSlider)];
			[numPaginaLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
			//NSString *numPaginaLabel = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u di %u",[self page],[[self document]numberOfPages]]];
		
			numPaginaLabel.text = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u di %u",[self page],[[self document]numberOfPages]]];
			numPaginaLabel.textAlignment = UITextAlignmentLeft;
			numPaginaLabel.backgroundColor = [UIColor clearColor];
			numPaginaLabel.shadowColor = [UIColor whiteColor];
			numPaginaLabel.shadowOffset = CGSizeMake(0, 1);
			numPaginaLabel.textColor = [UIColor whiteColor];
			numPaginaLabel.font = [UIFont boldSystemFontOfSize:10.0];
			[aTSVH addSubview:numPaginaLabel];
			[numPaginaLabel release];
		}
	
	

	
		[self.view addSubview:aTSVH];
		// [thumbSliderViewHorizontal setHidden:YES];
		self.thumbSliderViewHorizontal = aTSVH;
		[aTSVH release];
	}
	
	/*creo un array di immagini di test*/
	NSMutableArray * aThumbImgArray  = [[NSMutableArray alloc]init];
	
	
	// NSLog(@"inizio thumb");
	
	NSUInteger numpagePDF = [[self document]numberOfPages];
	for (int i=0; i<numpagePDF ; i++) {
		UIImage *img = [UIImage imageNamed:@"Icon.png"];
		//CGImageRef imgthumb = [self.document createImageForThumbnailOfPageNumber:i ofSize:thumbSize andScale:1.0];
		//UIImage *img = [UIImage imageWithCGImage:imgthumb];
		
		[aThumbImgArray insertObject:img atIndex:i];
		//CGImageRelease(imgthumb);
	}	
	
	self.thumbImgArray = aThumbImgArray;
	[aThumbImgArray release];
	
	[self performSelector:@selector(createThumbToolbar) withObject:nil afterDelay:0.1];
	
	//Add ToolBar
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		heightToolbar = 44;
		imgChangeMode =[UIImage imageNamed:@"changeModeSingle.png"];
		[imgChangeMode retain];
		imgChangeModeDouble =[UIImage imageNamed:@"changeModeDouble.png"];
		[imgChangeModeDouble retain];
		
		imgZoomLock =[UIImage imageNamed:@"zoomLock.png"];
		[imgZoomLock retain];
		imgZoomUnlock =[UIImage imageNamed:@"zoomUnlock.png"];
		[imgZoomUnlock retain];
		
		imgl2r =[UIImage imageNamed:@"direction_l2r.png"];
		[imgl2r retain];
		imgr2l =[UIImage imageNamed:@"direction_r2l.png"];
		[imgr2l retain];
		
		imgChangeLead =[UIImage imageNamed:@"pagelead.png"];
		[imgChangeLead retain];
		imgChangeLeadClick =[UIImage imageNamed:@"pagelead.png"];
		[imgChangeLeadClick retain];
		
		
	}else {
		heightToolbar = 44;
		heightTSHV = 130;
		imgChangeMode =[UIImage imageNamed:@"changeModeSingle_phone.png"];
		[imgChangeMode retain];
		imgChangeModeDouble =[UIImage imageNamed:@"changeModeDouble_phone.png"];
		[imgChangeModeDouble retain];
		
		imgZoomLock =[UIImage imageNamed:@"zoomLock_phone.png"];
		[imgZoomLock retain];
		imgZoomUnlock =[UIImage imageNamed:@"zoomUnlock_phone.png"];
		[imgZoomUnlock retain];
		
		imgl2r =[UIImage imageNamed:@"direction_l2r_phone.png"];
		[imgl2r retain];
		imgr2l =[UIImage imageNamed:@"direction_r2l_phone.png"];
		[imgr2l retain];
		
		imgChangeLead =[UIImage imageNamed:@"pagelead_phone.png"];
		[imgChangeLead retain];
		imgChangeLeadClick =[UIImage imageNamed:@"pagelead_phone.png"];
		[imgChangeLeadClick retain];
	}
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width, heightToolbar)];
	toolbar.hidden = YES;
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	
	// [toolbar sizeToFit];
	// toolbar.frame = CGRectMake(0, 0, 768, 44);
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		UIBarButtonItem *numberOfPageTitle = [[UIBarButtonItem alloc] initWithCustomView:numberOfPageTitleToolbar];
		
		UIBarButtonItem *bookmarkBarButtonItem = [[UIBarButtonItem alloc]
												  initWithImage:[UIImage imageNamed:@"bookmark_add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		
		
		UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc]
												 initWithImage:[UIImage imageNamed:@"X.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		
		
		changeModeBarButtonItem = [[UIBarButtonItem alloc]
								   initWithImage:[UIImage imageNamed:@"changeModeDouble.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		
		UIBarButtonItem *OutlineBarButtonItem = [[UIBarButtonItem alloc]
														initWithImage:[UIImage imageNamed:@"indice.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		
		[OutlineBarButtonItem setWidth:60];
		
		zoomLockBarButtonItem = [[UIBarButtonItem alloc]
												   initWithImage:[UIImage imageNamed:@"zoomUnlock.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		
		
		changeDirectionButtonItem = [[UIBarButtonItem alloc]
								 initWithImage:[UIImage imageNamed:@"direction_r2l.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		
		
		changeLeadButtonItem = [[UIBarButtonItem alloc]
								initWithImage:[UIImage imageNamed:@"pagelead.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		
		
		UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc]
												   initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		
		
		UIBarButtonItem *textBarButtonItem = [[UIBarButtonItem alloc]
												initWithImage:[UIImage imageNamed:@"text.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		
		
		UIBarButtonItem *itemSpazioBarButtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																								target:nil
																								action:nil];
		
		
		NSArray *items = [NSArray arrayWithObjects:dismissBarButtonItem,itemSpazioBarButtnItem,zoomLockBarButtonItem,changeDirectionButtonItem,changeLeadButtonItem,changeModeBarButtonItem,itemSpazioBarButtnItem,numberOfPageTitle,itemSpazioBarButtnItem,itemSpazioBarButtnItem,searchBarButtonItem,textBarButtonItem,OutlineBarButtonItem,bookmarkBarButtonItem,nil];
		
		[bookmarkBarButtonItem release];
		[changeModeBarButtonItem release];
		[changeDirectionButtonItem release],
		[OutlineBarButtonItem release];
		[itemSpazioBarButtnItem release];
		[searchBarButtonItem release];
		[zoomLockBarButtonItem release];
		[textBarButtonItem release];
		[numberOfPageTitle release];
		[toolbar setItems:items animated:NO];
	
	} else {
		UIBarButtonItem *bookmarkBarButtonItem = [[UIBarButtonItem alloc]
												  initWithImage:[UIImage imageNamed:@"bookmark_add_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		
		[bookmarkBarButtonItem setWidth:25];
		
		UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc]
												 initWithImage:[UIImage imageNamed:@"X_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		
		[dismissBarButtonItem setWidth:22];
		
		changeModeBarButtonItem = [[UIBarButtonItem alloc]
								   initWithImage:[UIImage imageNamed:@"changeModeDouble_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		
		[changeModeBarButtonItem setWidth:32];
		
		UIBarButtonItem *OutlineBarButtonItem = [[UIBarButtonItem alloc]
												 initWithImage:[UIImage imageNamed:@"indice_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		
		[OutlineBarButtonItem setWidth:22];
		
		zoomLockBarButtonItem = [[UIBarButtonItem alloc]
								 initWithImage:[UIImage imageNamed:@"zoomUnlock_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		
		[zoomLockBarButtonItem setWidth:22];
		
		changeDirectionButtonItem = [[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"direction_r2l_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		
		[changeDirectionButtonItem setWidth:22];
		
		changeLeadButtonItem = [[UIBarButtonItem alloc]
								initWithImage:[UIImage imageNamed:@"pagelead_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		
		
		[changeLeadButtonItem setWidth:25];
		
		UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc]
												initWithImage:[UIImage imageNamed:@"search_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		
		[searchBarButtonItem setWidth:22];
		
		
		UIBarButtonItem *textBarButtonItem = [[UIBarButtonItem alloc]
											  initWithImage:[UIImage imageNamed:@"text_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		
		[textBarButtonItem setWidth:22];
		
		
		UIBarButtonItem *itemSpazioBarButtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																								target:nil
																								action:nil];
		[itemSpazioBarButtnItem setWidth:25];
		
		NSArray *items = [NSArray arrayWithObjects: dismissBarButtonItem,itemSpazioBarButtnItem,zoomLockBarButtonItem,changeDirectionButtonItem,changeLeadButtonItem,changeModeBarButtonItem,itemSpazioBarButtnItem,itemSpazioBarButtnItem,searchBarButtonItem,textBarButtonItem,OutlineBarButtonItem,bookmarkBarButtonItem,nil];
		
		
		[bookmarkBarButtonItem release];
		[changeModeBarButtonItem release];
		[changeDirectionButtonItem release],
		[OutlineBarButtonItem release];
		[itemSpazioBarButtnItem release];
		[searchBarButtonItem release];
		[zoomLockBarButtonItem release];
		//[thumbnailBarButtonItem release];
		[textBarButtonItem release];
		[toolbar setItems:items animated:NO];
	}
	
	[self.view addSubview:toolbar];
 }

-(void)initNumberOfPageToolbar{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		numberOfPageTitleToolbar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
		numberOfPageTitleToolbar.textAlignment = UITextAlignmentLeft;
		numberOfPageTitleToolbar.backgroundColor = [UIColor clearColor];
		numberOfPageTitleToolbar.shadowColor = [UIColor whiteColor];
		numberOfPageTitleToolbar.shadowOffset = CGSizeMake(0, 1);
		numberOfPageTitleToolbar.textColor = [UIColor whiteColor];
		//NSString *ToolbarTextTitle = [[NSString alloc]initWithString:@"RASSEGNA STAMPA ETT - "];
		NSString *ToolbarTextTitle = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u di %u",[self page],[[self document]numberOfPages]]];
		//ToolbarTextTitle = [ToolbarTextTitle stringByAppendingString:@" di "];
		//ToolbarTextTitle = [ToolbarTextTitle stringByAppendingString:[@"%i",numberOfPages]];
		numberOfPageTitleToolbar.text = ToolbarTextTitle;
		numberOfPageTitleToolbar.font = [UIFont boldSystemFontOfSize:20.0];
	} else {
		numberOfPageTitleToolbar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 23)];
		numberOfPageTitleToolbar.font = [UIFont boldSystemFontOfSize:10.0];
	}

	
}

-(void)setNumberOfPageToolbar{
	
	NSString *ToolbarTextTitle = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u di %u",[self page],[[self document]numberOfPages]]];

	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		numberOfPageTitleToolbar.text = ToolbarTextTitle;
	}else {
		numPaginaLabel.text = ToolbarTextTitle;
	}

}

-(void)showToolbar{
		toolbar.hidden = NO;
		[UIView beginAnimations:@"show" context:NULL];
		[UIView setAnimationDuration:0.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, heightToolbar)];
		[UIView commitAnimations];		
}

-(void)hideToolbar{
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[toolbar setFrame:CGRectMake(0, -heightToolbar, toolbar.frame.size.width, heightToolbar)];
	[UIView commitAnimations];
}


-(void)createThumbToolbar{
	// Horizontal thumb slider.
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		MFHorizontalSlider *anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray andSize:CGSizeMake(90, 120) andWidth:self.view.bounds.size.width andType:1 andNomeFile:nomefile];
		anHorizontalThumbSlider.delegate = self;	
		self.thumbsliderHorizontal = anHorizontalThumbSlider;
	
		[self.thumbSliderViewHorizontal addSubview:thumbsliderHorizontal.view];
		[anHorizontalThumbSlider viewDidLoad];
		
		[anHorizontalThumbSlider release];
		[self performSelectorInBackground:@selector(generathumbinbackground:) withObject:nil];
		
	}else {
		MFHorizontalSlider *anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray andSize:CGSizeMake(45, 58) andWidth:self.view.frame.size.width andType:1 andNomeFile:nomefile];
		anHorizontalThumbSlider.delegate = self;
		
		self.thumbsliderHorizontal = anHorizontalThumbSlider;
		[self.thumbSliderViewHorizontal addSubview:thumbsliderHorizontal.view];
		[anHorizontalThumbSlider viewDidLoad];
		
		[anHorizontalThumbSlider release];
		[self performSelectorInBackground:@selector(generathumbinbackground:) withObject:nil];
		
	}
	
	
}


- (void)didTappedOnPage:(int)number ofType:(int)type withObject:(id)object{
	[self setPage:number];
	// NSLog(@"didTappedOnPage");
}

- (void)didSelectedPage:(int)number ofType:(int)type withObject:(id)object{
	// NSLog(@"didSelectedPage");
}

-(void)generathumbinbackground:(NSNumber *)numeropaginEPDF {
	
	NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];
    [numeropaginEPDF retain];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [ documentsDirectory stringByAppendingString:@"/"];
	documentsDirectory = [documentsDirectory stringByAppendingString:nomefile];
	
	// NSLog(@"directory crea thumb : %@",documentsDirectory);
	
	NSFileManager *filemanager = [[NSFileManager alloc]init];
	NSError *error;
	BOOL testDirectoryCreated = [filemanager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
	
	// BOOL testDirectoryCreated = [filemanager createDirectoryAtPath:documentsDirectory attributes:nil];
	
	//BOOL testDirectoryCreated = [filemanager createDirectoryAtPath:documentsDirectory attributes:nil];
	
	if (testDirectoryCreated) {
		NSLog(@"directory creata");
	}else {
		NSLog(@"directory gia esistente");
	}
	
	
	
	// NSLog(@"inizio");
	
	CGSize thumbSize = CGSizeMake(140, 182);
	
	for (int i=1; i<=[[self document]numberOfPages] ; i++) {
		
		NSString *filename = [NSString stringWithFormat:@"png%d.png",i]; //nome del file su disco, possiamo anche chiamarlo in altro modo
		NSString *fullPathToFile = [documentsDirectory stringByAppendingString:@"/"];
		fullPathToFile = [ fullPathToFile stringByAppendingString:filename];
		//fullPathToFile= [fullPathToFile stringByAppendingPathComponent:filename];
		
		// NSLog(@"path crea thumb : %@",fullPathToFile);
		
		if((![filemanager fileExistsAtPath: fullPathToFile]) && pdfIsOpen)
		{
			CGImageRef imgthumb = [self.document createImageForThumbnailOfPageNumber:i ofSize:thumbSize andScale:1.0];
			UIImage *img = [[UIImage alloc] initWithCGImage:imgthumb];
			NSData *data = UIImagePNGRepresentation(img);
			if (pdfIsOpen) {
				[filemanager createFileAtPath:fullPathToFile contents:data attributes:nil];
			}
			CGImageRelease(imgthumb);
			[img release];
			
		}
		//	[thumbImgArray insertObject:img atIndex:i];
	}
	// NSLog(@"fine");
	[filemanager release];
	[arPool release];
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
//	as long as you pass an instance of it to the superclass initializer.
	
	if(self = [super initWithDocumentManager:aDocumentManager]) {
		[self setDocumentDelegate:self];
	}
	return self;
}


- (void)didReceiveMemoryWarning {
	
	// Remember to call the super implementation, since MFDocumentViewController will use
	// memory warnings to clear up its rendering cache.
	
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
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
	
	[imgChangeModeDouble release];
	[imgChangeMode release];
	
    [super dealloc];
}

@end
