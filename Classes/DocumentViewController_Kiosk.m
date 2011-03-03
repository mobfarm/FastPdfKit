//
//  DocumentViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
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
@synthesize nomefile,thumbsViewVisible,visibleBookmarkView,visibleOutlineView,visibleSearchView,visibleTextView;
@synthesize thumbSliderView,aTSVH;
@synthesize bookmarkPopover,outlinePopover,searchPopover,textPopover;
@synthesize senderText;
@synthesize senderSearch;
@synthesize toolbarHeight,widthborder,heightTSHV;
@synthesize miniSearchVisible;

@synthesize searchBarButtonItem, changeModeBarButtonItem, zoomLockBarButtonItem, changeDirectionButtonItem, changeLeadBarButtonItem;

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

-(void)presentFullSearchView:(id)sender {
	
	// Get the full search view controller lazily, set it upt as the delegate for
	// the search manager and present it to the user modally.
	
	SearchManager * manager = nil;
	SearchViewController * controller = nil;
	
	
	// Get the search manager lazily and set up the document.
	
	manager = self.searchManager;
	manager.document = self.document;
	
	
	// Get the search view controller lazily, set the delegate at self to handle
	// document action and the search manager as data source.
	
	controller = self.searchViewController;
	[controller setDelegate:self];
	controller.searchManager = manager;
	
	
	// Set the search view controller as the data source delegate.
	
	manager.delegate = controller;
	
	
	// Enable overlay and set the search manager as the data source for
	// overlay items.
	self.overlayDataSource = self.searchManager;
	self.overlayEnabled = YES;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		searchPopover = [[UIPopoverController alloc] initWithContentViewController:(UIViewController *)controller];
		[searchPopover setPopoverContentSize:CGSizeMake(450, 650)];
		[searchPopover setDelegate:self];
		[searchPopover presentPopoverFromBarButtonItem:senderSearch permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
		visibleSearchView = YES;
		
	} else {
		
		[self presentModalViewController:(UIViewController *)controller animated:YES];
		visibleSearchView = YES;
	}	
}

	
-(IBAction) actionBookmarks:(id)sender {
	
	//
	//	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
	//	you can also push the controller with the navigation controller or use an UIActionSheet.
	
	if (visibleBookmarkView) {
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[bookmarkPopover dismissPopoverAnimated:YES];
			visibleBookmarkView=NO;
			
		} else {
			
			[[self parentViewController]dismissModalViewControllerAnimated:YES];
			visibleBookmarkView=NO;
		}
		
	}else {
		
		BookmarkViewController *bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:[NSBundle mainBundle]];
		bookmarksVC.delegate=self;
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[self dismissAllPopovers];
			
			bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:bookmarksVC];
			[bookmarkPopover setPopoverContentSize:CGSizeMake(372, 650)];
			[bookmarkPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			[bookmarkPopover setDelegate:self];
			
			visibleBookmarkView=YES;
		}else {
			
			[self presentModalViewController:bookmarksVC animated:YES];
			visibleBookmarkView=YES;
		}
		[bookmarksVC release];
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
	
	
	if (visibleOutlineView) {
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[outlinePopover dismissPopoverAnimated:YES];
			visibleOutlineView = NO;
		} else {
			
			[[self parentViewController]dismissModalViewControllerAnimated:YES];
			visibleOutlineView = NO;
		}
		
	} else {
		
		OutlineViewController *outlineVC = [[OutlineViewController alloc]initWithNibName:@"OutlineView" bundle:[NSBundle mainBundle]];
		[outlineVC setDelegate:self];
		
		// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
		// this array and the openentries array somewhere and set them again before present the view to the user again.
		
		[outlineVC setOutlineEntries:[[self document] outline]];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			[self dismissAllPopovers];	// Dismiss any eventual other popover.
			
			outlinePopover = [[UIPopoverController alloc] initWithContentViewController:outlineVC];
			[outlinePopover setPopoverContentSize:CGSizeMake(372, 650)];
			[outlinePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			[outlinePopover setDelegate:self];
			visibleOutlineView=YES;
			
		} else {
			
			[self presentModalViewController:outlineVC animated:YES];
			visibleOutlineView=YES;
			
		}
		[outlineVC release];
	}
}
	

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
		[self.view bringSubviewToFront:toolbar];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
		[self.view bringSubviewToFront:toolbar];
	}
	[UIView commitAnimations];
	
	miniSearchVisible = YES;
	
	[[self view]setNeedsLayout];
}

