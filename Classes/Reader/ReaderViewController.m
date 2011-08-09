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

#define PAGE_NUM_LABEL_TEXT(x,y) [NSString stringWithFormat:@"%d/%d",(x),(y)]

@interface ReaderViewController()

-(void)dismissMiniSearchView;
-(void)presentTextDisplayViewControllerForPage:(NSUInteger)page;
-(void)revertToFullSearchView;

@end

@implementation ReaderViewController

@synthesize thumbSliderViewHorizontal,thumbsliderHorizontal;
@synthesize thumbImgArray;
@synthesize rollawayToolbar;

@synthesize searchBarButtonItem, changeModeBarButtonItem, zoomLockBarButtonItem, changeDirectionBarButtonItem, changeLeadBarButtonItem;
@synthesize bookmarkBarButtonItem, textBarButtonItem, numberOfPageTitleBarButtonItem, dismissBarButtonItem, outlineBarButtonItem;
@synthesize numberOfPageTitleToolbar;
@synthesize pageNumLabel;
@synthesize documentId;
@synthesize textDisplayViewController;
@synthesize searchViewController;
@synthesize searchManager;
@synthesize miniSearchView;
@synthesize pageSlider;
@synthesize reusablePopover;
@synthesize multimediaVisible;

@synthesize imgModeSingle, imgModeDouble, imgZoomLock, imgZoomUnlock, imgl2r, imgr2l, imgLeadRight, imgLeadLeft;

@synthesize thumbFileManager;

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
		[self hideHorizontalThumbnails];
	}else {
		[self showHorizontalThumbnails];
	}
}

