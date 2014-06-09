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
#import "MiniSearchViewController.h"
#import "TextDisplayViewController.h"
#import "SearchManager.h"
#import "MiniSearchView.h"
#import "mfprofile.h"
#import "WebBrowser.h"
#import "AudioViewController.h"
#import "MFAudioPlayerViewImpl.h"

#define PAGE_NUM_LABEL_TEXT(x,y) [NSString stringWithFormat:@"Page %lu of %lu",(x),(y)]
#define PAGE_NUM_LABEL_TEXT_PHONE(x,y) [NSString stringWithFormat:@"%lu / %lu",(x),(y)]

@interface ReaderViewController()

-(void)dismissMiniSearchView;
-(void)presentTextDisplayViewControllerForPage:(NSUInteger)page;
-(void)revertToFullSearchView;

-(void)showToolbar;
-(void)hideToolbar;

@end

@implementation ReaderViewController

@synthesize dismissBlock;
@synthesize navigationbar;
@synthesize rollawayNavigationbar;

@synthesize searchBarButtonItem, changeModeBarButtonItem, zoomLockBarButtonItem, changeDirectionBarButtonItem, changeLeadBarButtonItem;
@synthesize bookmarkBarButtonItem, textBarButtonItem, numberOfPageTitleBarButtonItem, dismissBarButtonItem, outlineBarButtonItem;
@synthesize numberOfPageTitleToolbar;
@synthesize pageNumLabel;

@synthesize textDisplayViewController, searchViewController, miniSearchViewController;
@synthesize searchManager;
@synthesize miniSearchView;
@synthesize reusablePopover;
@synthesize multimediaVisible;
@synthesize navigationbarHeight;
@synthesize changeModeButton,zoomLockButton,changeDirectionButton,changeLeadButton;

@synthesize imgModeSingle, imgModeDouble, imgZoomLock, imgZoomUnlock, imgl2r, imgr2l, imgLeadRight, imgLeadLeft, imgModeOverflow;
@synthesize imgSearch, imgDismiss, imgOutline, imgBookmark, imgText;
@synthesize pageLabelFormat;
@synthesize topBarMarginFroTop;

#pragma mark - Popover

-(UIPopoverController *)prepareReusablePopoverControllerWithController:(UIViewController *)controller {

    UIPopoverController * popoverController = nil;
    
    if(!reusablePopover) {
        
        popoverController = [[UIPopoverController alloc]initWithContentViewController:controller];
        popoverController.delegate = self;
        self.reusablePopover = popoverController;
        self.reusablePopover.delegate = self;
        
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
                
                [self dismissViewControllerAnimated:YES completion:nil];
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
		
	} else {
        
		waitingForTextInput = NO;
	}
}

#pragma mark -
#pragma mark BookmarkViewController, _Delegate and _Actions

-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [reusablePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    currentReusableView = FPK_REUSABLE_VIEW_NONE;
}

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page
{
    self.page = page;
    [self dismissAlternateViewController];
}

-(IBAction) actionBookmarks:(id)sender
{
		//
	//	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
	//	you can also push the controller with the navigation controller or use an UIActionSheet.
	
    BookmarkViewController *bookmarksVC = nil;
    UIBarButtonItem * bbItem = nil;
    
	if (currentReusableView == FPK_REUSABLE_VIEW_BOOKMARK)
    {
    	[self dismissAlternateViewController];
	}
    else
    {
	    currentReusableView = FPK_REUSABLE_VIEW_BOOKMARK;
        
		bookmarksVC = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		bookmarksVC.delegate = self;
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self prepareReusablePopoverControllerWithController:bookmarksVC];
        	[reusablePopover setPopoverContentSize:CGSizeMake(372, 650) animated:YES];
			[reusablePopover presentPopoverFromBarButtonItem:bookmarkBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
        else
        {
			[self presentViewController:bookmarksVC animated:YES completion:nil];
		}
	}
}

#pragma mark -
#pragma mark OutlineViewController, _Delegate and _Actions

