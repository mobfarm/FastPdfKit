//
//  ReaderViewController.m
//  FastPdfKit
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

#define FPK_REUSABLE_VIEW_NONE 0
#define FPK_REUSABLE_VIEW_SEARCH 1
#define FPK_REUSABLE_VIEW_TEXT 2
#define FPK_REUSABLE_VIEW_OUTLINE 3
#define FPK_REUSABLE_VIEW_BOOKMARK 4

static const NSUInteger FPKReusableViewNone = FPK_REUSABLE_VIEW_NONE;
static const NSUInteger FPKReusableViewSearch = FPK_REUSABLE_VIEW_SEARCH;
static const NSUInteger FPKReusableViewText = FPK_REUSABLE_VIEW_TEXT;
static const NSUInteger FPKReusableViewOutline = FPK_REUSABLE_VIEW_OUTLINE;
static const NSUInteger FPKReusableViewBookmarks = FPK_REUSABLE_VIEW_BOOKMARK;

#define FPK_SEARCH_VIEW_MODE_MINI 0
#define FPK_SEARCH_VIEW_MODE_FULL 1

static const NSUInteger FPKSearchViewModeMini = FPK_SEARCH_VIEW_MODE_MINI;
static const NSUInteger FPKSearchViewModeFull = FPK_SEARCH_VIEW_MODE_FULL;

#define PAGE_NUM_LABEL_TEXT(x,y) [NSString stringWithFormat:@"Page %lu of %lu",(x),(y)]
#define PAGE_NUM_LABEL_TEXT_PHONE(x,y) [NSString stringWithFormat:@"%lu / %lu",(x),(y)]

@interface ReaderViewController() <UIPopoverPresentationControllerDelegate>

@property (nonatomic, readwrite) NSUInteger currentReusableView;
@property (nonatomic, readwrite) NSUInteger currentSearchViewMode;

@property (nonatomic, readwrite) BOOL thumbsViewVisible;
@property (nonatomic, readwrite) BOOL waitingForTextInput;
@property (nonatomic, readwrite) BOOL pdfOpen;
@property (nonatomic, readwrite) BOOL willFollowLink;
@property (nonatomic, readwrite) BOOL hudHidden;
@end

@implementation ReaderViewController

-(UIPopoverController *)prepareReusablePopoverControllerWithController:(UIViewController *)controller {

    if(!self.reusablePopover) {
        
        UIPopoverController * popoverController = [[UIPopoverController alloc]initWithContentViewController:controller];
        popoverController.delegate = self;
        self.reusablePopover = popoverController;
        self.reusablePopover.delegate = self;
        
    } else {
        
        [self.reusablePopover setContentViewController:controller animated:YES];
    }

    return self.reusablePopover;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    if(popoverController == self.reusablePopover) {  // Only on reusablePopover dismissal.
        
        switch(self.currentReusableView) {
                
            case FPKReusableViewNone: // This should never happens.
                break;
                
            case FPKReusableViewOutline:
            case FPKReusableViewBookmarks:
                
                // The popover has been already dismissed, just set the flag accordingly.
                
                self.currentReusableView = FPKReusableViewNone;
                break;
                
            case FPKReusableViewSearch:
                
                if(self.currentSearchViewMode == FPKSearchViewModeFull) {
                    
                    self.currentReusableView = FPKReusableViewNone;
                }
                break;
                // Same as above, but also cancel the search.
                
            default: break;
        }
    }
}

-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    switch(self.currentReusableView)
    {
            
        case FPKReusableViewNone: // This should never happens.
            break;
            
        case FPKReusableViewOutline:
        case FPKReusableViewBookmarks:
            
            // The popover has been already dismissed, just set the flag accordingly.
            
            self.currentReusableView = FPKReusableViewNone;
            break;
            
        case FPKReusableViewSearch:
            
            if(self.currentSearchViewMode == FPKSearchViewModeFull)
            {
                self.currentReusableView = FPKReusableViewNone;
            }
            break;
            // Same as above, but also cancel the search.
            
        default: break;
    }
}

