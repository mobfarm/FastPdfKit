//
//  DocumentViewController_Kiosk.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "ReaderViewController.h"
#import "BookmarkViewController.h"
#import "OutlineViewController.h"
#import "MFDocumentManager.h"
#import "SearchViewController.h"
#import "TextDisplayViewController.h"
#import "SearchManager.h"
#import "MiniSearchView.h"
#import "mfprofile.h"
#import "WebBrowser.h"
#import "AudioViewController.h"
#import "MFAudioPlayerViewImpl.h"

#define PAGE_NUM_LABEL_TEXT(x,y) [NSString stringWithFormat:@"Page %d of %d",(x),(y)]
#define PAGE_NUM_LABEL_TEXT_PHONE(x,y) [NSString stringWithFormat:@"%d / %d",(x),(y)]

@interface ReaderViewController()

-(void)dismissMiniSearchView;
-(void)presentTextDisplayViewControllerForPage:(NSUInteger)page;
-(void)revertToFullSearchView;

-(void)showToolbar;
-(void)hideToolbar;
-(void)prepareToolbar;

@end

@implementation ReaderViewController

@synthesize rollawayToolbar;

@synthesize searchBarButtonItem, changeModeBarButtonItem, zoomLockBarButtonItem, changeDirectionBarButtonItem, changeLeadBarButtonItem;
@synthesize bookmarkBarButtonItem, textBarButtonItem, numberOfPageTitleBarButtonItem, dismissBarButtonItem, outlineBarButtonItem;
@synthesize numberOfPageTitleToolbar;
@synthesize pageNumLabel;

@synthesize textDisplayViewController;
@synthesize searchViewController;
@synthesize searchManager;
@synthesize miniSearchView;
@synthesize pageSlider;
@synthesize reusablePopover;
@synthesize multimediaVisible;
@synthesize toolbarHeight;
@synthesize changeModeButton,zoomLockButton,changeDirectionButton,changeLeadButton;

@synthesize imgModeSingle, imgModeDouble, imgZoomLock, imgZoomUnlock, imgl2r, imgr2l, imgLeadRight, imgLeadLeft, imgModeOverflow;
@synthesize imgSearch, imgDismiss, imgOutline, imgBookmark, imgText;

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
#pragma mark ThumbnailSlider

-(IBAction) actionThumbnail:(id)sender{
	
	if (thumbsViewVisible) {
		[self hideThumbnails];
	}else {
		[self showThumbnails];
	}
}

#pragma mark -
#pragma mark TextDisplayViewController, _Delegate and _Actions