-(void)dismissOutlineViewController:(OutlineViewController *)anOutlineViewController
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [reusablePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    currentReusableView = FPK_REUSABLE_VIEW_NONE;
}

-(void)outlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page
{
    self.page = page;
    [self dismissAlternateViewController];
}

-(void)outlineViewController:(OutlineViewController *)ovc
       didRequestDestination:(NSString *)destinationName
                        file:(NSString *)file
{
    // Here's the chance to unload this view controller and load a new one with the starting page set to the page returned
    // by MFDocumentManager's -pageForNamedDestination: method.
}

-(void)outlineViewController:(OutlineViewController *)ovc
              didRequestPage:(NSUInteger)page
                        file:(NSString *)file
{
    // Here's the chance to unload this view controller and load a new one with the starting page set to page.
}

-(IBAction) actionOutline:(id)sender
{
	// We create an instance of the OutlineViewController and push it onto the stack like we did with the
	// BookmarksViewController. However, you can show them in the same view with a segmented control, just
	// switch datasources and take it into account in the various tableView delegate methods. Another thing
	// to consider is that the view will be resetted once removed, and for an complex outline is not a nice thing.
	// So, it would be better to store the position in the outline somewhere to present it again the very same
	// view to the user or just retain the outlineVC and just let the application ditch only the view in case
	// of low memory warnings.
	
	OutlineViewController *outlineVC = nil;
    
	if (currentReusableView != FPK_REUSABLE_VIEW_OUTLINE)
    {
        currentReusableView = FPK_REUSABLE_VIEW_OUTLINE;
        outlineVC = [[OutlineViewController alloc]initWithNibName:@"OutlineView"
                                                           bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
        [outlineVC setDelegate:self];
		
		// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
		// this array and the openentries array somewhere and set them again before present the view to the user again.
		
		[outlineVC setOutlineEntries:[[self document] outline]];
		
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self prepareReusablePopoverControllerWithController:outlineVC];
			[reusablePopover setPopoverContentSize:CGSizeMake(372, 650)
                                          animated:YES];
			[reusablePopover presentPopoverFromBarButtonItem:outlineBarButtonItem
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
		}
        else
        {
			[self presentViewController:outlineVC animated:YES completion:nil];
		}
	}
    else
    {
        [self dismissAlternateViewController];

    }
}
	
#pragma mark -
#pragma mark SearchViewController, _Delegate and _Action

-(void)presentFullSearchView
{
	// Get the search manager lazily and set up the document.
	
	SearchManager * manager = self.searchManager;
	manager.document = self.document;
	
	// Get the search view controller lazily, set the delegate at self to handle
	// document action and the search manager as data source.
	
	SearchViewController * controller = self.searchViewController;
	[controller setDelegate:self];
	controller.searchManager = manager;
	
	// Enable overlay and set the search manager as the data source for
	// overlay items.
	[self addOverlayDataSource:searchManager];
	self.overlayEnabled = YES;
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self prepareReusablePopoverControllerWithController:controller];
        
		[reusablePopover setPopoverContentSize:CGSizeMake(450, 650) animated:YES];
		[reusablePopover presentPopoverFromBarButtonItem:searchBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	}
    else
    {
		[self presentViewController:controller animated:YES completion:nil];
    }
	
    currentReusableView = FPK_REUSABLE_VIEW_SEARCH;
    currentSearchViewMode = FPK_SEARCH_VIEW_MODE_FULL;
}

-(MiniSearchViewController *)miniSearchViewController {
    
    if(!miniSearchViewController) {
        
        miniSearchViewController = [[MiniSearchViewController alloc]initWithNibName:@"MiniSearchViewController" bundle:[NSBundle mainBundle]];
    }
    return miniSearchViewController;
}

