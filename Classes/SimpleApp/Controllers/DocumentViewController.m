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
#import "MenuViewController.h"

#define TITLE_MODE_SINGLE @"Single"
#define TITLE_MODE_DOUBLE @"Double"
#define TTILE_MODE_OVERFLOW @"Overflow"

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
@synthesize searchViewController, searchButton, searchManager,miniSearchView;
@synthesize thumbnailView;
@synthesize reusablePopover;
@synthesize delegate;


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

-(UIPopoverController *)prepareReusablePopoverControllerWithController:(UIViewController *)controller {
    
    UIPopoverController * popoverController = nil;
    
    if(!reusablePopover) {
        
        popoverController = [[UIPopoverController alloc]initWithContentViewController:controller];
        popoverController.delegate = self;
        self.reusablePopover = popoverController;
        self.reusablePopover.delegate = self;
        [popoverController release];
        
    } else {
        
        [reusablePopover setContentViewController:controller animated:YES];
    }
    
    return reusablePopover;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    if(popoverController == reusablePopover) {  // Only on reusablePopover dismissal.
        
        switch(currentReusableView) {
                
            case FPK_REUSABLE_VIEW_NONE: // This should never happens.
                break;
                
            case FPK_REUSABLE_VIEW_OUTLINE:
            case FPK_REUSABLE_VIEW_BOOKMARK:
                
                // The popover has been already dismissed, just set the flag accordingly.
                
                currentReusableView = FPK_REUSABLE_VIEW_NONE;
                break;
                
            case FPK_REUSABLE_VIEW_SEARCH:
                
                if(currentSearchViewMode == FPK_SEARCH_VIEW_MODE_FULL) {
                    
                    [searchManager cancelSearch];
                    
                    currentReusableView = FPK_REUSABLE_VIEW_NONE;
                }
                break;
                // Same as above, but also cancel the search.
                
                
            default: break;
        }
    }
}

-(void)dismissAlternateViewController {
    
    // This is just an utility method that will call the appropriate dismissal procedure depending
    // on which alternate controller is visible to the user.
    
    switch(currentReusableView) {
            
        case FPK_REUSABLE_VIEW_NONE:
            break;
            
        case FPK_REUSABLE_VIEW_OUTLINE:
        case FPK_REUSABLE_VIEW_BOOKMARK:
            
            // Same procedure for both outline and bookmark.
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                [reusablePopover dismissPopoverAnimated:YES];
                
            } else {
                
                [self dismissModalViewControllerAnimated:YES];
            }
            currentReusableView = FPK_REUSABLE_VIEW_NONE;
            break;
            
        case FPK_REUSABLE_VIEW_SEARCH:
            
            if(currentSearchViewMode == FPK_SEARCH_VIEW_MODE_FULL) {
                
                [searchManager cancelSearch];
                [self dismissSearchViewController:searchViewController];            
                currentReusableView = FPK_REUSABLE_VIEW_NONE;
                
            } else if (currentSearchViewMode == FPK_SEARCH_VIEW_MODE_MINI) {
                [searchManager cancelSearch];
                [self dismissMiniSearchView];
                currentReusableView = FPK_REUSABLE_VIEW_NONE;
            }
            
            // Cancel search and remove the controller.
            
            break;
        default: break;
    }
}



#pragma mark -
#pragma mark TextDisplayViewController lazy init and management

-(TextDisplayViewController *)textDisplayViewController {
	
	// Show the text display view controller to the user.
	
	if(nil == textDisplayViewController) {
		textDisplayViewController = [[TextDisplayViewController alloc]initWithNibName:@"TextDisplayView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		textDisplayViewController.documentManager = self.document;
	}
	
	return textDisplayViewController;
}

-(void)dismissTextDisplayViewController:(TextDisplayViewController *)controller {
 
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SearchViewController, _Delegate and _Actions

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
			searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_pad" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		} else {
			searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_phone" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		}
	}
	
	return searchViewController;
}

-(void)presentFullSearchView {
	
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
	
	// Enable overlay and set the search manager as the data source for
	// overlay items.
	[self addOverlayDataSource:searchManager];
	self.overlayEnabled = YES;
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
        [self prepareReusablePopoverControllerWithController:controller];
        
		[reusablePopover setPopoverContentSize:CGSizeMake(450, 650) animated:YES];
		[reusablePopover presentPopoverFromRect:self.searchButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		
		[self presentModalViewController:(UIViewController *)controller animated:YES];
    }
	
    currentReusableView = FPK_REUSABLE_VIEW_SEARCH;
    currentSearchViewMode = FPK_SEARCH_VIEW_MODE_FULL;
}