-(TextDisplayViewController *)textDisplayViewController {
	
	// Show the text display view controller to the user.
	
	if(nil == textDisplayViewController) {
		textDisplayViewController = [[TextDisplayViewController alloc]initWithNibName:@"TextDisplayView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		textDisplayViewController.documentManager = self.document;
	}
	
	return textDisplayViewController;
}

-(IBAction)actionText:(id)sender {
	
    UIAlertView * alert = nil;
    
    [self dismissAlternateViewController];
    
	if(!waitingForTextInput) {
		
		// We set the flag to YES and enable the documenter interaction. The flag is used to discard unwanted
		// user interaction on the document elsewhere, while the document interaction will allow the document
		// manager to notify its delegate (in this case itself) of user generated event on the document, like
		// the tap on a certain page.
		
		waitingForTextInput = YES;
		self.documentInteractionEnabled = YES;
		
		alert = [[UIAlertView alloc]initWithTitle:@"Text" message:@"Select the page you want the text of." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} else {
        
		waitingForTextInput = NO;
	}
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
    UIBarButtonItem * bbItem = nil;
    
	if (currentReusableView == FPK_REUSABLE_VIEW_BOOKMARK) {
        
		[self dismissAlternateViewController];
		
	} else {
		
        currentReusableView = FPK_REUSABLE_VIEW_BOOKMARK;
        
		bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		bookmarksVC.delegate = self;
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            [self prepareReusablePopoverControllerWithController:bookmarksVC];
            
			[reusablePopover setPopoverContentSize:CGSizeMake(372, 650) animated:YES];
			[reusablePopover presentPopoverFromBarButtonItem:bookmarkBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
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

-(void)outlineViewController:(OutlineViewController *)ovc didRequestDestination:(NSString *)destinationName file:(NSString *)file {
    
    // Here's the chance to unload this view controller and load a new one with the starting page set to the page returned
    // by MFDocumentManager's -pageForNamedDestination: method.
}

-(void)outlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page file:(NSString *)file {
    
    // Here's the chance to unload this view controller and load a new one with the starting page set to page.
    
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
            
			[reusablePopover setPopoverContentSize:CGSizeMake(372, 650) animated:YES];
			[reusablePopover presentPopoverFromBarButtonItem:outlineBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
		} else {
			
			[self presentModalViewController:outlineVC animated:YES];
		}
        
		[outlineVC release];

	} else {
        
        [self dismissAlternateViewController];

    }
}
	
#pragma mark -
#pragma mark SearchViewController, _Delegate and _Action

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
		[reusablePopover presentPopoverFromBarButtonItem:searchBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	} else {
		
		[self presentModalViewController:(UIViewController *)controller animated:YES];
    }
	
    currentReusableView = FPK_REUSABLE_VIEW_SEARCH;
    currentSearchViewMode = FPK_SEARCH_VIEW_MODE_FULL;
}

-(void)presentMiniSearchViewWithStartingItem:(MFTextItem *)item {
	
	// This could be rather tricky.
	
	// This method is called only when the (Full) SearchViewController. It first instantiate the
	// mini search view if necessary, then set the mini search view as the delegate for the current
	// search manager - associated until now to the full SVC - then present it to the user.
	
	if(miniSearchView == nil) {
		
		// If nil, allocate and initialize it.
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			self.miniSearchView = [[[MiniSearchView alloc]initWithFrame:CGRectMake(0, -45, self.view.bounds.size.width, 44)]autorelease];
			[miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
			
		}else {
			self.miniSearchView = [[[MiniSearchView alloc]initWithFrame:CGRectMake(0, -45, self.view.bounds.size.width, 44)]autorelease];
			[miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
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
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
        [miniSearchView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, 44)];
        [miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
		[self.view bringSubviewToFront:rollawayToolbar];
        
	}else {
        
		[miniSearchView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, 44)];
        [miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
		[self.view bringSubviewToFront:rollawayToolbar];
	}
    
	[UIView commitAnimations];
	
    currentReusableView = FPK_REUSABLE_VIEW_SEARCH;
    currentSearchViewMode = FPK_SEARCH_VIEW_MODE_MINI;
}

-(SearchViewController *)searchViewController {
	
	// Lazily allocation when required.
	
	if(!searchViewController) {
		
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

-(IBAction)actionSearch:(id)sender {
	
	// Get the instance of the Search Manager lazily and then present a full sized search view controller
	// to the user. The full search view controller will allow the user to type in a search term and
	// start the search. Look at the details in the utility method implementation.
    
    if(currentReusableView!= FPK_REUSABLE_VIEW_SEARCH) {
        
        if(currentSearchViewMode == FPK_SEARCH_VIEW_MODE_MINI) {
            
            [self revertToFullSearchView];
        
        } else {
            
            [self presentFullSearchView];
        }
        
    } else {
        
        if(currentSearchViewMode == FPK_SEARCH_VIEW_MODE_MINI) {
            
            [self revertToFullSearchView];
            
        } else if (currentSearchViewMode == FPK_SEARCH_VIEW_MODE_FULL) {
            
            [self dismissAlternateViewController];    
            
        }
    }
}

-(void)dismissMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
	// Animation.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		[miniSearchView setFrame:CGRectMake(0,-45 , self.view.bounds.size.width, 44)];
	}else {
		[miniSearchView setFrame:CGRectMake(0,-45 , self.view.bounds.size.width, 44)];
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
		[miniSearchView setFrame:CGRectMake(0,66 , self.view.bounds.size.width, 44)];
        [miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
	}else {
		[miniSearchView setFrame:CGRectMake(0,66 , self.view.bounds.size.width, 44)];
        [miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
	}
	
	[UIView commitAnimations];
}

-(SearchManager *)searchManager {
	
	// Lazily allocate and instantiate the search manager.
	
	if(!searchManager) {
		
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
#pragma mark Actions

-(IBAction) actionDismiss:(id)sender {
	
	// For simplicity, the DocumentViewController will remove itself. If you need to pass some
	// values you can just set up a delegate and implement in a delegate method both the
	// removal of the DocumentViweController and the processing of the values.
	
    // Stop the search.
    [self.searchManager cancelSearch];
    
	// Call this function to stop the worker threads and release the associated resources.
	pdfOpen = NO;
	
    [self dismissAlternateViewController];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES]; // Hide the status bar.
	
	//
	//	Just remove this controller from the navigation stack.
    if([self navigationController])
        [[self navigationController] popViewControllerAnimated:YES];	
    else{
        // Or, if presented as modalviewcontroller, tell the parent to dismiss it.
        if ([self respondsToSelector:@selector(presentingViewController)])
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
        else
            [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

-(IBAction) actionPageSliderSlided:(id)sender {
	
	// When the user move the slider, we update the label.
	
	// Get the slider value.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Update the label.
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [pageNumLabel setText:PAGE_NUM_LABEL_TEXT(pageNumber,[[self document]numberOfPages])];
    
    }else{
        
        [pageNumLabel setText:PAGE_NUM_LABEL_TEXT_PHONE(pageNumber,[[self document]numberOfPages])];
    }
}

-(IBAction) actionPageSliderStopped:(id)sender {
	
	// Get the requested page number from the slider.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Go to the page.
	[self setPage:pageNumber];
    
    
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
        
        [self.zoomLockButton setImage:imgZoomUnlock forState:UIControlStateNormal];
        
	} else {
		[self setAutozoomOnPageChange:YES];
        
        
        [self.zoomLockButton setImage:imgZoomLock forState:UIControlStateNormal];
        
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
#pragma mark MFDocumentViewControllerDelegate methods implementation Support for Multimedia


// The nice things about delegate callbacks is that we can use them to update the UI when the internal status of
// the controller changes, rather than query or keep track of it when the user press a button. Just listen for
// the right event and update the UI accordingly.

-(Class<MFAudioPlayerViewProtocol>)classForAudioPlayerView{
    return [MFAudioPlayerViewImpl class];
}


-(BOOL) documentViewController:(MFDocumentViewController *)dvc doesHaveToAutoplayAudio:(NSString *)audioUri{
	return YES;
}

-(BOOL) documentViewController:(MFDocumentViewController *)dvc doesHaveToAutoplayVideo:(NSString *)videoUri{
    return YES;
}

-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveURIRequest:(NSString *)uri{
    
    if (![uri hasPrefix:@"#page="]) {
        
        if (![uri hasPrefix:@"mailto:"]) {
            
            //NSArray *arrayParameter = nil;
            NSString *uriType = nil;
            NSString *uriResource = nil;
            
            NSString * documentPath = nil;
            
            NSRange separatorRange = [uri rangeOfString:@"://"];
            
            if(separatorRange.location!=NSNotFound) {
                
                //arrayParameter = [uri componentsSeparatedByString:@"://"];
                
                //uriType = [arrayParameter objectAtIndex:0];
                uriType = [uri substringToIndex:separatorRange.location];
                //uriResource = [arrayParameter objectAtIndex:1];
                uriResource = [uri substringFromIndex:separatorRange.location + separatorRange.length];
                
                if ([uriType isEqualToString:@"fpke"]||[uriType isEqualToString:@"videomodal"]) {
                    
                    documentPath = [self.document.resourceFolder stringByAppendingPathComponent:uriResource];
                    
                    [self playVideo:documentPath local:YES];
                }
                
                if ([uriType isEqualToString:@"fpkz"]||[uriType isEqualToString:@"videoremotemodal"]) {
                    
                    documentPath = [@"http://" stringByAppendingString:uriResource];
                    
                    [self playVideo:documentPath local:NO];
                }
                
                if ([uriType isEqualToString:@"fpki"]||[uriType isEqualToString:@"htmlmodal"]){
                    
                    documentPath = [self.document.resourceFolder stringByAppendingPathComponent:uriResource];
                    
                    [self showWebView:documentPath local:YES];
                }
                
                if ([uriType isEqualToString:@"http"]){
                    
                    [self showWebView:uri local:NO];
                }
            }
        }
        
    } else {
        
        // Chop the page parameters into an array and set is as current page parameters
        
        NSArray *arrayParameter = nil;
        
        arrayParameter = [uri componentsSeparatedByString:@"="];
        
        [self setPage:[[arrayParameter objectAtIndex:1]intValue]];
    }
}

- (void)playAudio:(NSString *)audioURL local:(BOOL)_isLocal{
	
    AudioViewController *audioVC = nil;
    
	multimediaVisible = YES;
    
	audioVC = [[AudioViewController alloc]initWithNibName:@"AudioViewController" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle") audioFilePath:audioURL local:_isLocal];
	
	audioVC.documentViewController = self;
	
	[audioVC.view setFrame:CGRectMake(0, 0, 272, 40)];
	
	[self.view addSubview:audioVC.view];
    
    [audioVC release];
}

- (void)playVideo:(NSString *)videoPath local:(BOOL)isLocal{
	
    NSURL *url = nil;
	BOOL openVideo = NO;
	MPMoviePlayerViewController *moviePlayViewController = nil;
    NSFileManager * fileManager = nil;
    
	multimediaVisible = YES;
	
	if (isLocal) {
		
		fileManager = [[NSFileManager alloc]init];
		
		if ([fileManager fileExistsAtPath:videoPath]) {
            
			openVideo = YES;
			url = [NSURL fileURLWithPath:videoPath];
		} else {
            
			openVideo = NO;
		}
        
		[fileManager release];
		
	} else {
        
		url = [NSURL URLWithString:videoPath];
		openVideo = YES;
	}
	
	if (openVideo) {
        
		moviePlayViewController=[[MPMoviePlayerViewController alloc] initWithContentURL:url];
		
		if (moviePlayViewController) {
			[self presentMoviePlayerViewControllerAnimated:moviePlayViewController];
			[self setWantsFullScreenLayout:NO];
			moviePlayViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieViewFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:[moviePlayViewController moviePlayer]];
			[moviePlayViewController.moviePlayer play];
		}
        
        [moviePlayViewController release];
	}
}

-(void)myMovieViewFinishedCallback:(NSNotification *)aNotification{
	
    MPMoviePlayerController *moviePlayerController = nil;
    
    moviePlayerController = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
	[moviePlayerController stop];
	
    multimediaVisible = NO;
}

-(void)showWebView:(NSString *)url local:(BOOL)isLocal{
	
    WebBrowser * webBrowser = nil;
    
	multimediaVisible = YES;
    
	webBrowser = [[WebBrowser alloc]initWithNibName:@"WebBrowser" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle") link:url local:isLocal];
	
	webBrowser.docViewController = self;
	[self presentModalViewController:webBrowser animated:YES];
	
	[webBrowser release];
}

#pragma mark -
#pragma mark MFDocumentViewControllerDelegate methods implementation

-(void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page {
	
	//	Page has changed, either by user input or an internal change upon an event: update the label and the 
	//	slider to reflect that. If you save the current page as a bookmark to it is a good idea to store the value
	//	in this callback.
    
	[pageNumLabel setText:PAGE_NUM_LABEL_TEXT(page,[[self document]numberOfPages])];
    
	[self setNumberOfPageToolbar];
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeModeTo:(MFDocumentMode)mode automatic:(BOOL)automatically {
	
	//	The mode has changed, for example from single to double. Update the UI with the right title, image, etc for
	//	the right componenets: in this case a button.
	//	You can also choose to change/update the UI when the setter is called instead, just be sure that you keep track
	//	of the changes in your own variables and check for inconsitencies in the internal state somewhere in your code.
	
	if(mode == MFDocumentModeSingle) {
        
        [changeModeButton setImage:imgModeSingle forState:UIControlStateNormal];
        
		//[changeModeBarButtonItem setImage:imgModeSingle];
	} else if (mode == MFDocumentModeDouble) {
        [changeModeButton setImage:imgModeDouble forState:UIControlStateNormal];
		//[changeModeBarButtonItem setImage:imgModeDouble];
	} else if (mode == MFDocumentModeOverflow) {
        [changeModeButton setImage:imgModeOverflow forState:UIControlStateNormal];
        //[changeModeBarButtonItem setImage:imgModeOverflow];
    }
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(direction == MFDocumentDirectionL2R) {
        
        
        [self.changeDirectionButton setImage:imgl2r forState:UIControlStateNormal];
		

		
	} else if (direction == MFDocumentDirectionR2L) {
        
        [self.changeDirectionButton setImage:imgr2l forState:UIControlStateNormal];		
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(lead == MFDocumentLeadLeft) {
        
        [self.changeLeadButton setImage:imgLeadLeft forState:UIControlStateNormal];
		
		//[changeLeadBarButtonItem setImage:imgLeadLeft];
		
	} else if (lead == MFDocumentLeadRight) {
        
        [self.changeLeadButton setImage:imgLeadRight forState:UIControlStateNormal];
		
		//[changeLeadBarButtonItem setImage:imgLeadRight];
	}
}

-(void)dismissTextDisplayViewController:(TextDisplayViewController *)controller {
    
    [self dismissModalViewControllerAnimated:YES];
    currentReusableView = FPK_REUSABLE_VIEW_NONE;
}

-(void)presentTextDisplayViewControllerForPage:(NSUInteger)page {
    
    TextDisplayViewController * controller = nil;
    
    if(currentReusableView != FPK_REUSABLE_VIEW_NONE) {
        
        [self dismissAlternateViewController];
    }
    
    controller = self.textDisplayViewController;
    controller.delegate = self;
    [controller updateWithTextOfPage:page];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentModalViewController:controller animated:YES];
   
    currentReusableView = FPK_REUSABLE_VIEW_TEXT;
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnPage:(NSUInteger)page atPoint:(CGPoint)point {
	
        //unused

}

-(void)documentViewController:(MFDocumentViewController *)dvc willFollowLinkToPage:(NSUInteger)page {
    willFollowLink = YES; 
}

-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
    // Skip if we are going to move to a different page because the user tapped on the view to
    // over an internal link. Check the documentViewController:willFollowLinkToPage: callback.
    if(willFollowLink) {
        willFollowLink = NO;
        return;
    }
    
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
    
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		
		[self dismissAlternateViewController];
	}
	
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
        
        if(!multimediaVisible){
		
            if(hudHidden) {
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
			
                [self showToolbar];
                [self showThumbnails];
			
                [miniSearchView setHidden:NO];
			
                hudHidden = NO;
			
            } else {
			
                // Hide
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			
                [self hideToolbar];
                [self hideThumbnails];
			
                [miniSearchView setHidden:YES];
			
                hudHidden = YES;
            }
        }
	}else{
    
        waitingForTextInput = NO;
		
		// Get the text display controller lazily, set up the delegate that will provide the document (this instance)
		// and show it.
		
        [self presentTextDisplayViewControllerForPage:[self page]];
    }
}

#pragma mark -
#pragma mark UIViewController lifcecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// Create the view of the right size. Keep into consideration height of the status bar and the navigation bar. If
	// you want to add a toolbar, use the navigation controller's one like you would with an UIImageView to not cover
	// the document.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self setWantsFullScreenLayout:YES];
	
	UIView * aView = nil;
	BOOL isPad = NO;
    
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    
 	if(isPad) {
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 768, 1024-20)];  // Status bar only
	} else {
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 480-20)];   // Status bar only
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

-(void)loadResources {
    
    if(self.toolbarHeight == 0)
        self.toolbarHeight = 44.0;
    
    if(!self.imgModeSingle)
        self.imgModeSingle = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"changeModeSingle",@"png")];
    
    if(!self.imgModeDouble)
        self.imgModeDouble = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"changeModeDouble",@"png")];
    
    if(!self.imgZoomLock)
        self.imgZoomLock = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"zoomLock",@"png")];
    
    if(!self.imgZoomUnlock)
        self.imgZoomUnlock = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"zoomUnlock",@"png")];
    
    if(!self.imgl2r)
        self.imgl2r = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"direction_l2r",@"png")];
    
    if(!self.imgr2l)
        self.imgr2l = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"direction_r2l",@"png")];
    
    if(!self.imgLeadRight)
        self.imgLeadRight = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"pagelead",@"png")];
    
    if(!self.imgLeadLeft)
        self.imgLeadLeft = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"pagelead",@"png")];
    
    if(!self.imgModeOverflow)
		self.imgModeOverflow = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"changeModeOverflow", @"png")];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if(!self.imgDismiss)
            self.imgDismiss = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"X", @"png")];
        
        if(!self.imgText)
            self.imgText = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"text", @"png")];
        
        if(!self.imgOutline)
            self.imgOutline = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"indice", @"png")];
        
        if(!self.imgBookmark)
            self.imgBookmark = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"bookmark_add", @"png")];
        
        if(!self.imgSearch)
            self.imgSearch = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"search", @"png")];    
        
    } else {
     
        if(!self.imgDismiss)
            self.imgDismiss = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"X_phone", @"png")];
        
        if(!self.imgText)
            self.imgText = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"text_phone", @"png")];
        
        if(!self.imgOutline)
            self.imgOutline = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"indice_phone", @"png")];
        
        if(!self.imgBookmark)
            self.imgBookmark = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"bookmark_add_phone", @"png")];
        
        if(!self.imgSearch)
            self.imgSearch = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle", @"search_phone", @"png")];
    }
}