-(void)presentMiniSearchViewWithStartingItem:(MFTextItem *)item {
	
	/*
     This method is called only when the (Full) SearchViewController. It first
     get the mini search view controller, add the search manager as overlay
     data source and set up both the controller data source and delegate. Then
     present the mini search view controller view as subview of this view
     controller with custom container view controller logic. */
    
    MiniSearchViewController * controller = self.miniSearchViewController;
    
    UIView * controllerView = controller.view;
    
    controllerView.frame = CGRectMake(0, -45, self.view.bounds.size.width, 44); // Out of sight
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
	controller.dataSource = self.searchManager;
    [self addOverlayDataSource:self.searchManager];
    
    controller.documentDelegate = self;
    
	[controller reloadData];
	[controller setCurrentTextItem:item];
	
	// Add the subview and referesh the superview.
    
    [self addChildViewController:controller];
	[[self view]addSubview:controllerView];
	
    UIViewController * __weak selfPtr = self; // Prevent retain cycle.
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             [controllerView setFrame:CGRectMake(0, 44 + topBarMarginFroTop, selfPtr.view.bounds.size.width, 44)];
                     }
                     completion:^(BOOL finished){
                         
                         [controller didMoveToParentViewController:selfPtr];
                         
                         currentReusableView = FPK_REUSABLE_VIEW_SEARCH;
                         currentSearchViewMode = FPK_SEARCH_VIEW_MODE_MINI;
                     }];
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
	
	/* 
     Remove the mini search view and its associated child view controller from
     this view controller. */
	
    MiniSearchViewController * controller = self.miniSearchViewController;
    [controller willMoveToParentViewController:nil];
    UIView * controllerView = controller.view;
    
    ReaderViewController * __weak selfPtr = self;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             [controllerView setFrame:CGRectMake(0,-45 , selfPtr.view.bounds.size.width, 44)];

                     }
                     completion:^(BOOL finished){
                         
                         [controllerView removeFromSuperview];
                         [controller removeFromParentViewController];
                         
                         [selfPtr removeOverlayDataSource:selfPtr.searchManager];
                         [selfPtr reloadOverlay];   // Reset the overlay to clear any residual highlight.
                     }];
}