-(IBAction)actionSearch:(id)sender {
	
	// Get the instance of the Search Manager lazily and then present a full sized search view controller
	// to the user. The full search view controller will allow the user to type in a search term and
	// start the search. Look at the details in the utility method implementation.
	
	[self presentFullSearchView];	// This method will take care of everything.
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
    [self addOverlayDataSource:self.searchManager];
    
	miniSearchView.documentDelegate = self;
	
	// Update the view with the right index.
	[miniSearchView reloadData];
	[miniSearchView setCurrentTextItem:item];
	
	// Add the subview and referesh the superview.
	[[self view]addSubview:miniSearchView];
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
		
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
		
	}

    
	[UIView commitAnimations];
	
    currentReusableView = FPK_REUSABLE_VIEW_SEARCH;
    currentSearchViewMode = FPK_SEARCH_VIEW_MODE_MINI;
}


-(void)dismissMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	// Animation.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,-50 , 320, 44)];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,-50 , 320, 44)];
	}
	[UIView commitAnimations];
	
	// Actual removal.
	if(miniSearchView!=nil) {
		
		[miniSearchView removeFromSuperview];
		MF_COCOA_RELEASE(miniSearchView);
	}
	
	[self removeOverlayDataSource:self.searchManager];
    [self reloadOverlay];   // Reset the overlay to clear any residual highlight.
}

-(void)showMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,50 , 320, 44)];
	}else {
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2,50 , 320, 44)];
	}
	
	[UIView commitAnimations];
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
	[self presentFullSearchView];
}

-(void)switchToMiniSearchView:(MFTextItem *)item {

	// Dismiss the full view and present the minimized one.
	
	[self dismissSearchViewController:searchViewController];
	[self presentMiniSearchViewWithStartingItem:item];
}

-(void)dismissSearchViewController:(SearchViewController *)aSearchViewController {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
        [reusablePopover dismissPopoverAnimated:YES];
        
	} else {
		
        [self dismissModalViewControllerAnimated:YES];
	}
    
    [self removeOverlayDataSource:self.searchManager];
    [self reloadOverlay];
    
    currentReusableView = FPK_REUSABLE_VIEW_NONE;
}

#pragma mark -
#pragma mark BookmarkViewController, _Delegate and _Actions


-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc {
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [reusablePopover dismissPopoverAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
    currentReusableView = FPK_REUSABLE_VIEW_NONE;
}

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page{
	
    self.page = page;
    
    [self dismissAlternateViewController];
}

-(IBAction) actionBookmarks:(id)sender {
	
    //
	//	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
	//	you can also push the controller with the navigation controller or use an UIActionSheet.
	
    BookmarkViewController *bookmarksVC = nil;
    
	if (currentReusableView == FPK_REUSABLE_VIEW_BOOKMARK) {
        
		[self dismissAlternateViewController];
		
	} else {
		
        currentReusableView = FPK_REUSABLE_VIEW_BOOKMARK;
        
		bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		bookmarksVC.delegate = self;
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            [self prepareReusablePopoverControllerWithController:bookmarksVC];
            
			[reusablePopover setPopoverContentSize:CGSizeMake(372, 650) animated:YES];
            [reusablePopover presentPopoverFromRect:self.bookmarksButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
		} else {
			
			[self presentModalViewController:bookmarksVC animated:YES];
		}
        
		[bookmarksVC release];
	}
}

#pragma mark -
#pragma mark OutlineViewController, _Delegate and _Actions

-(void)dismissOutlineViewController:(OutlineViewController *)anOutlineViewController {
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [reusablePopover dismissPopoverAnimated:YES];
        
    } else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
    
    currentReusableView = FPK_REUSABLE_VIEW_NONE;
}

-(void)outlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page{
	
    self.page = page;
	
    [self dismissAlternateViewController];
}

