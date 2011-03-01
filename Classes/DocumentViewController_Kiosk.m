//
//  DocumentViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 25/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewController_Kiosk.h"
#import "BookmarkViewController.h"
#import "OutlineViewController.h"
#import "MFDocumentManager.h"
#import "SearchViewController.h"
#import "TextDisplayViewController.h"
#import "SearchManager.h"
#import "MiniSearchView.h"
#import "mfprofile.h"



@implementation DocumentViewController_Kiosk

@synthesize leadButton, modeButton, directionButton, autozoomButton, automodeButton;
@synthesize pageLabel, pageSlider,numPaginaLabel;
@synthesize dismissButton, bookmarksButton, outlineButton;
@synthesize prevButton, nextButton;
@synthesize textButton, textDisplayViewController;
@synthesize searchViewController, searchButton, searchManager, pdfIsOpen,miniSearchView;
@synthesize thumbnailView;
@synthesize thumbSliderViewHorizontal,thumbsliderHorizontal;
@synthesize thumbImgArray;
@synthesize nomefile,thumbsViewVisible,visibleBookmark,visibleOutline,visibleSearch,visibleText;
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
		textDisplayViewController.documentManager = self.document;
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
	// They implement the same methods
	[controller setDelegate:self];
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
		[popupSearch setDelegate:self];
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
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			self.miniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-320)/2, -45, 320, 44)];
			[miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
		}else {
			self.miniSearchView = [[MiniSearchView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-320)/2, -45, 320, 44)];
			[miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
		}

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
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
	}
	[UIView commitAnimations];
	
	
	[[self view]setNeedsLayout];
}

-(void)dismissMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,-50 , 320, 44)];
		visibleSearch = NO;
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,-50 , 320, 44)];
		visibleSearch = NO;
	}
	
	[UIView commitAnimations];
	
	
	if(miniSearchView!=nil) {
		
	//	[miniSearchView removeFromSuperview];
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
	
	if (visibleSearch) {
		[self dismissAllPopoversFrom:sender];
	}else {
		[self presentFullSearchView:sender];
	}
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

-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopoversFrom:self];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		visibleBookmark=NO;
	}

}

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page{
	self.page = page;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopoversFrom:self];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		visibleBookmark=NO;
	}
}

-(void)dismissOutline:(id)sender {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopoversFrom:self];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		visibleOutline=NO;
	}
	
}

-(void)OutlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page{
	self.page = page;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopoversFrom:self];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		visibleOutline=NO;
	}
}