-(void)showMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
            [miniSearchView setFrame:CGRectMake(0,66 , self.view.bounds.size.width, 44)];
            [miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        
        }else {
            
            [miniSearchView setFrame:CGRectMake(0,66 , self.view.bounds.size.width, 44)];
            [miniSearchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        }
    } completion:NULL];
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
		
        [self dismissViewControllerAnimated:YES completion:nil];
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
	
    
    // If there's a dismiss block defined, use it. Otherwise, try to guesstimate
    // what is the appropriate dismiss action
    
	if(self.dismissBlock) {
        
        dismissBlock();
        
    } else {
        
        /* Guess dismiss action */
        
        if([self navigationController]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([self respondsToSelector:@selector(presentingViewController)]) {
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
        }
        else if (self.parentViewController) {
            [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
        }
    }
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
    
	webBrowser = [[WebBrowser alloc]initWithNibName:@"WebBrowser"
                                             bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")
                                               link:url
                                              local:isLocal];
	webBrowser.docViewController = self;
    
	[self presentViewController:webBrowser animated:YES completion:nil];
}

#pragma mark -
#pragma mark MFDocumentViewControllerDelegate methods implementation

-(void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)page {
	
	//	Page has changed, either by user input or an internal change upon an event: update the label and the 
	//	slider to reflect that. If you save the current page as a bookmark to it is a good idea to store the value
	//	in this callback.
    
	[self updatePageNumberLabel];
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeModeTo:(MFDocumentMode)mode automatic:(BOOL)automatically {
	
	//	The mode has changed, for example from single to double. Update the UI with the right title, image, etc for
	//	the right componenets: in this case a button.
	//	You can also choose to change/update the UI when the setter is called instead, just be sure that you keep track
	//	of the changes in your own variables and check for inconsitencies in the internal state somewhere in your code.
	
	if(mode == MFDocumentModeSingle) {
        
        [changeModeButton setImage:imgModeSingle forState:UIControlStateNormal];
        
	} else if (mode == MFDocumentModeDouble) {
        
        [changeModeButton setImage:imgModeDouble forState:UIControlStateNormal];
		
	} else if (mode == MFDocumentModeOverflow) {
        
        [changeModeButton setImage:imgModeOverflow forState:UIControlStateNormal];
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [self presentViewController:controller animated:YES completion:nil];
   
    currentReusableView = FPK_REUSABLE_VIEW_TEXT;
}


-(void) documentViewController:(MFDocumentViewController *)dvc
           didReceiveTapOnPage:(NSUInteger)page
                       atPoint:(CGPoint)point
{
        //unused
}

-(void)documentViewController:(MFDocumentViewController *)dvc
         willFollowLinkToPage:(NSUInteger)page
{
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
    
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
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
		aView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 568-20)];   // Status bar only
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
	
}

/**
 * This method will load the image for the toolbar icons. You can override this
 * method to load different images.
 */
-(void)loadResources {
    
    if(self.navigationbarHeight == 0)
    {
        if([[[UIDevice currentDevice]systemVersion]compare:@"7.0" options:NSNumericSearch]!=NSOrderedAscending)
        {
            self.navigationbarHeight = 64.0;
        }
        else
        {
            self.navigationbarHeight = 44.0;
        }
    }
    
    if(!self.imgModeSingle)
        self.imgModeSingle = [UIImage imageNamed:@"mode_single_page"];
    
    if(!self.imgModeDouble)
        self.imgModeDouble = [UIImage imageNamed:@"mode_double_page"];
    
    if(!self.imgModeOverflow)
		self.imgModeOverflow = [UIImage imageNamed:@"mode_overflow"];
    
    if(!self.imgZoomLock)
        self.imgZoomLock = [UIImage imageNamed:@"zoom_lock"];
    
    if(!self.imgZoomUnlock)
        self.imgZoomUnlock = [UIImage imageNamed:@"zoom_unlock"];
    
    if(!self.imgl2r)
        self.imgl2r = [UIImage imageNamed:@"direction_l2r"];
    
    if(!self.imgr2l)
        self.imgr2l = [UIImage imageNamed:@"direction_r2l"];
    
    if(!self.imgLeadRight)
        self.imgLeadRight = [UIImage imageNamed:@"page_lead_right"];
    
    if(!self.imgLeadLeft)
        self.imgLeadLeft = [UIImage imageNamed:@"page_lead_left"];
    
    if(!self.imgDismiss)
        self.imgDismiss = [UIImage imageNamed:@"close"];
        
    if(!self.imgText)
        self.imgText = [UIImage imageNamed:@"text"];
        
    if(!self.imgOutline)
        self.imgOutline = [UIImage imageNamed:@"table_of_contents"];
        
    if(!self.imgBookmark)
        self.imgBookmark = [UIImage imageNamed:@"bookmark"];
        
    if(!self.imgSearch)
        self.imgSearch = [UIImage imageNamed:@"search"];
}

/**
 * This method will create and customize the toolbar.
 */

-(UIBarButtonItem *)searchBarButtonItem
{
    if(!searchBarButtonItem)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:self.imgSearch forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.searchBarButtonItem = barButtonItem;

    }
    return searchBarButtonItem;
}

-(UIButton *)changeModeButton
{
    if(!changeModeButton)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake( 0, 0, 30 , 30 );
        [button setImage:self.imgModeSingle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionChangeMode:) forControlEvents:UIControlEventTouchUpInside];
        self.changeModeButton = button;
    }
    return changeModeButton;
}

-(UIBarButtonItem *)changeModeBarButtonItem
{
    if(!changeModeBarButtonItem)
    {
        UIButton * button = self.changeModeButton;
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
		self.changeModeBarButtonItem = barButtonItem;
    }
    return changeModeBarButtonItem;
}