-(void)showHorizontalThumbnails{
    
	if (thumbSliderViewHorizontal.frame.origin.y >= self.view.bounds.size.height) {
	
		[UIView beginAnimations:@"show" context:NULL];
		[UIView setAnimationDuration:0.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[thumbSliderViewHorizontal setFrame:CGRectMake(0, thumbSliderViewHorizontal.frame.origin.y-thumbSliderViewHorizontal.frame.size.height, thumbSliderViewHorizontal.frame.size.width, thumbSliderViewHorizontal.frame.size.height)];
		[UIView commitAnimations];
		thumbsViewVisible = YES;
	}
}

-(void)hideHorizontalThumbnails {
    
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[thumbSliderViewHorizontal setFrame:CGRectMake(0, thumbSliderViewHorizontal.frame.origin.y+thumbSliderViewHorizontal.frame.size.height, thumbSliderViewHorizontal.frame.size.width, thumbSliderViewHorizontal.frame.size.height)];
	[UIView commitAnimations];
	thumbsViewVisible = NO;
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
			[reusablePopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
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
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
        [miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
		[self.view bringSubviewToFront:rollawayToolbar];
        
	}else {
        
		[miniSearchView setFrame:CGRectMake((self.view.frame.size.width-320)/2, 50, 320, 44)];
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
	
	// Call this function to stop the worker threads and release the associated resources.
	pdfOpen = NO;
	[self cleanUp];
    
    [self.searchManager cancelSearch];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES]; // Hide the status bar.
	
	//
	//	Just remove this controller from the navigation stack.
	[[self navigationController]popViewControllerAnimated:YES];	
	
	// Or, if presented as modalviewcontroller, tell the parent to dismiss it.
	// [[self parentViewController]dismissModalViewControllerAnimated:YES];
}

-(IBAction) actionPageSliderSlided:(id)sender {
	
	// When the user move the slider, we update the label.
	
	// Get the slider value.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Update the label.
	[pageNumLabel setText:PAGE_NUM_LABEL_TEXT(pageNumber,[[self document]numberOfPages])];
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
	NSArray *arrayParameter = nil;
	NSString *uriType = nil;
    NSString *uriResource = nil;
    
    NSString * documentPath = nil;
    
    arrayParameter = [uri componentsSeparatedByString:@"://"];
	
    uriType = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:0]];
	
	uriResource = [NSString stringWithFormat:@"%@", [arrayParameter objectAtIndex:1]];
	
	if ([uriType isEqualToString:@"fpke"]) {
		
		documentPath = [self.document.resourceFolder stringByAppendingPathComponent:uriResource];
		
		[self playVideo:documentPath local:YES];
    }
	
	if ([uriType isEqualToString:@"fpkz"]) {
		
		documentPath = [@"http://" stringByAppendingString:uriResource];
		
        [self playVideo:documentPath local:NO];
	}
	
	if ([uriType isEqualToString:@"fpki"]){
		
		documentPath = [self.document.resourceFolder stringByAppendingPathComponent:uriResource];
		
		[self showWebView:documentPath local:YES];
	}
	
	if ([uriType isEqualToString:@"http"]){
		
		[self showWebView:uri local:NO];
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
	[[self parentViewController]presentModalViewController:webBrowser animated:YES];
	
	[webBrowser release];
}

#pragma mark -
#pragma mark MFDocumentViewControllerDelegate methods implementation

-(void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page {
	
	//	Page has changed, either by user input or an internal change upon an event: update the label and the 
	//	slider to reflect that. If you save the current page as a bookmark to it is a good idea to store the value
	//	in this callback.
	
	[pageNumLabel setText:PAGE_NUM_LABEL_TEXT(page,[[self document]numberOfPages])];
	
	[pageSlider setValue:[[NSNumber numberWithUnsignedInteger:page]floatValue] animated:YES];
	
	[thumbsliderHorizontal goToPage:page-1 animated:YES];
	
	[self setNumberOfPageToolbar];
	
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeModeTo:(MFDocumentMode)mode automatic:(BOOL)automatically {
	
	//	The mode has changed, for example from single to double. Update the UI with the right title, image, etc for
	//	the right componenets: in this case a button.
	//	You can also choose to change/update the UI when the setter is called instead, just be sure that you keep track
	//	of the changes in your own variables and check for inconsitencies in the internal state somewhere in your code.
	
	if(mode == MFDocumentModeSingle) {
		[changeModeBarButtonItem setImage:imgModeSingle];
	} else if (mode == MFDocumentModeDouble) {
		[changeModeBarButtonItem setImage:imgModeDouble];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(direction == MFDocumentDirectionL2R) {
		
		[changeDirectionBarButtonItem setImage:imgl2r];
		
	} else if (direction == MFDocumentDirectionR2L) {
		
		[changeDirectionBarButtonItem setImage:imgr2l];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(lead == MFDocumentLeadLeft) {
		
		[changeLeadBarButtonItem setImage:imgLeadLeft];
		
	} else if (lead == MFDocumentLeadRight) {
		
		[changeLeadBarButtonItem setImage:imgLeadRight];
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
	
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		[self dismissAlternateViewController];
	}
	
	if(waitingForTextInput) {
		
		waitingForTextInput = NO;
		
		// Get the text display controller lazily, set up the delegate that will provide the document (this instance)
		// and show it.
		
        [self presentTextDisplayViewControllerForPage:page];
    }
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
	
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		
		[self dismissAlternateViewController];
	}
	
	
	if(!waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
        
        if(!multimediaVisible){
		
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



-(void)prepareToolbar {

    NSMutableArray * items = nil;
    UIBarButtonItem * aBarButtonItem = nil;
    UILabel * aLabel = nil;
    NSString *labelText = nil;
    UIToolbar * aToolbar = nil;
    
	toolbarHeight = 44;
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // IPad.
        
        self.imgModeSingle = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"changeModeSingle",@"png")];
        
        self.imgModeDouble = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"changeModeDouble",@"png")];
        
        self.imgZoomLock = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"zoomLock",@"png")];
        
        self.imgZoomUnlock = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"zoomUnlock",@"png")];
        
        self.imgl2r = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"direction_l2r",@"png")];
        
        self.imgr2l = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"direction_r2l",@"png")];
        
        self.imgLeadRight = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"pagelead",@"png")];
        
        self.imgLeadLeft = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"pagelead",@"png")];
		
	} else { // IPhone.
        
        self.imgModeSingle = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"changeModeSingle_phone",@"png")];
        
        self.imgModeDouble = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"changeModeDouble_phone",@"png")];
        
        self.imgZoomLock = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"zoomLock_phone",@"png")];
        
        self.imgZoomUnlock = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"zoomUnlock_phone",@"png")];
        
        self.imgl2r = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"direction_l2r_phone",@"png")];
        
        self.imgr2l = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"direction_r2l_phone",@"png")];
        
        self.imgLeadRight = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"pagelead_phone",@"png")];
        
        self.imgLeadLeft = [UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"pagelead_phone",@"png")];
	}
	
	items = [[NSMutableArray alloc]init];	// This will be the containter for the bar button items.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Ipad.
		
		aBarButtonItem = nil;
		
		// Dismiss.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"X",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		self.dismissBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Zoom lock.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgZoomUnlock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		self.changeDirectionBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgLeadRight style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change mode.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgModeSingle style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		self.changeModeBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Space.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Page number.
		
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
		
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
		
		// Search.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"search",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		self.searchBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"text",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		self.textBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Outline.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"indice",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		
		[aBarButtonItem setWidth:60];
		self.outlineBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Bookmarks.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"bookmark_add",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		self.bookmarkBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
	} else { // Iphone.
        
        
		// Dismiss.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"X_phone",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
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
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgZoomLock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		[aBarButtonItem setWidth:22];
		self.zoomLockBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change direction.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		[aBarButtonItem setWidth:22];
		self.changeDirectionBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change lead.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgLeadRight style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];
		self.changeLeadBarButtonItem = aBarButtonItem;
		[aBarButtonItem setWidth:25];
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Change mode.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgModeSingle style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
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
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"search_phone",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		[aBarButtonItem setWidth:22];
		self.searchBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Text.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"text_phone",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		[aBarButtonItem setWidth:22];
		self.textBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Outline.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"indice_phone",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		[aBarButtonItem setWidth:22];
		self.outlineBarButtonItem = aBarButtonItem;
		[items addObject:aBarButtonItem];
		[aBarButtonItem release];
		
		// Bookmarks.
		
		aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:MF_BUNDLED_RESOURCE(@"FPKReaderBundle",@"bookmark_add_phone",@"png")] style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		[aBarButtonItem setWidth:25];
		self.bookmarkBarButtonItem = aBarButtonItem;
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
    
    //UIFont *font = nil;
	UIView * aThumbSliderView = nil;
    
    UIToolbar *aThumbSliderToolbar = nil;
    UISlider *aSlider = nil;
    UILabel * aLabel = nil;
    
    NSMutableArray * aThumbImgArray = nil;
    
    CGFloat thumbSliderOffsetX = 0 ;
	CGFloat thumbSliderHeight = 0;
	CGFloat thumbSliderOffsetY = 0;
	CGFloat thumbSliderToolbarHeight= 0;
    
    NSUInteger pagesCount = 0;
    int paddingSlider = 0;
    
    BOOL isPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    
    // Defaulting the flags.
    
    pdfOpen = YES;
	hudHidden = YES;
	currentReusableView = FPK_REUSABLE_VIEW_NONE;
    multimediaVisible = NO;
    
	//	Let the superclass do its stuff (setting up the views), then you can begin to add your own custom subviews
	//	like buttons.
	
	[super viewDidLoad];
	
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
		// Initialize the thumb slider containter view. 
		
		aThumbSliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width,204)];
		thumbSliderToolbarHeight = 44; // Height of the thumb that include the slider.
		thumbSliderViewBorderWidth = 100;
		thumbSliderHeight = 20 ; // Height of the slider.
		
		thumbSliderOffsetY = aThumbSliderView.frame.size.height-44; // Vertical offset of the toolbar.
		thumbSliderOffsetX = thumbSliderOffsetY + 10; // Horizontal offset of the toolbar.
		
	} else {
		
		aThumbSliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 114)];
		thumbSliderToolbarHeight = 44;
		thumbSliderViewBorderWidth = 50;
		thumbSliderHeight = 10;
		thumbSliderOffsetY = aThumbSliderView.frame.size.height-44;
		thumbSliderOffsetX = thumbSliderOffsetY + 10;
	}
	
	[aThumbSliderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	[aThumbSliderView setAutoresizesSubviews:YES];
	[aThumbSliderView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
	
	aThumbSliderToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, thumbSliderOffsetY, self.view.frame.size.width, thumbSliderToolbarHeight)];
	[aThumbSliderToolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
	aThumbSliderToolbar.barStyle = UIBarStyleBlackTranslucent;
	
	[aThumbSliderView addSubview:aThumbSliderToolbar];
	[aThumbSliderToolbar release];
	
	if(isPad) {
		paddingSlider = 10;
	}
    
	//Page slider.
	aSlider = [[UISlider alloc]initWithFrame:CGRectMake((thumbSliderViewBorderWidth/2)-paddingSlider, thumbSliderOffsetX, aThumbSliderView.frame.size.width-thumbSliderViewBorderWidth-(paddingSlider*2),thumbSliderHeight)];
	[aSlider setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
	[aSlider setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
	[aSlider setMinimumValue:1.0];
	[aSlider setMaximumValue:[[self document] numberOfPages]];
	[aSlider setContinuous:YES];
	[aSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
	[aSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
	
	[self setPageSlider:aSlider];
	
	[aThumbSliderView addSubview:aSlider];
	
	[aSlider release];
	
	if(!isPad) {
		
		// Set the number of page into the toolbar at the right the slider on iPhone.
		aLabel = [[UILabel alloc]initWithFrame:CGRectMake((thumbSliderViewBorderWidth/2)+(aThumbSliderView.frame.size.width-thumbSliderViewBorderWidth)-25, thumbSliderOffsetX+6, 55, thumbSliderHeight)];
		[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		aLabel.text = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
		aLabel.textAlignment = UITextAlignmentCenter;
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.textColor = [UIColor whiteColor];
		aLabel.font = [UIFont boldSystemFontOfSize:11.0];
		[aThumbSliderView addSubview:aLabel];
		self.pageNumLabel = aLabel;
		[aLabel release];
	}
	
	[self.view addSubview:aThumbSliderView];
	
	self.thumbSliderViewHorizontal = aThumbSliderView;
	
	[aThumbSliderView release];
	
    
	// Now prepare an image array to display as placeholder for the thumbs.
	
	aThumbImgArray  = [[NSMutableArray alloc]init];
	
	pagesCount = [[self document]numberOfPages];
	
	for (int i=0; i<pagesCount ; i++) {
		[aThumbImgArray insertObject:[NSNull null] atIndex:i];
	}	
	
	self.thumbImgArray = aThumbImgArray;
	
	[aThumbImgArray release];
	
    
	// Utility method to prepare the rollaway toolbar.
	
	[self prepareToolbar];
}


//-(void)viewDidLoad {
//    
//	// 
//	//	Let the superclass do its stuff (setting up the views), then you can begin to add your own custom subviews
//	//	like buttons.
//	
//	[super viewDidLoad];
//	
//	// A few flags.
//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
//    
//	pdfIsOpen = YES;
//	hudHidden=YES;
//	visibleMultimedia = NO;
//	
//	// Slighty different font sizes on iPad and iPhone.
//	
//	UIFont *font = nil;
//	
//	BOOL isPad = NO;
//	
//#ifdef UI_USER_INTERFACE_IDIOM
//	isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
//#endif
//	
// 	if(isPad) {
//		font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
//	} else {
//		font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
//	}
//    
//	CGFloat thumbSliderOffsetX = 0 ;
//	CGFloat thumbSliderHeight = 0;
//	CGFloat thumbSliderOffsetY = 0;
//	CGFloat thumbSliderToolbarHeight= 0;
//	
//	UIView * aThumbSliderView = nil;
//	
//	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//		
//		// Initialize the thumb slider containter view. 
//		
//		aThumbSliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width,204)];
//		thumbSliderToolbarHeight = 44; // Height of the thumb that include the slider.
//		thumbSliderViewBorderWidth = 100;
//		thumbSliderHeight = 20 ; // Height of the slider.
//		
//		thumbSliderOffsetY = aThumbSliderView.frame.size.height-44; // Vertical offset of the toolbar.
//		thumbSliderOffsetX = thumbSliderOffsetY + 10; // Horizontal offset of the toolbar.
//		
//	} else {
//		
//		aThumbSliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 114)];
//		thumbSliderToolbarHeight = 44;
//		thumbSliderViewBorderWidth = 50;
//		thumbSliderHeight = 10;
//		thumbSliderOffsetY = aThumbSliderView.frame.size.height-44;
//		thumbSliderOffsetX = thumbSliderOffsetY + 10;
//		
//	}
//	
//	
//	[aThumbSliderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
//	[aThumbSliderView setAutoresizesSubviews:YES];
//	[aThumbSliderView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
//	
//	UIToolbar *aThumbSliderToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, thumbSliderOffsetY, self.view.frame.size.width, thumbSliderToolbarHeight)];
//	[aThumbSliderToolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
//	aThumbSliderToolbar.barStyle = UIBarStyleBlackTranslucent;
//	
//	[aThumbSliderView addSubview:aThumbSliderToolbar];
//	[aThumbSliderToolbar release];
//	
//	int paddingSlider = 0;
//	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
//		paddingSlider = 10;
//	}
//	
//	
//	//Page slider.
//	UISlider *aSlider = [[UISlider alloc]initWithFrame:CGRectMake((thumbSliderViewBorderWidth/2)-paddingSlider, thumbSliderOffsetX, aThumbSliderView.frame.size.width-thumbSliderViewBorderWidth-(paddingSlider*2),thumbSliderHeight)];
//	[aSlider setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
//	[aSlider setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
//	[aSlider setMinimumValue:1.0];
//	[aSlider setMaximumValue:[[self document] numberOfPages]];
//	[aSlider setContinuous:YES];
//	[aSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
//	[aSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
//	
//	[self setPageSlider:aSlider];
//	
//	[aThumbSliderView addSubview:aSlider];
//	
//	[aSlider release];
//	
//	
//	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
//		
//		// Set the number of page into the toolbar at the right the slider on iPhone.
//		UILabel * aLabel = [[UILabel alloc]initWithFrame:CGRectMake((thumbSliderViewBorderWidth/2)+(aThumbSliderView.frame.size.width-thumbSliderViewBorderWidth)-25, thumbSliderOffsetX+6, 55, thumbSliderHeight)];
//		[aLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//		aLabel.text = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
//		aLabel.textAlignment = UITextAlignmentCenter;
//		aLabel.backgroundColor = [UIColor clearColor];
//		aLabel.textColor = [UIColor whiteColor];
//		aLabel.font = [UIFont boldSystemFontOfSize:11.0];
//		[aThumbSliderView addSubview:aLabel];
//		self.pageNumLabel = aLabel;
//		[aLabel release];
//	}
//	
//	[self.view addSubview:aThumbSliderView];
//	
//	self.thumbSliderViewHorizontal = aThumbSliderView;
//	
//	[aThumbSliderView release];
//	
//	
//	// Now prepare an image array to display as placeholder for the thumbs.
//	
//	NSMutableArray * aThumbImgArray  = [[NSMutableArray alloc]init];
//	
//	NSUInteger pagesCount = [[self document]numberOfPages];
//	
//	for (int i=0; i<pagesCount ; i++) {
//		[aThumbImgArray insertObject:[NSNull null] atIndex:i];
//	}	
//	
//	self.thumbImgArray = aThumbImgArray;
//	
//	[aThumbImgArray release];
//	
//	// Utility method to prepare the rollaway toolbar.
//	
//	[self prepareToolbar];
//	
//}


-(void)setNumberOfPageToolbar{
	
	NSString *labelTitle = nil;
    
    labelTitle = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
	self.pageNumLabel.text = labelTitle;
}

-(void)showToolbar {
	
	// Show toolbar, with animation.
	
	rollawayToolbar.hidden = NO;
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[rollawayToolbar setFrame:CGRectMake(0, 0, rollawayToolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];		
}

-(void)hideToolbar{
	
	// Hide the toolbar, with animation.	
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationDuration:0.35];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[rollawayToolbar setFrame:CGRectMake(0, -toolbarHeight, rollawayToolbar.frame.size.width, toolbarHeight)];
	[UIView commitAnimations];
}

-(void)prepareThumbSlider {
	
//    NSString * sysver = [[UIDevice currentDevice]systemVersion];
    
//    if([sysver isEqualToString:@"5.0"]) // Skip thumbnail slider and thumbnails generation on 5.0.
//        return;
    
    MFHorizontalSlider * anHorizontalThumbSlider = nil;
    
	if(thumbsliderHorizontal)
		return;
	
	// Create the actual thumb slider controller. The controller view will be added manually to the view stack, so you need to call viewDidLoad esplicitely.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray size:CGSizeMake(100, 124) width:self.view.bounds.size.width height:160 type:1 andFolderName:documentId];
		
	}	else {
		
		anHorizontalThumbSlider = [[MFHorizontalSlider alloc] initWithImages:thumbImgArray size:CGSizeMake(50, 64) width:self.view.frame.size.width height:70 type:1 andFolderName:documentId];
	}
	
	anHorizontalThumbSlider.delegate = self;
	
	self.thumbsliderHorizontal = anHorizontalThumbSlider;
	
	[self.thumbSliderViewHorizontal addSubview:thumbsliderHorizontal.view];
	
	[anHorizontalThumbSlider viewDidLoad];
	[anHorizontalThumbSlider release];
	
	// Start generating the thumbs in background.
	
	[self performSelectorInBackground:@selector(generateThumbInBackground) withObject:nil];
}


-(void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	[self prepareThumbSlider];
}


- (void)didTappedOnPage:(int)number ofType:(int)type withObject:(id)object{
	[self setPage:number];
}

- (void)didSelectedPage:(int)number ofType:(int)type withObject:(id)object{
}


-(void)handleThumbDone {
    
    [self.thumbsliderHorizontal refreshThumbnailViewWithPage:currentThumbPage-1];
    // Start next thumbnail operation or abort.
    
    if(currentThumbPage < [[self document]numberOfPages]) {
        
        currentThumbPage++;
        
		[self performSelectorInBackground:@selector(startThumb) withObject:nil];
	} else {
		
        self.thumbFileManager = nil;
        //self.thumbnailFolderPath = nil;
        
	}
}

-(void)startThumb {
    
    NSString * thumbnailFilePath = nil;
    //NSString * thumbnailFileName = nil;
    
    CGImageRef thumbImage = NULL;
    UIImage * thumbnailImage = nil;
    NSData * imageData = nil;
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    //thumbnailFileName = [MFHorizontalSlider thumbnailNameForPage:currentThumbPage];
    //thumbnailFilePath = [self.thumbnailFolderPath stringByAppendingPathComponent:thumbnailFileName];
    
    thumbnailFilePath = [MFHorizontalSlider thumbnailImagePathForPage:currentThumbPage documentId:documentId];
    
    if(![self.thumbFileManager fileExistsAtPath:thumbnailFilePath] && pdfOpen) {
        
        thumbImage = [[self document] createImageForThumbnailOfPageNumber:currentThumbPage ofSize:CGSizeMake(70, 91) andScale:1.0];
        thumbnailImage = [[UIImage alloc]initWithCGImage:thumbImage];
		
		imageData = UIImagePNGRepresentation(thumbnailImage);
        //imageData = UIImageJPEGRepresentation(thumbnailImage,0.8); // JPEG version (will not have alfa).
        
        [self.thumbFileManager createFileAtPath:thumbnailFilePath contents:imageData attributes:nil];
        
        CGImageRelease(thumbImage);
        [thumbnailImage release];
    }
    
    [pool release];
    
    [self performSelectorOnMainThread:@selector(handleThumbDone) withObject:nil waitUntilDone:NO];
}

-(void)generateThumbInBackground {
    
    NSFileManager * fileManager = nil;
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    NSString * thumbFolderPath = [MFHorizontalSlider thumbnailFolderPathForDocumentId:self.documentId];
    
    BOOL isDir = NO;
    NSError * error = nil;
    
    fileManager = [[NSFileManager alloc]init];
    
    if(![fileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDir]) { // Does not exist.
        
        if(![fileManager createDirectoryAtPath:thumbFolderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            
            // Disable thumb here.
            
        }
        
    } else { // Exist...
        
        if(!isDir) { // ... but is not a directory.
            
            if(![fileManager removeItemAtPath:thumbFolderPath error:&error]) {
                
                // Disable thumb here.
                
            } else { // File successfully deleted.
                
                if(![fileManager createDirectoryAtPath:thumbFolderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                    
                    // Disable thumb here.
                    
                }
            }
        }
    }
    
    self.thumbFileManager = fileManager;
    //self.thumbnailFolderPath = thumbFolderPath;
    
    currentThumbPage = 1;
    
    [self performSelectorInBackground:@selector(startThumb) withObject:nil]; // Start the actual thumbnail generation.
    
    // Cleanup.
    
    [fileManager release];
    [pool release];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

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
	
	// Remember to call the super implementation, since MFDocumentViewController will use
	// memory warnings to clear up its rendering cache.
	
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
}

- (void)dealloc {
	
    // UI elements.
    
	[imgModeSingle release];
	[imgModeDouble release];
	[imgZoomLock release];
	[imgZoomUnlock release];
	[imgl2r release];
	[imgr2l release];
	[imgLeadRight release];
	[imgLeadLeft release];
    
    [rollawayToolbar release];
	[thumbnailView release];
	[thumbImgArray release];
	
    [searchBarButtonItem release], searchBarButtonItem = nil;
	[zoomLockBarButtonItem release], zoomLockBarButtonItem = nil;
	[changeModeBarButtonItem release], changeModeBarButtonItem = nil;
	[changeDirectionBarButtonItem release], changeDirectionBarButtonItem = nil;
	[changeLeadBarButtonItem release], changeLeadBarButtonItem = nil;
	
    // Popovers.
    [reusablePopover release];
   
	[numberOfPageTitleBarButtonItem release];
	
	[searchViewController release];
	[textDisplayViewController release];
	[miniSearchView release];
	[searchManager release];
	
    [documentId release];
	
    //[thumbnailFolderPath release];
    [thumbFileManager release];
    
	[super dealloc];
}

@end
