//
//  MFHorizontalSlider.m
//  FastPdfKit Sample
//
//  Created by Matteo Gavagnin on 22/12/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFHorizontalSlider.h"
#import <QuartzCore/QuartzCore.h>

@implementation MFHorizontalSlider

@synthesize thumbnailsView, thumbnailsPageControl, thumbnailViewControllers, thumbnailNumbers,viewHeight,sliderHeight;
@synthesize delegate;

- (MFHorizontalSlider *)initWithImages:(NSArray *)images size:(CGSize)size width:(CGFloat)_width height:(CGFloat)_height type:(int)_type andFolderName:(NSString *)_nomecartellapdf{
	thumbWidth = size.width;
	thumbHeight = size.height;
	sliderWidth = _width;
	sliderHeight = _height;
	sliderType = _type;
	thumbnailNumbers = [[NSMutableArray alloc] initWithArray:images];
	thumbFolderName = _nomecartellapdf;
	
	[self.view setFrame:CGRectMake(0,0, sliderWidth, sliderHeight)];
	
	[self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
    unsigned k;
    for (k = 0; k < [thumbnailNumbers count]; k++) {
        [controllers addObject:[NSNull null]];
    }
	
    self.thumbnailViewControllers = controllers;
    [controllers release];
	
	// Create the main view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]]; 
	self.view = contentView;
	[contentView setFrame:CGRectMake(5, 5, sliderWidth, thumbHeight)];	
	[contentView release];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	currentThumbnail = 0;
	
	thumbnailsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sliderWidth, sliderHeight)]; // dimension of view 

	[thumbnailsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[thumbnailsView setDelegate:self];
	thumbnailsView.alwaysBounceVertical = NO;
	thumbnailsView.alwaysBounceHorizontal = NO;
	thumbnailsView.pagingEnabled = NO;
	//create the contentsize of all thumb
    thumbnailsView.contentSize = CGSizeMake(((thumbWidth)* ([thumbnailNumbers count]))+(thumbWidth/3), thumbnailsView.frame.size.height);
    // hide horizontal and vertical scroll indicator
	thumbnailsView.showsHorizontalScrollIndicator = NO;
	[thumbnailsView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    thumbnailsView.showsVerticalScrollIndicator = NO;
	thumbnailsView.scrollsToTop = NO;
	thumbnailsView.alwaysBounceHorizontal = NO;
    thumbnailsView.delegate = self;
	//add the view
	[self.view addSubview:thumbnailsView];
	
	//add a view of the current thumb - on click changePage of pdf
	thumbnailsPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, thumbHeight)];
	thumbnailsPageControl.numberOfPages = [thumbnailNumbers count];
    thumbnailsPageControl.currentPage = currentThumbnail;
	[thumbnailsPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
	
	// update the scroll view to the appropriate page
	CGRect frame = thumbnailsView.frame;
	frame.origin.x = thumbWidth * currentThumbnail;
	frame.origin.y = 0;
	frame.size.width = thumbWidth;
	[thumbnailsView scrollRectToVisible:frame animated:NO];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
	thumbnailsPageControlUsed = NO;
	[thumbnailsPageControl setCurrentPage:currentThumbnail];
	[thumbnailsPageControl updateCurrentPageDisplay];
	
	
	goToPageUsed = NO;
}	

-(void)viewDidLoad{
	[self performSelector:@selector(loadControllers) withObject:nil afterDelay:0.1];
}

- (void)loadControllers{
	[self loadAndUnloadWithPage:currentThumbnail];
}
- (void)loadAndUnloadWithPage:(int)_page{
	if (_page - 10 > 0) {
		for(unsigned i = 0; i < _page - 10; i++){
			[self unloadThumbnailViewWithPage:i];
		}		
	}
	
	//load the thumb display in the screen from page-10 to page+10
	//it allow the fast scrolling of the thumbnail
	
	[self loadThumbnailViewWithPage:_page - 10];
	[self loadThumbnailViewWithPage:_page - 9];
	[self loadThumbnailViewWithPage:_page - 8];
	[self loadThumbnailViewWithPage:_page - 7];
	[self loadThumbnailViewWithPage:_page - 6];
	[self loadThumbnailViewWithPage:_page - 5];
	[self loadThumbnailViewWithPage:_page - 4];
	[self loadThumbnailViewWithPage:_page - 3];
	[self loadThumbnailViewWithPage:_page - 2];
	[self loadThumbnailViewWithPage:_page - 1];
	[self loadThumbnailViewWithPage:_page];
	[self loadThumbnailViewWithPage:_page + 1];
	[self loadThumbnailViewWithPage:_page + 2];
	[self loadThumbnailViewWithPage:_page + 3];
	[self loadThumbnailViewWithPage:_page + 4];
	[self loadThumbnailViewWithPage:_page + 5];
	[self loadThumbnailViewWithPage:_page + 6];
	[self loadThumbnailViewWithPage:_page + 7];
	[self loadThumbnailViewWithPage:_page + 8];
	[self loadThumbnailViewWithPage:_page + 9];
	[self loadThumbnailViewWithPage:_page + 10];

	//unload the thumb out of the screen
	if (_page + 11 < [thumbnailNumbers count]) {
		for(unsigned j = _page + 11; j < [thumbnailNumbers count]; j++){
			[self unloadThumbnailViewWithPage:j];
		}
	}
}

- (void)goToPage:(int)page animated:(BOOL)animated{
	
	//set the currect thumbanail number 
    CGRect frame = thumbnailsView.frame;
    frame.origin.x = thumbWidth * page;
    frame.origin.y = 0;
    [thumbnailsView scrollRectToVisible:frame animated:animated];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
	goToPageUsed = YES;
    thumbnailsPageControlUsed = NO;
	currentThumbnail = page;
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.7];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];		
	}
	
	if(animated){
		[UIView commitAnimations];		
	}
	
}