-(UIButton *)zoomLockButton
{
    if(!zoomLockButton)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake( 0, 0, 30 , 30 );
        [button setImage:self.imgZoomUnlock forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionChangeAutozoom:) forControlEvents:UIControlEventTouchUpInside];
        self.zoomLockButton = button;
    }
    return zoomLockButton;
}

-(UIBarButtonItem *)zoomLockBarButtonItem
{
    if(!zoomLockBarButtonItem)
    {
        UIButton * button = self.zoomLockButton;
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.zoomLockBarButtonItem = barButtonItem;
    }
    return zoomLockBarButtonItem;
}

-(UIButton *)changeDirectionButton
{
    if(!changeDirectionButton)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake( 0, 0, 30 , 30 );
        [button setImage:self.imgl2r forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionChangeDirection:) forControlEvents:UIControlEventTouchUpInside];
        
        self.changeDirectionButton = button;
    }
    return changeDirectionButton;
}

-(UIBarButtonItem *)changeDirectionBarButtonItem
{
    if(!changeDirectionBarButtonItem)
    {
        UIButton * button = self.changeDirectionButton;
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.changeDirectionBarButtonItem = barButtonItem;
    }
    return changeDirectionBarButtonItem;
}

-(UIButton *)changeLeadButton
{
    if(!changeLeadButton)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake( 0, 0, 30 , 30 );
        [button setImage:self.imgLeadRight forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionChangeLead:) forControlEvents:UIControlEventTouchUpInside];
        self.changeLeadButton = button;
    }
    return changeLeadButton;
}

-(UIBarButtonItem *)changeLeadBarButtonItem
{
    if(!changeLeadBarButtonItem)
    {
        UIButton * button = self.changeLeadButton;
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.changeLeadBarButtonItem = barButtonItem;
    }
    return changeLeadBarButtonItem;
}

-(UIBarButtonItem *) bookmarkBarButtonItem
{
    if(!bookmarkBarButtonItem)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:self.imgBookmark forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionBookmarks:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        
		self.bookmarkBarButtonItem = barButtonItem;
    }
    return bookmarkBarButtonItem;
}

- (UIBarButtonItem *) textBarButtonItem
{
    if(!textBarButtonItem)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:self.imgText forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
		self.textBarButtonItem = barButtonItem;
    }
    return textBarButtonItem;
}

-(UIBarButtonItem *) numberOfPageTitleBarButtonItem
{
    if(!numberOfPageTitleBarButtonItem)
    {
        
    }
    return numberOfPageTitleBarButtonItem;
}

-(UIBarButtonItem *) dismissBarButtonItem
{
    if(!dismissBarButtonItem)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:self.imgDismiss forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.dismissBarButtonItem = barButtonItem;
    }
    return dismissBarButtonItem;
}

-(UIBarButtonItem *) outlineBarButtonItem
{
    if(!outlineBarButtonItem)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:self.imgOutline forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionOutline:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.outlineBarButtonItem = barButtonItem;
    }
    return outlineBarButtonItem;
}