-(void)dismissSearch:(id)sender{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self dismissAllPopoversFrom:self];
	}else {
		[[self parentViewController]dismissModalViewControllerAnimated:YES];
		visibleSearch=NO;
	}
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
		[outlineVC setOutlineEntries:[[self document] outline]];
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
	pdfIsOpen = NO;
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
		[zoomLockBarButtonItem setImage:imgZoomUnlock];
	} else {
		[self setAutozoomOnPageChange:YES];
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
	
	
	if(mode == MFDocumentModeSingle) {
		[changeModeBarButtonItem setImage:imgChangeModeDouble];
	} else if (mode == MFDocumentModeDouble) {
		[changeModeBarButtonItem setImage:imgChangeMode];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(direction == MFDocumentDirectionL2R) {
		
		
		
	} else if (direction == MFDocumentDirectionR2L) {
		

	}
	
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(lead == MFDocumentLeadLeft) {
		
		
	} else if (lead == MFDocumentLeadRight) {
		

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
	visibleSearch=NO;
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
			
			[self showToolbar];
			[self showHorizontalThumbnails];
			
			[miniSearchView setHidden:NO];
			hudHidden = NO;
			
		} else {
			
			// Hide
			
			[self hideToolbar];
			[self hideHorizontalThumbnails];
			
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
		
	CGFloat ySlider = 0 ;
	CGFloat heightSlider = 0;
	CGFloat yToolbarThumb = 0;
	CGFloat heightToolbarThumb = 0;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//init the horizontal view thumb 
		aTSVH = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width,204)];
		heightToolbarThumb = 44; //height of the thumb that inclued the UISlider
		widthborder = 100;
		heightSlider = 20 ; //height of slider
		
		yToolbarThumb = aTSVH.frame.size.height-44; //y position Of Toolbar
		ySlider = yToolbarThumb + 10; // y position of slider
	}else {
		aTSVH = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 114)];
		heightToolbarThumb = 44;
		widthborder = 50;
		heightSlider = 10;
		yToolbarThumb = aTSVH.frame.size.height-44;
		ySlider = yToolbarThumb + 10;
	}
	
	
	[aTSVH setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	[aTSVH setAutoresizesSubviews:YES];
	[aTSVH setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
	
	UIToolbar *toolbarThumb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, yToolbarThumb, self.view.frame.size.width, heightToolbarThumb)];
	[toolbarThumb setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
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
		//set the number of page into the toolbar at right of UIslider .. only in Iphone
		numPaginaLabel = [[UILabel alloc]initWithFrame:CGRectMake((widthborder/2)+(aTSVH.frame.size.width-widthborder)-25, ySlider+6, 55, heightSlider)];
		[numPaginaLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		numPaginaLabel.text = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u",[self page]]];
		numPaginaLabel.textAlignment = UITextAlignmentLeft;
		numPaginaLabel.backgroundColor = [UIColor clearColor];
		//numPaginaLabel.shadowColor = [UIColor whiteColor];
		//numPaginaLabel.shadowOffset = CGSizeMake(0, 1);
		numPaginaLabel.textColor = [UIColor whiteColor];
		numPaginaLabel.font = [UIFont boldSystemFontOfSize:11.0];
		[aTSVH addSubview:numPaginaLabel];
		[numPaginaLabel release];
	}
	
	[self.view addSubview:aTSVH];
	self.thumbSliderViewHorizontal = aTSVH;
	[aTSVH release];
	
	/*Array of test img*/
	NSMutableArray * aThumbImgArray  = [[NSMutableArray alloc]init];
	
	
	// NSLog(@"inizio thumb");
	
	NSUInteger numpagePDF = [[self document]numberOfPages];
	for (int i=0; i<numpagePDF ; i++) {
		UIImage *img = [UIImage imageNamed:@"Icon.png"];
		[aThumbImgArray insertObject:img atIndex:i];
	}	
	
	self.thumbImgArray = aThumbImgArray;
	[aThumbImgArray release];
	
	[self performSelector:@selector(createThumbToolbar) withObject:nil afterDelay:0.1];
	
	//Add ToolBar
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//Set the img for the UIBarbuttonItem that change image on click
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
		//Iphone
		heightToolbar = 44;
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
	
	//set the top toolbar that include all UibarButtonItem
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width, heightToolbar)];
	toolbar.hidden = YES;
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
		
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		//Init UIBarButtonItem
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
		
		//set order of BarButtonItem
		NSArray *items = [NSArray arrayWithObjects:dismissBarButtonItem,itemSpazioBarButtnItem,zoomLockBarButtonItem,changeDirectionButtonItem,changeLeadButtonItem,changeModeBarButtonItem,itemSpazioBarButtnItem,numberOfPageTitle,itemSpazioBarButtnItem,itemSpazioBarButtnItem,searchBarButtonItem,textBarButtonItem,OutlineBarButtonItem,bookmarkBarButtonItem,nil];
		
		//release UIBarbuttonItem
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
		//iphone
		UIBarButtonItem *bookmarkBarButtonItem = [[UIBarButtonItem alloc]
												  initWithImage:[UIImage imageNamed:@"bookmark_add_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		
		//for each UIBarButtonItem force the width
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
	//add toolbar to view
	[self.view addSubview:toolbar];
}

-(void)initNumberOfPageToolbar{
	//Init the number of page .. it's called from MenuViewController
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		numberOfPageTitleToolbar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
		numberOfPageTitleToolbar.textAlignment = UITextAlignmentLeft;
		numberOfPageTitleToolbar.backgroundColor = [UIColor clearColor];
		numberOfPageTitleToolbar.shadowColor = [UIColor whiteColor];
		numberOfPageTitleToolbar.shadowOffset = CGSizeMake(0, 1);
		numberOfPageTitleToolbar.textColor = [UIColor whiteColor];
		NSString *ToolbarTextTitle = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u of %u",[self page],[[self document]numberOfPages]]];
		numberOfPageTitleToolbar.text = ToolbarTextTitle;
		numberOfPageTitleToolbar.font = [UIFont boldSystemFontOfSize:20.0];
	} /*else {
		numberOfPageTitleToolbar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 23)];
		numberOfPageTitleToolbar.font = [UIFont boldSystemFontOfSize:10.0];
	}*/
	
	
}