-(void)prepareToolbar {

    NSMutableArray * items = nil;
    UIBarButtonItem * aBarButtonItem = nil;
    UILabel * aLabel = nil;
    NSString *labelText = nil;
    UIToolbar * aToolbar = nil;
    UIButton *aButton = nil; 
        
	items = [[NSMutableArray alloc]init];	// This will be the containter for the bar button items.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Ipad.
        
		// Dismiss.
        
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 34 , 30);

        [aButton setImage:self.imgDismiss forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.dismissBarButtonItem = aBarButtonItem;

		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
				
		// Zoom lock.
        
        self.zoomLockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.zoomLockButton.bounds = CGRectMake( 0, 0, 30 , 30 );    
        [self.zoomLockButton setImage:imgZoomUnlock forState:UIControlStateNormal];
        [self.zoomLockButton addTarget:self action:@selector(actionChangeAutozoom:) forControlEvents:UIControlEventTouchUpInside];    
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.zoomLockButton];
        
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
        
        self.changeDirectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeDirectionButton.bounds = CGRectMake( 0, 0, 30 , 30 );    
        [self.changeDirectionButton setImage:imgl2r forState:UIControlStateNormal];
        [self.changeDirectionButton addTarget:self action:@selector(actionChangeDirection:) forControlEvents:UIControlEventTouchUpInside];    
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.changeDirectionButton];
        
        self.changeDirectionBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
        
        self.changeLeadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeLeadButton.bounds = CGRectMake( 0, 0, 30 , 30 );    
        [self.changeLeadButton setImage:imgLeadRight forState:UIControlStateNormal];
        [self.changeLeadButton addTarget:self action:@selector(actionChangeLead:) forControlEvents:UIControlEventTouchUpInside];    
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.changeLeadButton];
        
        self.changeLeadBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
        
		[aBarButtonItem release];
		
		// Change mode.
        
        self.changeModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeModeButton.bounds = CGRectMake( 0, 0, 30 , 30 );    
        [self.changeModeButton setImage:imgModeSingle forState:UIControlStateNormal];
        [self.changeModeButton addTarget:self action:@selector(actionChangeMode:) forControlEvents:UIControlEventTouchUpInside];    
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.changeModeButton];
        
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Page number.
		
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 23)];
		
		aLabel.textAlignment = UITextAlignmentLeft;
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.shadowColor = [UIColor whiteColor];
		aLabel.shadowOffset = CGSizeMake(0, 1);
		aLabel.textColor = [UIColor whiteColor];
		aLabel.font = [UIFont boldSystemFontOfSize:20.0];
		
		labelText = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);		
		aLabel.text = labelText;
		self.pageNumLabel = aLabel;
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aLabel];
		self.numberOfPageTitleBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		[aLabel release];
		
		// Space.
        
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 34 , 30);
        
        [aButton setImage:self.imgText forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.textBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Outline.
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 34 , 30);
       
        [aButton setImage:self.imgOutline forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionOutline:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.outlineBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
		// Bookmarks.
        
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 34 , 30);
        
        [aButton setImage:self.imgBookmark forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionBookmarks:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.bookmarkBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
        // Search.
        
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 34 , 30);
        
        [aButton setImage:self.imgSearch forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.searchBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
		
	} else { // Iphone.
             
       
        // Dismiss
        
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 30 , 24);
       
        [aButton setImage:self.imgDismiss forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.dismissBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		
         // Space
         
         aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
         [items addObject:aBarButtonItem];
         [aBarButtonItem release];
         
		
		// Zoom lock.
        
        self.zoomLockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.zoomLockButton.bounds = CGRectMake( 0, 0, 24 , 24 );    
        [self.zoomLockButton setImage:imgZoomUnlock forState:UIControlStateNormal];
        [self.zoomLockButton addTarget:self action:@selector(actionChangeAutozoom:) forControlEvents:UIControlEventTouchUpInside];    
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.zoomLockButton];
        
        
		//aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgZoomUnlock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
        
        self.changeDirectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeDirectionButton.bounds = CGRectMake( 0, 0, 24 , 24 );    
        [self.changeDirectionButton setImage:imgl2r forState:UIControlStateNormal];
        [self.changeDirectionButton addTarget:self action:@selector(actionChangeDirection:) forControlEvents:UIControlEventTouchUpInside];    
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.changeDirectionButton];
        
		
		//aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		self.changeDirectionBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
        
        self.changeLeadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeLeadButton.bounds = CGRectMake( 0, 0, 24 , 24 );    
        [self.changeLeadButton setImage:imgLeadRight forState:UIControlStateNormal];
        [self.changeLeadButton addTarget:self action:@selector(actionChangeLead:) forControlEvents:UIControlEventTouchUpInside];    
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.changeLeadButton];
        
		
		//aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
        
		[aBarButtonItem release];
		
		// Change mode.
        
        self.changeModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeModeButton.bounds = CGRectMake( 0, 0, 24 , 24 );    
        [self.changeModeButton setImage:imgModeSingle forState:UIControlStateNormal];
        [self.changeModeButton addTarget:self action:@selector(actionChangeMode:) forControlEvents:UIControlEventTouchUpInside];    
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.changeModeButton];
        
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
        // Space
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [items addObject:aBarButtonItem];
        [aBarButtonItem release];
        
		
		// Text.
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 25 , 25);
        
        [aButton setImage:self.imgText forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
        
		self.textBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
		
		// Outline.
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 24 , 24);
        
        [aButton setImage:self.imgOutline forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionOutline:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
        
		self.outlineBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
        
		// Bookmarks.
        
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 24 , 24);
        
        [aButton setImage:self.imgBookmark forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionBookmarks:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
        
		self.bookmarkBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
        
        // Search.
        
        aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.bounds = CGRectMake( 0, 0, 24 , 24);
        
        [aButton setImage:self.imgSearch forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(actionSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
        
		self.searchBarButtonItem = aBarButtonItem;
        
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
	}
	
	aToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, self.view.bounds.size.width, toolbarHeight)];
	aToolbar.hidden = YES;
	aToolbar.barStyle = UIBarStyleBlackTranslucent;
	[aToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	[aToolbar setItems:items animated:NO];
	
	[self.view addSubview:aToolbar];
	
	self.rollawayToolbar = aToolbar;
	
	[aToolbar release];
	[items release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    // Defaulting the flags.
    
    pdfOpen = YES;
	hudHidden = YES;
	currentReusableView = FPK_REUSABLE_VIEW_NONE;
    multimediaVisible = NO;
    
	//	Let the superclass do its stuff (setting up the views), then you can begin to add your own custom subviews
	//	like buttons.
	
	[super viewDidLoad];
	
    [self loadResources];
	[self prepareToolbar];
}


-(void)setNumberOfPageToolbar{
	
	NSString *labelTitle = nil;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        labelTitle = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
    
    } else {
    
        labelTitle = PAGE_NUM_LABEL_TEXT_PHONE([self page],[[self document]numberOfPages]);
    }
    
	self.pageNumLabel.text = labelTitle;
}