-(void)dismissAlternateViewController {
    
    // This is just an utility method that will call the appropriate dismissal procedure depending
    // on which alternate controller is visible to the user.
    
    switch(self.currentReusableView) {
            
        case FPKReusableViewNone:
            break;
            
        case FPKReusableViewText:
            
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            self.currentReusableView = FPKReusableViewNone;
            
            break;
            
        case FPKReusableViewOutline:
        case FPKReusableViewBookmarks:
            
            // Same procedure for both outline and bookmark.
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
                if([UIPresentationController class])
                {
                    if(self.presentedViewController) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                else
                {
                    [self.reusablePopover dismissPopoverAnimated:YES];
                }
                
            } else {
                
                /* On iPad iOS 8 and iPhone whe have a presented view controller */
                
                if(self.presentedViewController) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            self.currentReusableView = FPKReusableViewNone;
            break;
            
        case FPKReusableViewSearch:
            
            if(self.currentSearchViewMode == FPKSearchViewModeFull) {
           
                [self dismissSearchViewController:_searchViewController];
                self.currentReusableView = FPKReusableViewNone;
                
            } else if (self.currentSearchViewMode == FPKSearchViewModeMini) {
           
                [self dismissMiniSearchView];
                self.currentReusableView = FPKReusableViewNone;
            }
            
            // Cancel search and remove the controller.
            
            break;
        default: break;
    }
}

-(void)presentViewController:(UIViewController *)controller
                    fromRect:(CGRect)rect
                  sourceView:(UIView *)view
                 contentSize:(CGSize)contentSize
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        if([UIPopoverPresentationController class]) {
            
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            controller.modalPresentationStyle = UIModalPresentationPopover;
            
            UIPopoverPresentationController * popoverPresentationController = controller.popoverPresentationController;
            
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popoverPresentationController.sourceRect = rect;
            popoverPresentationController.sourceView = view;
            popoverPresentationController.delegate = self;
            
            [self presentViewController:controller animated:YES completion:nil];
            
        } else {
            
            [self prepareReusablePopoverControllerWithController:controller];
            
            [self.reusablePopover setPopoverContentSize:contentSize animated:YES];
            [self.reusablePopover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
    } else {
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void)presentViewController:(UIViewController *)controller
               barButtonItem:(UIBarButtonItem *)barButtonItem
                 contentSize:(CGSize)contentSize
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if([UIPopoverPresentationController class]) {
                
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            controller.modalPresentationStyle = UIModalPresentationPopover;
            
            UIPopoverPresentationController * popoverPresentationController = controller.popoverPresentationController;
            
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popoverPresentationController.barButtonItem = barButtonItem;
            popoverPresentationController.delegate = self;
            
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            [self prepareReusablePopoverControllerWithController:controller];
            
            [self.reusablePopover setPopoverContentSize:contentSize animated:YES];
            [self.reusablePopover presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark ThumbnailSlider

-(IBAction) actionThumbnail:(id)sender{
	
	if (self.thumbsViewVisible) {
		[self hideThumbnails];
	}else {
		[self showThumbnails];
	}
}

#pragma mark -
#pragma mark TextDisplayViewController, _Delegate and _Actions

/**
 * Lazily allocated TextDisplayViewController.
 */
-(TextDisplayViewController *)textDisplayViewController {
	
	// Show the text display view controller to the user.
	
	if(!_textDisplayViewController) {
		_textDisplayViewController = [[TextDisplayViewController alloc]initWithNibName:@"TextDisplayView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		_textDisplayViewController.documentManager = self.document;
	}
	
	return _textDisplayViewController;
}

-(IBAction)actionText:(id)sender {
    
    [self dismissAlternateViewController];
    
	if(!self.waitingForTextInput) {
		
		// We set the flag to YES and enable the documenter interaction. The flag is used to discard unwanted
		// user interaction on the document elsewhere, while the document interaction will allow the document
		// manager to notify its delegate (in this case itself) of user generated event on the document, like
		// the tap on a certain page.
		
		self.waitingForTextInput = YES;
		self.documentInteractionEnabled = YES;
		
		UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Text"
                                                        message:@"Select the page you want the text of."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
		[alert show];
		
	} else {
        
		self.waitingForTextInput = NO;
	}
}

#pragma mark - Status bar

-(UIStatusBarStyle)preferredStatusBarStyle {
    if(self.rollawayToolbar == nil || self.rollawayToolbar.hidden) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIToolbarDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    if (bar == self.rollawayToolbar) {
        return UIBarPositionTopAttached;
    }
    return UIBarPositionAny;
}

#pragma mark -
#pragma mark BookmarkViewController, _Delegate and _Actions

-(BookmarkViewController *)bookmarksViewController {
    if(!_bookmarksViewController) {
        _bookmarksViewController = [[BookmarkViewController alloc]initWithNibName:@"BookmarkView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
    }
    return _bookmarksViewController;
}

-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc {
	
    [self dismissAlternateViewController];
}

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page{
	
    self.page = page;
    
    [self dismissAlternateViewController];
}

-(void)presentBookmarksViewController {
    
    //	We create an instance of the BookmarkViewController and push it onto the stack as a model view controller, but
    //	you can also push the controller with the navigation controller or use an UIActionSheet.
    
    if (self.currentReusableView == FPKReusableViewBookmarks) {
        
        [self dismissAlternateViewController];
        
    } else {
        
        self.currentReusableView = FPKReusableViewBookmarks;
        
        BookmarkViewController * bookmarksVC = self.bookmarksViewController;
        bookmarksVC.delegate = self;
        
        [self presentViewController:bookmarksVC barButtonItem:self.bookmarkBarButtonItem contentSize:self.popoverContentSize];
    }
}

-(IBAction) actionBookmarks:(id)sender {
	
    [self presentBookmarksViewController];
}


#pragma mark -
#pragma mark OutlineViewController, _Delegate and _Actions

-(void)dismissOutlineViewController:(OutlineViewController *)anOutlineViewController {
	
    [self dismissAlternateViewController];
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
    
    NSLog(@"%@ %lu", file, (unsigned long)page);
}

-(OutlineViewController *)outlineViewController {
    
    // Lazily allocation when required.
    
    if(!_outlineViewController) {
        
        // We use different xib on iPhone and iPad.
        _outlineViewController = [[OutlineViewController alloc]initWithNibName:@"OutlineView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
    }
    return _outlineViewController;
}

-(void)presentOutlineViewController {
    
    if (self.currentReusableView == FPKReusableViewOutline) {
        
        [self dismissAlternateViewController];
        
    } else {
        
        self.currentReusableView = FPKReusableViewOutline;
        
        OutlineViewController * controller = self.outlineViewController;
        [controller setOutlineEntries: [[self document] outline]];
        controller.delegate = self;
        
        [self presentViewController:controller barButtonItem:self.outlineBarButtonItem contentSize:self.popoverContentSize];
    }
}

-(IBAction) actionOutline:(id)sender {
    
    [self presentOutlineViewController];
}

#pragma mark - SearchViewControllerDelegate

-(MFDocumentManager *)documentForSearchViewController:(SearchViewController *)controller {
    return self.document;
}

-(SearchManager *)searchForSearchViewController:(SearchViewController *)controller {
    return [self searchManager];
}

-(void)searchViewController:(SearchViewController *)controller setPage:(NSUInteger)page withZoomOfLevel:(float)zoomLevel onRect:(CGRect)rect {
    [self setPage:page withZoomOfLevel:zoomLevel onRect:rect];
}

-(void)searchViewController:(SearchViewController *)controller addSearch:(SearchManager *)searchManager {
    
    [self addOverlayViewDataSource:searchManager name:@"FPKSearchManager"];
    [self reloadOverlay];
}

-(void)searchViewController:(SearchViewController *)controller removeSearch:(SearchManager *)searchManager {
    
    [self removeOverlayViewDataSourceWithName:@"FPKSearchManager"];
    [self reloadOverlay];
}

-(void)searchViewController:(SearchViewController *)controller switchToMiniSearchView:(FPKSearchMatchItem *)item {
    
    [self dismissSearchViewController:self.searchViewController];
    [self presentMiniSearchViewWithStartingItem:item];
}

-(NSUInteger)pageForSearchViewController:(SearchViewController *)controller {
    return self.page;
}

-(void)dismissSearchViewController:(SearchViewController *)aSearchViewController {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        /* Dismiss the popover on iPad pre iOS 8 */

        if([UIPopoverPresentationController class]) {
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else
        {
            [self.reusablePopover dismissPopoverAnimated:YES];
        }
    }
    else
    {
        /* Dismiss the presented view controller on iPad iOS 8 and iPhone */
        if(self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    self.currentReusableView = FPKReusableViewNone;
}

#pragma mark - Search stuff

-(void)revertToFullSearchView {
    
    [self dismissMiniSearchView];
    [self presentFullSearchView];
}

-(void)handleSearchGotCancelledNotification:(NSNotification *)notification {
    
    if(self.currentReusableView == FPKReusableViewSearch) {
        [self dismissSearchViewController:self.searchViewController];
    }
}

-(void)handleSearchUpdateNotification:(NSNotification *)notification {
    
    NSDictionary * userInfo = notification.userInfo;
    NSInteger page = [userInfo[kNotificationSearchInfoPage] integerValue];
    NSInteger delta = page - self.page;
    
    if(self.isViewLoaded && (delta < 2)) {
        // We get up to two false 'current' page positives but it is good enogh for now.
        [self reloadOverlay];
    }
}

-(void)presentFullSearchView {
	
    // Get the full search view controller lazily, set it upt as the delegate for
    // the search manager and present it to the user modally.
    
    SearchViewController * controller = self.searchViewController;
    controller.delegate = self;
    controller.searchManager = [self searchManager];
    
    // Enable overlay and set the search manager as the data source for
    // overlay items.
    self.overlayEnabled = YES;
    
    self.currentReusableView = FPKReusableViewSearch;
    self.currentSearchViewMode = FPKSearchViewModeFull;
    
    CGSize popoverContentSize = CGSizeMake(450, 650);
    [self presentViewController:controller
                  barButtonItem:self.searchBarButtonItem
                    contentSize:popoverContentSize];
}

-(MiniSearchView *)miniSearchView {
    if(!_miniSearchView) {
        // If nil, allocate and initialize it.
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            MiniSearchView * view = [[MiniSearchView alloc]initWithFrame:CGRectMake(0, -45, self.view.bounds.size.width, 44)];
            view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
            [view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
            self.miniSearchView = view;
        } else {
            
            MiniSearchView * view = [[MiniSearchView alloc]initWithFrame:CGRectMake(0, -45, self.view.bounds.size.width, 44)];
            view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
            [view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
            self.miniSearchView = view;
        }
    }
    
    return _miniSearchView;
}

-(void)presentMiniSearchViewWithStartingItem:(FPKSearchMatchItem *)item {
	
	// This could be rather tricky.
	
	// This method is called only when the (Full) SearchViewController. It first instantiate the
	// mini search view if necessary, then set the mini search view as the delegate for the current
	// search manager - associated until now to the full SVC - then present it to the user.
    
    if(self.miniSearchView.superview != nil) {
        [self.miniSearchView removeFromSuperview];
    }
    
	// Set up the connections
    
	self.miniSearchView.delegate = self;
	
	// Update the view with the right index.
	[self.miniSearchView reloadData];
    self.miniSearchView.currentSearchResultIndex = [[[self searchManager] allSearchResults] indexOfObject:item];
	
	// Add the subview and referesh the superview.
	[[self view]addSubview:self.miniSearchView];
	
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                             
                             self.miniSearchView.frame = CGRectMake(0, (self.topLayoutGuide.length + self.rollawayToolbar.frame.size.height), self.view.bounds.size.width, 44);
                             self.miniSearchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
                             
                         } else {
                             
                             self.miniSearchView.frame = CGRectMake(0, (self.topLayoutGuide.length +  self.rollawayToolbar.frame.size.height), self.view.bounds.size.width, 44);
                             self.miniSearchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
                         }
                     }
                     completion:^(BOOL finished){
                         
                         [self.view bringSubviewToFront:self.rollawayToolbar];
                         
                         self.currentReusableView = FPKReusableViewSearch;
                         self.currentSearchViewMode = FPKSearchViewModeMini;
                     }];
}

-(SearchManager *)searchManager {
    id<FPKOverlayViewDataSource> dataSource = [self overlayViewDataSourceWithName:@"FPKSearchManager"];
    if([dataSource isKindOfClass:[SearchManager class]]) {
        return (SearchManager *)dataSource;
    }
    return nil;
}

/**
 * SearchViewController, lazily allocated.
 */
-(SearchViewController *)searchViewController {
	
	// Lazily allocation when required.
	
	if(!_searchViewController) {
		
		// We use different xib on iPhone and iPad.
        
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			_searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_pad" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		} else {
			_searchViewController = [[SearchViewController alloc]initWithNibName:@"SearchView2_phone" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
		}
	}
	return _searchViewController;
}

-(IBAction)actionSearch:(id)sender {
	
	// Get the instance of the Search Manager lazily and then present a full sized search view controller
	// to the user. The full search view controller will allow the user to type in a search term and
	// start the search. Look at the details in the utility method implementation.
    
    if(self.currentReusableView!= FPKReusableViewSearch) {
        
        if(self.currentSearchViewMode == FPKSearchViewModeMini) {
            
            [self revertToFullSearchView];
        
        } else {
            
            [self presentFullSearchView];
        }
        
    } else {
        
        if(self.currentSearchViewMode == FPKSearchViewModeMini) {
            
            [self revertToFullSearchView];
            
        } else if (self.currentSearchViewMode == FPKSearchViewModeFull) {
            
            [self dismissAlternateViewController];    
            
        }
    }
}

#pragma mark - MiniSearchViewDelegate

-(NSUInteger )numberOfSearchResults:(MiniSearchView *)view {
    
    NSUInteger count = [[[self searchManager] allSearchResults] count];
#if DEBUG
    NSLog(@"sarch results %d", count);
#endif
    return count;
}

-(FPKSearchMatchItem *)miniSearchView:(MiniSearchView *)view searchResultAtIndex:(NSUInteger)index {
    
    
    return [[[self searchManager] allSearchResults] objectAtIndex:index];
}

-(void)miniSearchView:(MiniSearchView *)view
              setPage:(NSUInteger)page
            zoomLevel:(float)zoomLevel
                 rect:(CGRect)rect {
    
    [self setPage:page withZoomOfLevel:zoomLevel onRect:rect];
}

-(void)dismissMiniSearchView:(MiniSearchView *)view {
    
    [self dismissMiniSearchView];
}

-(void)revertToFullSearchViewFromMiniSearchView:(MiniSearchView *)view {
    
    // Dismiss the minimized view and present the full one.
    [self revertToFullSearchView];
}

-(void)cancelSearch:(MiniSearchView *)view {
    
    [self dismissMiniSearchView];
    
    [[self searchManager] stopSearch];
    [self removeOverlayViewDataSourceWithName:@"FPKSearchManager"];
    [self reloadOverlay];
}

-(void)dismissMiniSearchView {
    
	// Animation.
    ReaderViewController * __weak this = self;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                             
                             this.miniSearchView.frame = CGRectMake(0,-45 , this.view.bounds.size.width, 44);
                         } else {
                             
                             this.miniSearchView.frame = CGRectMake(0,-45 , this.view.bounds.size.width, 44);
                         }
                     }
                     completion:^(BOOL finished){
                         // Actual removal.
                         if(this.miniSearchView!=nil) {
                             
                             [this.miniSearchView removeFromSuperview];
                         }
                     }];
}

-(void)showMiniSearchView {
	
	// Remove from the superview and release the mini search view.
	
    ReaderViewController * __weak this = self;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
            this.miniSearchView.frame = CGRectMake(0,66 , this.view.bounds.size.width, 44);
            this.miniSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        }else {
            
            this.miniSearchView.frame = CGRectMake(0,66 , this.view.bounds.size.width, 44);
            this.miniSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        }
    } completion:NULL];
}

#pragma mark - Actions

-(IBAction) actionDismiss:(id)sender {
	
	// For simplicity, the DocumentViewController will remove itself. If you need to pass some
	// values you can just set up a delegate and implement in a delegate method both the
	// removal of the DocumentViweController and the processing of the values.
	
    // Call this function to stop the worker threads and release the associated resources.
	self.pdfOpen = NO;
	
    [self dismissAlternateViewController];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES]; // Hide the status bar.
	
    
    // If there's a dismiss block defined, use it. Otherwise, try to guesstimate
    // what is the appropriate dismiss action
    
	if(self.dismissBlock) {
        
        self.dismissBlock();
        
    } else {
        
        /* Default behavior is to pop itself if on a navigation stack or
         tell the presenting view controller to dimiss the presented view
         controller (this) */
        
        if ([self navigationController]) {
            
            [[self navigationController] popViewControllerAnimated:YES];
            
        } else if(self.presentingViewController) {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)pageSliderCancel:(UISlider *)slider {
    [super pageSliderCancel:slider];
    
    [self updatePageNumberLabel];
}

-(void)pageSliderSlided:(UISlider *)slider {
    
    [super pageSliderSlided:slider];
    
    // Get the slider value.
    NSNumber *number = [NSNumber numberWithFloat:[slider value]];
    NSUInteger pageNumber = [number unsignedIntValue];
    
    // Update the label.
    
    [self updatePageNumberLabelWithPage:pageNumber];
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
        [self.zoomLockBarButtonItem setImage:self.imgZoomUnlock];
	
    } else {
        
        [self setAutozoomOnPageChange:YES];
        [self.zoomLockBarButtonItem setImage:self.imgZoomLock];
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

-(BOOL) documentViewController:(MFDocumentViewController *)dvc didReceiveURIRequest:(NSString *)uri{
    
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
                    
                    return YES;
                }
                
                if ([uriType isEqualToString:@"fpkz"]||[uriType isEqualToString:@"videoremotemodal"]) {
                    
                    documentPath = [@"http://" stringByAppendingString:uriResource];
                    
                    [self playVideo:documentPath local:NO];
                
                    return YES;
                }
                
                if ([uriType isEqualToString:@"fpki"]||[uriType isEqualToString:@"htmlmodal"]){
                    
                    documentPath = [self.document.resourceFolder stringByAppendingPathComponent:uriResource];
                    
                    [self showWebView:documentPath local:YES];
                
                    return YES;
                }
                
                if ([uriType isEqualToString:@"http"]){
                    
                    [self showWebView:uri local:NO];
                    
                    return YES;
                }
            }
        }
        
    } else {
        
        // Chop the page parameters into an array and set is as current page parameters
        
        NSArray *arrayParameter = nil;
        
        arrayParameter = [uri componentsSeparatedByString:@"="];
        
        [self setPage:[[arrayParameter objectAtIndex:1]intValue]];
        
    }
    
    return NO;
}