- (void)changePage:(id)sender{
	//set the current page
	//int page = thumbnailsPageControl.currentPage;
}

- (id) getObjectForPage:(int)page{
	if (page < [thumbnailNumbers count]) {
		return [thumbnailNumbers objectAtIndex:page];
	}
	
	return nil;
}

- (void)thumbTapped:(int)number withObject:(id)_object{
	// at tap on the thumb call delegate method and go to the correct page on pdf	
	[self.delegate didTappedOnPage:number ofType:sliderType withObject:_object];
}

- (void)loadThumbnailViewWithPage:(int)page{
	//set the detail of the page ( img and numbers of page 
	// if page <0 or >of the number of pdf page exit 
	if (page < 0) return;
    if (page >= [thumbnailNumbers count]) return;
	
    MFSliderDetail *controller = [thumbnailViewControllers objectAtIndex:page];
	
    if ((NSNull *)controller == [NSNull null]) {
		//get the path img of the thumb in chache directories
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filename = [NSString stringWithFormat:@"png%d.png",page+1]; //name of the file on disk
		NSString *fullPathToFile = [documentsDirectory stringByAppendingString: @"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:thumbFolderName];
		fullPathToFile = [fullPathToFile stringByAppendingString:@"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:filename];
		
		NSFileManager *filemanager = [[NSFileManager alloc]init];
		if([filemanager fileExistsAtPath: fullPathToFile]){
			controller = [[MFSliderDetail alloc] initWithPageNumber:page andImage:fullPathToFile andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
			[controller.view setAutoresizingMask:UIViewAutoresizingNone];
			controller.delegate = self;
			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
			
			[controller release];
		}else {
			controller = [[MFSliderDetail alloc] initWithPageNumberNoThumb:page andImage:@"png0.png" andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
			[controller.view setAutoresizingMask:UIViewAutoresizingNone];
			controller.delegate = self;
			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
			[controller release];
		}
		[filemanager release];
		
    } else if(controller.temp){
		//get the path img of the thumb in chache directories
		[thumbnailViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filename = [NSString stringWithFormat:@"png%d.png",page+1]; //nome del file su disco, possiamo anche chiamarlo in altro modo
		NSString *fullPathToFile = [documentsDirectory stringByAppendingString: @"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:thumbFolderName];
		fullPathToFile = [fullPathToFile stringByAppendingString:@"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:filename];
		
		NSFileManager *filemanager = [[NSFileManager alloc]init];
		if([filemanager fileExistsAtPath: fullPathToFile]){
			//init the sliderdetail with img and number of page
			controller = [[MFSliderDetail alloc] initWithPageNumber:page andImage:fullPathToFile andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
			controller.delegate = self;
			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
			[controller release];
		}else {
			controller = [[MFSliderDetail alloc] initWithPageNumberNoThumb:page andImage:@"png0.png" andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
			controller.delegate = self;
			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
			[controller release];
		}
		[filemanager release];
	}
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = thumbnailsView.frame;
        frame.origin.x = thumbWidth * page;
		frame.origin.y = 0;
		frame.size.width = thumbWidth;
        controller.view.frame = frame;
		controller.delegate = self;
        [thumbnailsView addSubview:controller.view];
    }
}

- (void)unloadThumbnailViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= [thumbnailNumbers count]) return;
	[thumbnailViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (thumbnailsPageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
    int page = floor((thumbnailsView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    thumbnailsPageControl.currentPage = page;
	
	[self loadAndUnloadWithPage:page];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView{
	 // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
	
	if (thumbnailsPageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	// Qui sta la chiave dello scroll, lavorarci per bene e ottenere il risultato richiesto
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	
	if (page > 0 && page < 800) {
		thumbnailsPageControl.currentPage = page;
		
		currentThumbnail = page;
		
		// update the scroll view to the appropriate page
		CGRect frame = thumbnailsView.frame;
		frame.origin.x = thumbWidth * page;
		frame.origin.y = 0;
		[thumbnailsView scrollRectToVisible:frame animated:YES];
		
		[self loadAndUnloadWithPage:page];
		
		[self.delegate didSelectedPage:page ofType:sliderType withObject:[thumbnailNumbers objectAtIndex:page]];		
	}
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    thumbnailsPageControl.currentPage = page;
	currentThumbnail = page;
	
	// update the scroll view to the appropriate page
    CGRect frame = thumbnailsView.frame;
    frame.origin.x = thumbWidth * page;
	frame.origin.y = 0;
    [thumbnailsView scrollRectToVisible:frame animated:YES];
	
	
    thumbnailsPageControlUsed = NO;
	goToPageUsed = NO;
	
	[self loadAndUnloadWithPage:page];
	
	[self.delegate didSelectedPage:page ofType:sliderType withObject:[thumbnailNumbers objectAtIndex:page]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate{
	
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    thumbnailsPageControl.currentPage = page;
	currentThumbnail = page;
	
	// update the scroll view to the appropriate page
    CGRect frame = thumbnailsView.frame;
    frame.origin.x = thumbWidth * page;
	frame.origin.y = 0;
    [thumbnailsView scrollRectToVisible:frame animated:YES];
	
    thumbnailsPageControlUsed = NO;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
									 // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[thumbnailsView release];
	[thumbnailsPageControl release];
	[thumbnailViewControllers release];
	[thumbnailNumbers release];
    [super dealloc];
}



@end