#pragma mark -
#pragma mark Actions

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
		
		
		
		if (visibleTextView) {
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[textPopover dismissPopoverAnimated:YES];
				visibleTextView=NO;
			}
		}else {
			TextDisplayViewController *controller = self.textDisplayViewController;
			controller.delegate = self;
			[controller updateWithTextOfPage:page];
			if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				controller.modalPresentationStyle = UIModalPresentationFormSheet;
			}
			visibleTextView=YES;
			[self presentModalViewController:controller animated:YES];
			//[controller release];
		}
	}
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		
		[self dismissAllPopovers];
	}
	
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
		
		if(hudHidden) {
			
			[self showToolbar];
			[self showHorizontalThumbnails];
			
			if (miniSearchVisible) {
				[self showMiniSearchView];
			}
			
			[miniSearchView setHidden:NO];
			hudHidden = NO;
			
		} else {
			
			// Hide
			
			[self hideToolbar];
			[self hideHorizontalThumbnails];
			
			
			[self dismissMiniSearchViewNoRelease];
			//[miniSearchView setHidden:YES];
			
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
	visibleBookmarkView = NO;
	visibleOutlineView = NO;
	miniSearchVisible = NO;
	
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
		toolbarHeight = 44;
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
		toolbarHeight = 44;
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
	
	
	NSArray * items = [[NSArray alloc]init];	// This will be the containter for the bar button items.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		UIBarButtonItem * aBarButtonItem = nil;
		
		// Dismiss.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		self.dismissBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Zoom lock.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomUnlock.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"direction_r2l.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];

		// Change lead.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pagelead.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change mode.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"changeModeDouble.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Page number.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:numberOfPageTitleToolbar];
		self.numberOfPageTitleBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Search.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		self.searchBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"text.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		self.textBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
	
		// Outline.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"indice.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		
		[aBarButtonItem setWidth:60];
		self.outlineBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Bookmarks.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark_add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		self.bookmarkBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// OLD
		// NSArray *items = [NSArray arrayWithObjects:dismissBarButtonItem,itemSpazioBarButtnItem,zoomLockBarButtonItem,changeDirectionButtonItem,changeLeadButtonItem,changeModeBarButtonItem,itemSpazioBarButtnItem,numberOfPageTitle,itemSpazioBarButtnItem,itemSpazioBarButtnItem,searchBarButtonItem,textBarButtonItem,OutlineBarButtonItem,bookmarkBarButtonItem,nil];
		
	} else {
		
		// Iphone.
		
		UIBarButtonItem * aBarButtonItem = nil;
		
		// Dismiss.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		[aBarButtonItem setWidth:22];
		self.dismissBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Zoom lock.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomUnlock_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		[aBarButtonItem setWidth:22];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"direction_r2l_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		[aBarButtonItem setWidth:22];
		self.changeDirectionButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pagelead_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change mode.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"changeModeDouble_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		[aBarButtonItem setWidth:32];
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Search.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		[aBarButtonItem setWidth:22];
		self.searchBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"text_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		[aBarButtonItem setWidth:22];
		self.textBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Outline.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"indice_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		[aBarButtonItem setWidth:22];
		self.outlineBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Bookmarks.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark_add_phone.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		[aBarButtonItem setWidth:25];
		self.bookmarkBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		
		// Old.
		//		NSArray *items = [NSArray arrayWithObjects: dismissBarButtonItem,itemSpazioBarButtnItem,zoomLockBarButtonItem,changeDirectionButtonItem,changeLeadButtonItem,changeModeBarButtonItem,itemSpazioBarButtnItem,itemSpazioBarButtnItem,searchBarButtonItem,textBarButtonItem,OutlineBarButtonItem,bookmarkBarButtonItem,nil];
		
	}
	
	
	UIToolbar * aToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width, toolbarHeight)];
	aToolbar.hidden = YES;
	aToolbar.barStyle = UIBarStyleBlackTranslucent;
	[aToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	[aToolbar setItems:items animated:NO];
	
	[self.view addSubview:aToolbar];
	
	self.toolbar = aToolbar;
	
	[aToolbar release];
	[items release];
}

// Useless?
//-(void)initNumberOfPageToolbar{
//	//Init the number of page .. it's called from MenuViewController
//	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//		
//		// TODO: what's this?
//		
//		numberOfPageTitleToolbar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
//		numberOfPageTitleToolbar.textAlignment = UITextAlignmentLeft;
//		numberOfPageTitleToolbar.backgroundColor = [UIColor clearColor];
//		numberOfPageTitleToolbar.shadowColor = [UIColor whiteColor];
//		numberOfPageTitleToolbar.shadowOffset = CGSizeMake(0, 1);
//		numberOfPageTitleToolbar.textColor = [UIColor whiteColor];
//		NSString *toolbarTextTitleString = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%u of %u",[self page],[[self document]numberOfPages]]];
//		numberOfPageTitleToolbar.text = toolbarTextTitleString;
//		numberOfPageTitleToolbar.font = [UIFont boldSystemFontOfSize:20.0];
//	} 
//}

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
	[toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];		
}

-(void)hideToolbar{
	//hide toolbar on tap
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[toolbar setFrame:CGRectMake(0, -toolbarHeight, toolbar.frame.size.width, toolbarHeight)];
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
	
	[searchBarButtonItem release], searchBarButtonItem = nil;
	[zoomLockBarButtonItem release], zoomLockBarButtonItem = nil;
	[changeModeBarButtonItem release], changeModeBarButtonItem = nil;
	[changeDirectionButtonItem release], changeDirectionButtonItem = nil;
	[changeLeadBarButtonItem release], changeLeadButtonItem = nil;
	
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