- (void)playAudio:(NSString *)audioURL local:(BOOL)_isLocal{
	
    self.multimediaVisible = YES;
    
    AudioViewController *audioVC = [[AudioViewController alloc]initWithNibName:@"AudioViewController" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle") audioFilePath:audioURL local:_isLocal];
	
	audioVC.documentViewController = self;
	
	[audioVC.view setFrame:CGRectMake(0, 0, 272, 40)];
	
	[self.view addSubview:audioVC.view];
}

- (void)playVideo:(NSString *)videoPath local:(BOOL)isLocal{
	
    NSURL *url = nil;
	BOOL openVideo = NO;
	self.multimediaVisible = YES;
	
	if (isLocal) {
		
        NSFileManager * fileManager = [[NSFileManager alloc]init];
		
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
        
        MPMoviePlayerViewController *moviePlayViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
		
		if (moviePlayViewController) {
			[self presentMoviePlayerViewControllerAnimated:moviePlayViewController];
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
	
    self.multimediaVisible = NO;
}

-(void)showWebView:(NSString *)url local:(BOOL)isLocal{
	
    self.multimediaVisible = YES;
    
    WebBrowser * webBrowser = [[WebBrowser alloc]initWithNibName:@"WebBrowser" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle") link:url local:isLocal];
	
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
        
        [self.changeModeBarButtonItem setImage:self.imgModeSingle];
        
	} else if (mode == MFDocumentModeDouble) {
        
        [self.changeModeBarButtonItem setImage:self.imgModeDouble];
        
	} else if (mode == MFDocumentModeOverflow) {
        
        [self.changeModeBarButtonItem setImage:self.imgModeOverflow];
    }
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeDirectionTo:(MFDocumentDirection)direction {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(direction == MFDocumentDirectionL2R) {
        
        [self.changeDirectionBarButtonItem setImage:self.imgl2r];
		
	} else if (direction == MFDocumentDirectionR2L) {
        
        [self.changeDirectionBarButtonItem setImage:self.imgr2l];
	}
}

-(void) documentViewController:(MFDocumentViewController *)dvc didChangeLeadTo:(MFDocumentLead)lead {
	
	//
	//	Update the UI to reflect change in the internal status (rename buttons, change icon, etc).
	
	if(lead == MFDocumentLeadLeft) {
        
        [self.changeLeadBarButtonItem setImage:self.imgLeadLeft];
		
	} else if (lead == MFDocumentLeadRight) {
        
        [self.changeLeadBarButtonItem setImage:self.imgLeadRight];
	}
}

-(void)dismissTextDisplayViewController:(TextDisplayViewController *)controller {
    
    [self dismissAlternateViewController];
}

-(void)presentTextDisplayViewControllerForPage:(NSUInteger)page {
    
    TextDisplayViewController * controller = nil;
    
    if(self.currentReusableView != FPKReusableViewNone) {
        
        [self dismissAlternateViewController];
    }
    
    controller = self.textDisplayViewController;
    controller.delegate = self;
    [controller updateWithTextOfPage:page];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:controller animated:YES completion:nil];
   
    self.currentReusableView = FPKReusableViewText;
}


-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapOnPage:(NSUInteger)page atPoint:(CGPoint)point {
	
        //unused

}

-(void)documentViewController:(MFDocumentViewController *)dvc willFollowLinkToPage:(NSUInteger)page {
    self.willFollowLink = YES;
}

-(void) documentViewController:(MFDocumentViewController *)dvc didReceiveTapAtPoint:(CGPoint)point {
	
    // Skip if we are going to move to a different page because the user tapped on the view to
    // over an internal link. Check the documentViewController:willFollowLinkToPage: callback.
    if(self.willFollowLink) {
        self.willFollowLink = NO;
        return;
    }
    
	// If the flag waitingForTextInput is enabled, we use the touch event to select the page. Otherwise,
	// we are free to use it to show/hide the selected HUD elements.
    
	if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
		
		[self dismissAlternateViewController];
	}
	
	
	if(!self.waitingForTextInput) {
		
		//	We are using this callback to selectively hide/unhide some UI components like the buttons.
        
        if(!self.multimediaVisible){
		
            if(self.hudHidden) {
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
			
                [self showToolbar];
                [self showThumbnails];
			
                self.miniSearchView.hidden = NO;
			
                self.hudHidden = NO;
			
            } else {
			
                // Hide
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			
                [self hideToolbar];
                [self hideThumbnails];
			
                self.miniSearchView.hidden = YES;
			
                self.hudHidden = YES;
            }
        }
        
	} else {
    
        self.waitingForTextInput = NO;
		
		// Get the text display controller lazily, set up the delegate that will provide the document (this instance)
		// and show it.
		
        [self presentTextDisplayViewControllerForPage:[self page]];
    }
}

#pragma mark -
#pragma mark UIViewController lifcecycle

/**
 * This method will load the image for the toolbar icons. You can override this
 * method to load different images.
 */
-(void)loadResources {
    
    if(!self.imgModeSingle) {
        self.imgModeSingle = [FPK_BUNDLED_IMAGE(@"changeModeSingle") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgModeDouble) {
        self.imgModeDouble = [FPK_BUNDLED_IMAGE(@"changeModeDouble") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgZoomLock) {
        self.imgZoomLock = [FPK_BUNDLED_IMAGE(@"zoomLock") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgZoomUnlock) {
        self.imgZoomUnlock = [FPK_BUNDLED_IMAGE(@"zoomUnlock") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgl2r) {
        self.imgl2r = [FPK_BUNDLED_IMAGE(@"direction_l2r") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgr2l) {
        self.imgr2l = [FPK_BUNDLED_IMAGE(@"direction_r2l") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgLeadRight) {
        self.imgLeadRight = [FPK_BUNDLED_IMAGE(@"pagelead") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgLeadLeft) {
        self.imgLeadLeft = [FPK_BUNDLED_IMAGE(@"pagelead") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgModeOverflow) {
		self.imgModeOverflow = [FPK_BUNDLED_IMAGE(@"changeModeOverflow") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgDismiss) {
        
        self.imgDismiss = [FPK_BUNDLED_IMAGE(@"X") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgText) {
        self.imgText = [FPK_BUNDLED_IMAGE(@"text") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgOutline) {
        self.imgOutline = [FPK_BUNDLED_IMAGE(@"indice") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgBookmark) {
        self.imgBookmark = [FPK_BUNDLED_IMAGE(@"bookmark_add") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if(!self.imgSearch) {
        self.imgSearch = [FPK_BUNDLED_IMAGE(@"search") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

/**
 * This method will create and customize the toolbar.
 */
-(void)prepareToolbar {
        
	NSMutableArray * items = [[NSMutableArray alloc]init];	// This will be the containter for the bar button items.
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // Ipad.
        
		// Dismiss.

        self.dismissBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgDismiss style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
		[items addObject:self.dismissBarButtonItem];
		
		// Zoom lock.
        
        self.zoomLockBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgZoomLock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
		[items addObject:self.zoomLockBarButtonItem];
		
		// Change direction.
        
        self.changeDirectionBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
		[items addObject:self.changeDirectionBarButtonItem];
		
		// Change lead.
        
        self.changeLeadBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgLeadRight style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];;
		[items addObject:self.changeLeadBarButtonItem];
		
		// Change mode.
        
        self.changeModeBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgModeSingle style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
		[items addObject:self.changeModeBarButtonItem];
		
		// Space.
		[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
		
		// Page number.
		
		UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 23)];
		
        label.textAlignment = NSTextAlignmentLeft;
		label.backgroundColor = [UIColor clearColor];
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont boldSystemFontOfSize:20.0];
		
        NSString * labelText = [self pageLabelString];
		label.text = labelText;
		self.pageNumLabel = label;
		
		self.numberOfPageTitleBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];;
		[items addObject:self.numberOfPageTitleBarButtonItem];
        
		// Space.
        
		[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
		
		// Text.
        
		self.textBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgText style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
		[items addObject:self.textBarButtonItem];
		
		// Outline.
        
		self.outlineBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgOutline style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
		[items addObject:self.outlineBarButtonItem];
        
		// Bookmarks.
        
        self.bookmarkBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgBookmark style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
		[items addObject:self.bookmarkBarButtonItem];
        
        // Search.
        
		self.searchBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgSearch style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
		[items addObject:self.searchBarButtonItem];
		
	} else { // Iphone.
        
        // Dismiss
        
        self.dismissBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgDismiss style:UIBarButtonItemStylePlain target:self action:@selector(actionDismiss:)];
        [items addObject:self.dismissBarButtonItem];

         // Space
         
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
		
		
		// Zoom lock
        
        self.zoomLockBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgZoomLock style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeAutozoom:)];
        [items addObject:self.zoomLockBarButtonItem];
		
		// Change direction.
    
        self.changeDirectionBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgl2r style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeDirection:)];
        [items addObject:self.changeDirectionBarButtonItem];

		// Change lead.
		
        self.changeLeadBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgLeadRight style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeLead:)];;
        [items addObject:self.changeLeadBarButtonItem];
		
		// Change mode.
        
        self.changeModeBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgModeSingle style:UIBarButtonItemStylePlain target:self action:@selector(actionChangeMode:)];
        [items addObject:self.changeModeBarButtonItem];
        
        // Space
        
      	[items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
		// Text.
        
        self.textBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgText style:UIBarButtonItemStylePlain target:self action:@selector(actionText:)];
        [items addObject:self.textBarButtonItem];
		
		// Outline.
        
        self.outlineBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgOutline style:UIBarButtonItemStylePlain target:self action:@selector(actionOutline:)];
        [items addObject:self.outlineBarButtonItem];
    
		// Bookmarks.
        
        self.bookmarkBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgBookmark style:UIBarButtonItemStylePlain target:self action:@selector(actionBookmarks:)];
        [items addObject:self.bookmarkBarButtonItem];
		
        // Search.
        
        self.searchBarButtonItem = [[UIBarButtonItem alloc]initWithImage:self.imgSearch style:UIBarButtonItemStylePlain target:self action:@selector(actionSearch:)];
        [items addObject:self.searchBarButtonItem];
	}
	
	UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.frame = CGRectMake(0, -self.toolbarHeight, self.view.bounds.size.width, self.toolbarHeight);
	toolbar.hidden = YES;
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	[toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	[toolbar setItems:items animated:NO];
    toolbar.delegate = self;
    
	[self.view addSubview:toolbar];
	
	self.rollawayToolbar = toolbar;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    // Defaulting the flags.
    
    self.pdfOpen = YES;
	self.hudHidden = YES;
	self.currentReusableView = FPKReusableViewNone;
    self.multimediaVisible = NO;
    self.toolbarHeight = 44.0;
    
	//	Let the superclass do its stuff (setting up the views), then you can begin to add your own custom subviews
	//	like buttons.
	
	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    [self loadResources];
	[self prepareToolbar];
}

-(NSString *)pageLabelTitleForPage:(NSUInteger)page {
    if(self.pageLabelFormat) {
        
        return [NSString stringWithFormat:self.pageLabelFormat, page, [[self document] numberOfPages]];
    
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        return PAGE_NUM_LABEL_TEXT((unsigned long)page,(unsigned long)[[self document]numberOfPages]);
    }
    else {
        
        return PAGE_NUM_LABEL_TEXT_PHONE((unsigned long)page,(unsigned long)[[self document]numberOfPages]);
    }
}

-(NSString *)pageLabelString {
    
    return [self pageLabelTitleForPage:[self page]];
}

/**
 * This method will update the page number label according to either the
 * pageLabelFormat, if not nil, or the default format and the page and
 * total number of pages.
 */
-(void)updatePageNumberLabel {
    
    NSString *labelTitle = [self pageLabelString];
    self.pageNumLabel.text = labelTitle;
}

/**
 * This method will update the page number label with an arbitrary page number,
 * for example while the slider is being dragged by the user.
 */
-(void)updatePageNumberLabelWithPage:(NSUInteger)page {
    
    NSString *labelTitle = [self pageLabelTitleForPage:page];
    self.pageNumLabel.text = labelTitle;
}

/**
 * This method will show the toolbar.
 */
-(void)showToolbar {

    // We used topLayoutGuide.length property to calculate the clearance.
    
    ReaderViewController * __weak this = self;
    [UIView animateWithDuration:.25f
                          delay:.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         this.rollawayToolbar.hidden = NO;
                        [this setNeedsStatusBarAppearanceUpdate];
                         this.rollawayToolbar.frame = CGRectMake(0, self.topLayoutGuide.length, this.rollawayToolbar.frame.size.width, this.rollawayToolbar.frame.size.height);
                     }
                     completion:^(BOOL finished) {

                     }
                     ];
}

/**
 * This method will hide the toolbar.
 */
-(void)hideToolbar {
	
	// Hide the toolbar, with animation.
        ReaderViewController * __weak this = self;
    [UIView animateWithDuration:.25f
                          delay:.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [this.rollawayToolbar setFrame:CGRectMake(0, -this.toolbarHeight, this.rollawayToolbar.frame.size.width, this.rollawayToolbar.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         this.rollawayToolbar.hidden = YES;
                        [this setNeedsStatusBarAppearanceUpdate];
                     }];
}

-(id)initWithDocumentManager:(MFDocumentManager *)aDocumentManager {
	
	//	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
	//	we used to initialize this class. However, since you probably want to track which document are
	//	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
	//	as long as you pass an instance of it to the superclass initializer.
	    
    self = [super initWithDocumentManager:aDocumentManager];
    if(self) {
        
        self.popoverContentSize = CGSizeMake(372, 650);

		[self setDocumentDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSearchUpdateNotification:)
                                                     name:kNotificationSearchResultAvailable
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSearchGotCancelledNotification:)
                                                     name:kNotificationSearchGotCancelled
                                                   object:nil];
	}
    
	return self;
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskAll;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    // UI images.
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