-(void)showToolbar {
	
	// Show toolbar, with animation.
	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[self.rollawayToolbar setHidden:NO];
    [self.rollawayToolbar setFrame:CGRectMake(0, 20, rollawayToolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];		
}

-(void)hideToolbar{
	
	// Hide the toolbar, with animation.	
    
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[self.rollawayToolbar setFrame:CGRectMake(0, -toolbarHeight, rollawayToolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];
}



-(void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
}


-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager {
	
	//	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
	//	we used to initialize this class. However, since you probably want to track which document are
	//	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
	//	as long as you pass an instance of it to the superclass initializer.
	    
	if((self = [super initWithDocumentManager:aDocumentManager])) {
		[self setDocumentDelegate:self];
	}
	return self;
}


- (void)didReceiveMemoryWarning {
	
	self.textDisplayViewController = nil;
    self.searchViewController = nil;
    
	[super didReceiveMemoryWarning];
    
    if(!self.isViewLoaded) {
        
        // This will be called in place of viewDidUnload on iOS 6
        
        self.pageSlider = nil;
        self.miniSearchView = nil;
        self.pageNumLabel = nil;
        self.numberOfPageTitleToolbar = nil;
        
        self.rollawayToolbar = nil;
        
        // Button and bar buttons
        
        self.changeModeBarButtonItem = nil;
        self.zoomLockBarButtonItem = nil;
        self.changeDirectionBarButtonItem = nil;
        self.changeLeadBarButtonItem = nil;
        self.searchBarButtonItem = nil;
        self.textBarButtonItem = nil;
        self.numberOfPageTitleBarButtonItem = nil;
        self.outlineBarButtonItem = nil;
        self.bookmarkBarButtonItem = nil;
        self.dismissBarButtonItem = nil;
        
        self.changeModeButton = nil;
        self.zoomLockButton = nil;
        self.changeDirectionButton = nil;
        self.changeLeadButton = nil;
    }
}

- (void)viewDidUnload {
    
    self.pageSlider = nil;
    self.miniSearchView = nil;
    self.pageNumLabel = nil;
    self.numberOfPageTitleToolbar = nil;
    
    self.rollawayToolbar = nil;
    
    // Button and bar buttons
    
    self.changeModeBarButtonItem = nil;
	self.zoomLockBarButtonItem = nil;
	self.changeDirectionBarButtonItem = nil;
	self.changeLeadBarButtonItem = nil;
	self.searchBarButtonItem = nil;
    self.textBarButtonItem = nil;
    self.numberOfPageTitleBarButtonItem = nil;
    self.outlineBarButtonItem = nil;
    self.bookmarkBarButtonItem = nil;
    self.dismissBarButtonItem = nil;
    
    self.changeModeButton = nil;
	self.zoomLockButton = nil;
	self.changeDirectionButton = nil;
	self.changeLeadButton = nil;
    
    [super viewDidUnload];
}

- (void)dealloc {
	
    // UI images.
    
	[imgModeSingle release];
	[imgModeDouble release];
    [imgModeOverflow release];
	[imgZoomLock release];
	[imgZoomUnlock release];
	[imgl2r release];
	[imgr2l release];
	[imgLeadRight release];
	[imgLeadLeft release];
    [imgBookmark release];
    [imgDismiss release];
    [imgText release];
    [imgSearch release];
    [imgOutline release];
    
    [rollawayToolbar release];
	
    // Bar button item.
    
    [searchBarButtonItem release], searchBarButtonItem = nil;
	[zoomLockBarButtonItem release], zoomLockBarButtonItem = nil;
	[changeModeBarButtonItem release], changeModeBarButtonItem = nil;
	[changeDirectionBarButtonItem release], changeDirectionBarButtonItem = nil;
	[changeLeadBarButtonItem release], changeLeadBarButtonItem = nil;
    [textBarButtonItem release], textBarButtonItem = nil;
    [numberOfPageTitleBarButtonItem release], numberOfPageTitleBarButtonItem = nil;
    [outlineBarButtonItem release], outlineBarButtonItem = nil;
    [bookmarkBarButtonItem release], bookmarkBarButtonItem = nil;
    [dismissBarButtonItem release], dismissBarButtonItem = nil;
    
    // Inner buttons.
    
    [zoomLockButton release],zoomLockButton = nil;
    [changeModeButton release],changeModeButton = nil;
    [changeLeadButton release],changeLeadButton = nil;
    [changeDirectionButton release],changeDirectionButton = nil;
	
    // Popovers.
    
    [reusablePopover release];
   
	[numberOfPageTitleBarButtonItem release];
	
	[searchViewController release];
	[textDisplayViewController release];
	[miniSearchView release];
	[searchManager release];
    
    [super dealloc];
}

@end