-(void)setNumberOfPageToolbar{
	//for each change of page set the correct numer of page
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//Ipad on toolbar
		NSString *ToolbarTextTitle = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u of %u",[self page],[[self document]numberOfPages]]];
		numberOfPageTitleToolbar.text = ToolbarTextTitle;
		[ToolbarTextTitle release];
	}else {
		//Iphone on Label at right of UISlider
		NSString *ToolbarTextTitle = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u",[self page]]];
		numPaginaLabel.text = ToolbarTextTitle;
		[ToolbarTextTitle release];
	}
}

-(void)showToolbar{
	//Show toolbar on tap
	toolbar.hidden = NO;
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, heightToolbar)];
	[UIView commitAnimations];		
}

-(void)hideToolbar{
	//hide toolbar on tap
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[toolbar setFrame:CGRectMake(0, -heightToolbar, toolbar.frame.size.width, heightToolbar)];
	[UIView commitAnimations];
}


-(void)createThumbToolbar{
	// Horizontal thumb slider set dimension and position
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		MFHorizontalSlider *anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray andSize:CGSizeMake(100, 124) andWidth:self.view.bounds.size.width andHeight:160 andType:1 andNomeFile:nomefile];
		anHorizontalThumbSlider.delegate = self;	
		self.thumbsliderHorizontal = anHorizontalThumbSlider;
		
		[self.thumbSliderViewHorizontal addSubview:thumbsliderHorizontal.view];
		[anHorizontalThumbSlider viewDidLoad];
		
		[anHorizontalThumbSlider release];
		[self performSelectorInBackground:@selector(generathumbinbackground:) withObject:nil];
		
	}else {
		MFHorizontalSlider *anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray andSize:CGSizeMake(50, 64) andWidth:self.view.frame.size.width andHeight:70 andType:1 andNomeFile:nomefile];
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
}

- (void)didSelectedPage:(int)number ofType:(int)type withObject:(id)object{
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
	
	NSError **error ;
	//BOOL testDirectoryCreated = [filemanager createDirectoryAtPath:<#(NSString *)path#> withIntermediateDirectories:<#(BOOL)createIntermediates#> attributes:<#(NSDictionary *)attributes#> error:<#(NSError **)error#>
	BOOL testDirectoryCreated = [filemanager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:error];
	
	//BOOL testDirectoryCreated = [filemanager createDirectoryAtPath:documentsDirectory attributes:nil];
	
	if (testDirectoryCreated) {
		//NSLog(@"directory creata");
	}else {
		//NSLog(@"directory gia esistente");
	}
	CGSize thumbSize = CGSizeMake(140, 182);
	
	for (int i=1; i<=[[self document]numberOfPages] ; i++) {
		
		NSString *filename = [NSString stringWithFormat:@"png%d.png",i];
		NSString *fullPathToFile = [documentsDirectory stringByAppendingString:@"/"];
		fullPathToFile = [ fullPathToFile stringByAppendingString:filename];
		
		if((![filemanager fileExistsAtPath: fullPathToFile]) && pdfIsOpen)
		//if file exist and a pdf is open create the thumbnail
		{
			CGImageRef imgthumb = [self.document createImageForThumbnailOfPageNumber:i ofSize:thumbSize andScale:1.0];
			UIImage *img = [[UIImage alloc] initWithCGImage:imgthumb];
			NSData *data = UIImagePNGRepresentation(img);
			if (pdfIsOpen) {
				[filemanager createFileAtPath:fullPathToFile contents:data attributes:nil];
				//NSLog(@"directory crea thumb : %@",fullPathToFile);
			}
			
			CGImageRelease(imgthumb);
			[img release];
		}
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