-(IBAction) actionOutline:(id)sender {
	
	// We create an instance of the OutlineViewController and push it onto the stack like we did with the 
	// BookmarksViewController. However, you can show them in the same view with a segmented control, just
	// switch datasources and take it into account in the various tableView delegate methods. Another thing
	// to consider is that the view will be resetted once removed, and for an complex outline is not a nice thing.
	// So, it would be better to store the position in the outline somewhere to present it again the very same
	// view to the user or just retain the outlineVC and just let the application ditch only the view in case
	// of low memory warnings.
	
	OutlineViewController *outlineVC = nil;
    
	if (currentReusableView != FPK_REUSABLE_VIEW_OUTLINE) {
		
        currentReusableView = FPK_REUSABLE_VIEW_OUTLINE;
		
        outlineVC = [[OutlineViewController alloc]initWithNibName:@"OutlineView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
        [outlineVC setDelegate:self];
		
		// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
		// this array and the openentries array somewhere and set them again before present the view to the user again.
		
		[outlineVC setOutlineEntries:[[self document] outline]];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
            [self prepareReusablePopoverControllerWithController:outlineVC];
            
			[reusablePopover setPopoverContentSize:CGSizeMake(372, 530) animated:YES];
            [reusablePopover presentPopoverFromRect:self.outlineButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
		} else {
			
			[self presentModalViewController:outlineVC animated:YES];
		}
        
		[outlineVC release];
        
	} else {
        
        [self dismissAlternateViewController];
        
    }
}


#pragma mark -
#pragma mark Common actions

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

-(IBAction)actionNext:(id)sender {
	
	// This would be connected to an hypotetical next page button. You can enable
	// pageFlipOnEdgeTouch instead.
	
	[self moveToNextPage];
}

-(IBAction)actionPrev:(id)sender {
	
	// Same as actionNext.
	
	[self moveToPreviousPage];
}


-(IBAction) actionDismiss:(id)sender {

	//  For simplicity, the DocumentViewController will remove itself. If you need to pass some
	//  values you can just set up a delegate and implement in a delegate method both the
	//  removal of the DocumentViweController and the processing of the values.
	
	//  Cancel the search if it is in progress.
    
    [self.searchManager cancelSearch];
    
	[self dismissAlternateViewController];
	
	//	Just remove this controller from the navigation stack.
    //  or, if presented as modalviewcontroller, tell the parent to dismiss it.
	//  [[self parentViewController]dismissModalViewControllerAnimated:YES];
    
	[[self navigationController]popViewControllerAnimated:YES];	
}

-(IBAction) actionPageSliderStopped:(id)sender {
	
	// We move to the page only if the user release the slider (on UITouchUpInside).
	
	// Cancel the previous request for thumbnail, we don't need it.
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showThumbnailView) object:nil];
	//[self hideThumbnailView];
	
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
	//[self hideThumbnailView];
	
	// Start a new one.
	//[self performSelector:@selector(showThumbnailView) withObject:nil afterDelay:1.0];
	
	// Get the slider value.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	//We use the instance's thumbPage variable to avoid passing a number to the selector each time.
	//thumbPage = pageNumber;
	
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
		[self setMode:MFDocumentModeOverflow];
	} else if (mode == MFDocumentModeOverflow) {
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
	
	// If autozoom is enable, when the user move to a new page, the zoom will be restored as it
	// was on the last page.
	
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
		
		TextDisplayViewController *controller = self.textDisplayViewController;
		controller.delegate = self;
		[controller updateWithTextOfPage:page];
		[self presentModalViewController:controller animated:YES];
		
	}
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
		
		if(hudHidden) {
			
				[nextButton setHidden:NO];
				[prevButton setHidden:NO];
				
				[autozoomButton setHidden:NO];
				[automodeButton setHidden:NO];
				
				[leadButton setHidden:NO];
				[modeButton setHidden:NO];
				[directionButton setHidden:NO];

			[miniSearchView setHidden:NO];
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
				
			
			[miniSearchView setHidden:YES];
			hudHidden = YES;
		}
	}
}

- (void)documentViewController:(MFDocumentViewController *)dvc didReceiveRequestToGoToDestinationNamed:(NSString *)destinationName ofFile:(NSString *)fileName{
    
    // We set the parameters to the MenuViewController that will open the other document as soon as this one is dismissed
    
    [(MenuViewController *)delegate setLinkedDocument:fileName withPage:-1 orDestinationName:destinationName];
    
    // We need to dismiss the document
    [self actionDismiss:nil];
    
}
- (void)documentViewController:(MFDocumentViewController *)dvc didReceiveRequestToGoToPage:(NSUInteger)pageNumber ofFile:(NSString *)fileName{
    
    // We set the parameters to the MenuViewController that will open the other document as soon as this one is dismissed
    
    [(MenuViewController *)delegate setLinkedDocument:fileName withPage:pageNumber orDestinationName:@""];    
    
    // We need to dismiss the document
    [self actionDismiss:nil];
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
	
	UIButton *aButton = nil;
	
	CGSize viewSize = [[self view]bounds].size;
	
	CGFloat buttonHeight = 20;
	CGFloat buttonWidth = 60;
	CGFloat padding = 10;
	
	UIFont *font = nil;
	
	// Slighty different font sizes on iPad and iPhone.
	
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
		
		hudHidden = YES;
 }

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager {
	
	//
//	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
//	we used to initialize this class. However, since you probably want to track which document are
//	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
//	as long as you pass an instance of it to the superclass initializer.
	
	if((self = [super initWithDocumentManager:aDocumentManager])) {
		[self setDocumentDelegate:self];
        [self setAutoMode:MFDocumentAutoModeOverflow];
        [self setAutomodeOnRotation:YES];
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
	
    [reusablePopover release], reusablePopover = nil;
    
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