-(void)prepareNavigationItem {

    NSMutableArray * leftItems = nil;
    NSMutableArray * rightItems = nil;
    UIView *titleView = nil;
    
    UILabel * aLabel = nil;
    NSString *labelText = nil;
    UIToolbar * aToolbar = nil;
    UIButton *aButton = nil; 
        
	leftItems = [[NSMutableArray alloc]init];
	rightItems = [[NSMutableArray alloc]init];
    
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Ipad.
        
		// Dismiss.
        UIBarButtonItem * dismissBBItem = self.dismissBarButtonItem;
		[leftItems addObject:dismissBBItem];
		
        [leftItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Zoom lock.
        UIBarButtonItem * zoomBBItem = self.zoomLockBarButtonItem;
        [leftItems addObject:zoomBBItem];
		
        [leftItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Change direction.
        UIBarButtonItem * changeDirectionBBItem = self.changeDirectionBarButtonItem;
		[leftItems addObject:changeDirectionBBItem];
		
        [leftItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Change lead.
        UIBarButtonItem * changeLeadBBItem = self.changeLeadBarButtonItem;
		[leftItems addObject:changeLeadBBItem];
        
        [leftItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Change mode.
        UIBarButtonItem * changeModeBBItem = self.changeModeBarButtonItem;
		[leftItems addObject:changeModeBBItem];
		
        [leftItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Page number.
		
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 23)];
		
		aLabel.textAlignment = NSTextAlignmentLeft;
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.shadowColor = [UIColor whiteColor];
		aLabel.shadowOffset = CGSizeMake(0, 1);
		aLabel.textColor = [UIColor whiteColor];
		aLabel.font = [UIFont systemFontOfSize:17.0];
		
		//labelText = PAGE_NUM_LABEL_TEXT([self page],[[self document]numberOfPages]);
		
        aLabel.text = self.title;
		self.pageNumLabel = aLabel;
		
		titleView = aLabel;
		
		// Text
        UIBarButtonItem * textBBItem = self.textBarButtonItem;
		[rightItems addObject:textBBItem];
		
        [rightItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Outline.
        
        UIBarButtonItem * outlineBBItem = self.outlineBarButtonItem;
		[rightItems addObject:outlineBBItem];
        
        [rightItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Bookmarks.
        
        UIBarButtonItem * bookmarkBBItem = self.bookmarkBarButtonItem;
		[rightItems addObject:bookmarkBBItem];
        
        [rightItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
        // Search.
        
        UIBarButtonItem * searchBBItem = self.searchBarButtonItem;
		[rightItems addObject:searchBBItem];
        
		
	} else { // Iphone.
             
       
        // Dismiss
        
        UIBarButtonItem * dismissBBItem = self.dismissBarButtonItem;
		[leftItems addObject:dismissBBItem];
		
		// Zoom lock.
        
        UIBarButtonItem * zoomLockBBItem = self.zoomLockBarButtonItem;
		[leftItems addObject:zoomLockBBItem];
		
        UIBarButtonItem * changeDirectionBBItem = self.changeDirectionBarButtonItem;
        [leftItems addObject:changeDirectionBBItem];
		
		// Change lead.
        //[leftItems addObject:spacer];
        
        UIBarButtonItem * changeLeadBBItem = self.changeLeadBarButtonItem;
		[leftItems addObject:changeLeadBBItem];
        
		// Change mode.
        //[leftItems addObject:spacer];
        
        UIBarButtonItem * changeModeBBItem = self.changeModeBarButtonItem;
        [leftItems addObject:changeModeBBItem];
        
		// Text.
        
        UIBarButtonItem * textBBItem = self.textBarButtonItem;
        [rightItems addObject:textBBItem];
        
		// Outline.
        
        UIBarButtonItem * outlineBBItem = self.outlineBarButtonItem;
        [rightItems addObject:outlineBBItem];
        
		// Bookmarks.
        
        UIBarButtonItem * bookmarksBBItem = self.bookmarkBarButtonItem;
        [rightItems addObject:bookmarksBBItem];
        
        // Search.
        
        UIBarButtonItem * searchBBitem = self.searchBarButtonItem;
		[rightItems addObject:searchBBitem];
	}
    
    if(self.useNavigationControllerNavigationbar) {
        self.navigationItem.leftItemsSupplementBackButton = NO;
        self.navigationItem.leftBarButtonItems = leftItems;
        self.navigationItem.rightBarButtonItems = rightItems;
        self.navigationItem.titleView = titleView;
    }
    else
    {
        [self prepareNavigationbar];
        
        UINavigationItem * navigationItem = [[UINavigationItem alloc]init];
        navigationItem.leftItemsSupplementBackButton = NO;
        navigationItem.leftBarButtonItems = leftItems;
        navigationItem.rightBarButtonItems = rightItems;
        navigationItem.titleView = titleView;

        [self.rollawayNavigationbar pushNavigationItem:navigationItem animated:YES];
    }
}

-(UINavigationBar *)navigationbar {
    
    if(self.useNavigationControllerNavigationbar)
        return nil;
    
    if(!navigationbar) {
        
        CGFloat actualToolbarHeight = self.navigationbarHeight;
        
        UINavigationBar * aNavbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, navigationbarHeight)];
        
        if([[[UIDevice currentDevice]systemVersion]compare:@"7.0" options:NSNumericSearch]!=NSOrderedAscending) {
            [aNavbar setBackgroundImage:[self toolbarBackgroundImage]
                         forBarPosition:UIBarPositionAny
                             barMetrics:UIBarMetricsDefault];
        }
        else
        {
            [aNavbar setBackgroundImage:[self toolbarBackgroundImage]
                          forBarMetrics:UIBarMetricsDefault];
        }
        
        aNavbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        
        self.navigationbar = aNavbar;
    }
    
    return navigationbar;
}

-(void)prepareNavigationbar {
    
    UINavigationBar * navbar = self.navigationbar;
    
    navbar.frame = CGRectMake(0, -navigationbarHeight, self.view.bounds.size.width, navigationbarHeight);
    navbar.hidden = YES;
    navbar.barStyle = UIBarStyleBlackTranslucent;
    navbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:navbar];
    
    self.rollawayNavigationbar = navbar;
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
	[self prepareNavigationItem];
}

/**
 * This method will update the page number label according to either the 
 * pageLabelFormat, if not nil, or the default format and the page and
 * total number of pages.
 */
-(void)updatePageNumberLabel
{	
	NSString *labelTitle = nil;
    
    if(self.pageLabelFormat) {
        
        labelTitle = [NSString stringWithFormat:self.pageLabelFormat, [self page], [[self document] numberOfPages]];
    }
    else {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            labelTitle = PAGE_NUM_LABEL_TEXT((unsigned long)[self page],(unsigned long)[[self document]numberOfPages]);
            
        }
        else {
            
            labelTitle = PAGE_NUM_LABEL_TEXT_PHONE((unsigned long)[self page],(unsigned long)[[self document]numberOfPages]);
        }
    }
    
	self.pageNumLabel.text = labelTitle;
}

/**
 * This method will show the toolbar.
 */
-(void)showToolbar {
	
	// Show toolbar, with animation.
    ReaderViewController * __weak selfPtr = self;
	[UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [selfPtr.rollawayNavigationbar setHidden:NO];
                         [selfPtr.rollawayNavigationbar setFrame:CGRectMake(0, self.topBarMarginFroTop, rollawayNavigationbar.frame.size.width, navigationbarHeight)];
                     }
                     completion:NULL
                     ];
}

/**
 * This method will hide the toolbar.
 */
-(void)hideToolbar{
	
	// Hide the toolbar, with animation.
     ReaderViewController * __weak selfPtr = self;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [selfPtr.rollawayNavigationbar setFrame:CGRectMake(0, -navigationbarHeight, rollawayNavigationbar.frame.size.width, navigationbarHeight)];
                     }
                     completion:^(BOOL finished){
                         [selfPtr.rollawayNavigationbar setHidden:YES];
                     }];
}

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager {
	
	//	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
	//	we used to initialize this class. However, since you probably want to track which document are
	//	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
	//	as long as you pass an instance of it to the superclass initializer.
	    
	if((self = [super initWithDocumentManager:aDocumentManager])) {
		[self setDocumentDelegate:self];
	}
    
    if([[[UIDevice currentDevice]systemVersion]compare:@"7.0" options:NSNumericSearch]!=NSOrderedAscending) {
        topBarMarginFroTop = 0.0;
    } else {
        topBarMarginFroTop = 20.0;
    }
    
	return self;
}


- (void)didReceiveMemoryWarning
{	
    [super didReceiveMemoryWarning];
	
	self.textDisplayViewController = nil;
    self.searchViewController = nil;
    self.miniSearchViewController = nil;
}

#pragma mark - Rotation

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
