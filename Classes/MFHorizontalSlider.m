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

@synthesize thumbnailsView, thumbnailsPageControl, thumbnailViewControllers, thumbnailNumbers;
@synthesize delegate;

- (MFHorizontalSlider *)initWithImages:(NSArray *)images andSize:(CGSize)size andWidth:(CGFloat)_width andType:(int)_type andNomeFile:(NSString *)_nomecartellapdf{
	thumbWidth = size.width;
	thumbHeight = size.height;
	sliderWidth = _width;
	sliderType = _type;
	thumbnailNumbers = [[NSMutableArray alloc] initWithArray:images];
	nomecartellathumb = _nomecartellapdf;
	
	[self.view setFrame:CGRectMake(0, 0, sliderWidth, thumbHeight)];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
	
    for (unsigned k = 0; k < [thumbnailNumbers count]; k++) {
        [controllers addObject:[NSNull null]];
    }
	
    self.thumbnailViewControllers = controllers;
    [controllers release];
	
	// Create the main view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]]; // Fissare dimensioni 
																								   // contentView.backgroundColor = [UIColor grayColor];
	self.view = contentView;
	[contentView setFrame:CGRectMake(0, 0, sliderWidth, thumbHeight)];	
	[contentView release];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	currentThumbnail = 0;

	
	// se la il numero di elementi è meno largo dello schermo posiziono al centro...
	// TODO: adattare per centrare in altezza invece che in larghezza 
	/*
	 
	 float width = sliderWidth;
	 float x = 0;
	 if ([thumbnailNumbers count]*thumbWidth < sliderWidth) {
	 width = [thumbnailNumbers count]*thumbWidth;
	 x = (sliderWidth-width)/2;
	 }
	 */
	thumbnailsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, sliderWidth, thumbHeight+20)]; // Fissare dimensioni
	[thumbnailsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[thumbnailsView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1]];
	[thumbnailsView setDelegate:self];
	thumbnailsView.alwaysBounceVertical = NO;
	thumbnailsView.alwaysBounceHorizontal = NO;
	thumbnailsView.pagingEnabled = NO;
    thumbnailsView.contentSize = CGSizeMake(thumbWidth * ([thumbnailNumbers count]), thumbnailsView.frame.size.height);
    thumbnailsView.showsHorizontalScrollIndicator = NO;
	[thumbnailsView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    thumbnailsView.showsVerticalScrollIndicator = NO;
	
	
    thumbnailsView.scrollsToTop = NO;
	thumbnailsView.alwaysBounceHorizontal = NO;
    thumbnailsView.delegate = self;
	[self.view addSubview:thumbnailsView];
	
	thumbnailsPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, 20)];
	thumbnailsPageControl.numberOfPages = [thumbnailNumbers count];
    thumbnailsPageControl.currentPage = currentThumbnail;
	[thumbnailsPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
	// Qui per mostrare il page controller
	//thumbnailsPageControl.hidden = true;
	
	// [self.view addSubview:thumbnailsPageControl];

	
	
	/*
	for (unsigned j = 0; j < [thumbnailNumbers count]; j++) {
		[self loadThumbnailViewWithPage:j];
    }*/
	
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
	
	
	
	/*
	border = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, thumbHeight)];
	[border setImage:[UIImage imageNamed:@"border.png"]];
	[border setBackgroundColor:[UIColor clearColor]];
	[border setUserInteractionEnabled:NO];
	[border setAlpha:1.0];
	[thumbnailsView addSubview:border];
	[border release];
	*/
	
	goToPageUsed = NO;
	// Aggiungo la maschera sopra le immagini
	//	NSString *thumbName = [NSString stringWithString:[NSString stringWithFormat:@"%@/maschera",[[NSBundle mainBundle] resourcePath]]];
	//	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 410, 320, 50)];
	//	[image setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@.png",thumbName]]];
	//	[image setUserInteractionEnabled:NO];
	//	[self.view addSubview:image];
	//	[image release];
	
}	

-(void)viewDidLoad{
	[self performSelector:@selector(loadControllers) withObject:nil afterDelay:0.1];
}

- (void)loadControllers{
	[self loadAndUnloadWithPage:currentThumbnail];
}
- (void)loadAndUnloadWithPage:(int)_page{
	if (_page - 7 > 0) {
		for(unsigned i = 0; i < _page - 7; i++){
			[self unloadThumbnailViewWithPage:i];
		}		
	}
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
	if (_page + 8 < [thumbnailNumbers count]) {
		for(unsigned j = _page + 8; j < [thumbnailNumbers count]; j++){
			[self unloadThumbnailViewWithPage:j];
		}
	}
}

- (void)goToPage:(int)page animated:(BOOL)animated{
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
	
	// [border setFrame:CGRectMake(0, thumbHeight * page, thumbWidth, thumbHeight)];
	
	if(animated){
		[UIView commitAnimations];		
	}
	
	
	// [[thumbnailViewControllers objectAtIndex:page] setSelected:YES];
}

- (void)changePage:(id)sender{
	int page = thumbnailsPageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
	/*
	NSInteger limiteMinimo = page-6;
	NSInteger limiteMassimo = page+6;
	
	if (limiteMassimo > [thumbnailNumbers count]) {
		limiteMassimo = [thumbnailNumbers count];
	}else {
		limiteMassimo = page+6;
	}
	
	
	if (limiteMinimo<0) {
		limiteMinimo = 0;
	}else {
		limiteMinimo = page-6;
	}
	
	
	for (unsigned i=limiteMinimo; i<limiteMassimo; i++) {
		[self loadThumbnailViewWithPage:i];
	}
	*/
	
	[self loadAndUnloadWithPage:page];
	
	/*[self unloadThumbnailViewWithPage:page - 6];
	[self loadThumbnailViewWithPage:page - 5];
	[self loadThumbnailViewWithPage:page - 4];
	[self loadThumbnailViewWithPage:page - 3];
	[self loadThumbnailViewWithPage:page - 2];
	[self loadThumbnailViewWithPage:page - 1];
	[self loadThumbnailViewWithPage:page];
	[self loadThumbnailViewWithPage:page + 1];
	[self loadThumbnailViewWithPage:page + 2];
	[self loadThumbnailViewWithPage:page + 3];
	[self loadThumbnailViewWithPage:page + 4];
	[self loadThumbnailViewWithPage:page + 5];
	[self unloadThumbnailViewWithPage:page + 6];*/
	
    // update the scroll view to the appropriate page
    CGRect frame = thumbnailsView.frame;
    frame.origin.x = thumbWidth * page;
    frame.origin.y = 0;
    [thumbnailsView scrollRectToVisible:frame animated:YES];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    thumbnailsPageControlUsed = NO;
	currentThumbnail = page;
}

- (id) getObjectForPage:(int)page{
	if (page < [thumbnailNumbers count]) {
		return [thumbnailNumbers objectAtIndex:page];
	}
	
	return nil;
}

- (void)thumbTapped:(int)number withObject:(id)_object{
	// [self goToPage:number];
	
	/*
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
	[border setFrame:CGRectMake(0, thumbHeight * number, thumbWidth, thumbHeight)];
    [UIView commitAnimations];
	*/
	
	[self.delegate didTappedOnPage:number ofType:sliderType withObject:_object];
}

- (void)loadThumbnailViewWithPage:(int)page{
	if (page < 0) return;
    if (page >= [thumbnailNumbers count]) return;
	
    MFSliderDetail *controller = [thumbnailViewControllers objectAtIndex:page];
	
    if ((NSNull *)controller == [NSNull null]) {		
		/*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filename = [NSString stringWithFormat:@"png%d.png",page+1]; //nome del file su disco, possiamo anche chiamarlo in altro modo
		NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:filename];*/
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filename = [NSString stringWithFormat:@"png%d.png",page+1]; //nome del file su disco, possiamo anche chiamarlo in altro modo
		NSString *fullPathToFile = [documentsDirectory stringByAppendingString: @"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:nomecartellathumb];
		fullPathToFile = [fullPathToFile stringByAppendingString:@"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:filename];
		
		// NSLog(@"path orizzonatele %@",fullPathToFile);
		
		NSFileManager *filemanager = [[NSFileManager alloc]init];
		if([filemanager fileExistsAtPath: fullPathToFile]){
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
		
    } else if(controller.temp){
		[thumbnailViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
		/*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filename = [NSString stringWithFormat:@"png%d.png",page+1]; //nome del file su disco, possiamo anche chiamarlo in altro modo
		NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:filename];*/
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filename = [NSString stringWithFormat:@"png%d.png",page+1]; //nome del file su disco, possiamo anche chiamarlo in altro modo
		NSString *fullPathToFile = [documentsDirectory stringByAppendingString: @"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:nomecartellathumb];
		fullPathToFile = [fullPathToFile stringByAppendingString:@"/"];
		fullPathToFile = [fullPathToFile stringByAppendingString:filename];
		
		NSFileManager *filemanager = [[NSFileManager alloc]init];
		if([filemanager fileExistsAtPath: fullPathToFile]){
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
	
	// NSLog(@"Color for page 3 is %i", [delegate getColorForPage:3]);
}

- (void)unloadThumbnailViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= [thumbnailNumbers count]) return;
	[thumbnailViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	//	if 	(!goToPageUsed){
	//		[self hidePopup];
	//		NSLog(@"NO");
	//	}
	//NSLog(@"scrollViewDidScroll");
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
	//	if 	(!goToPageUsed){
	//		[self hidePopup];
	//	}
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
		
		/*
		
		NSInteger limiteMinimo = page-6;
		NSInteger limiteMassimo = page+6;
		
		if (limiteMassimo > [thumbnailNumbers count]) {
			limiteMassimo = [thumbnailNumbers count];
		}else {
			limiteMassimo = page+5;
		}
		
		
		if (limiteMinimo<0) {
			limiteMinimo = 0;
		}else {
			limiteMinimo = page-6;
		}
		
		
		for (unsigned i=limiteMinimo; i<limiteMassimo; i++) {
			[self loadThumbnailViewWithPage:i];
		}
		*/
		/*[self unloadThumbnailViewWithPage:page - 6];
		[self loadThumbnailViewWithPage:page - 5];
		[self loadThumbnailViewWithPage:page - 4];
		[self loadThumbnailViewWithPage:page - 3];
		[self loadThumbnailViewWithPage:page - 2];
		[self loadThumbnailViewWithPage:page - 1];
		[self loadThumbnailViewWithPage:page];
		[self loadThumbnailViewWithPage:page + 1];
		[self loadThumbnailViewWithPage:page + 2];
		[self loadThumbnailViewWithPage:page + 3];
		[self loadThumbnailViewWithPage:page + 4];
		[self loadThumbnailViewWithPage:page + 5];
		[self unloadThumbnailViewWithPage:page + 6];	*/	
		
		[self.delegate didSelectedPage:page ofType:sliderType withObject:[thumbnailNumbers objectAtIndex:page]];		
	}
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
	//	if 	(!goToPageUsed){
	//		[self hidePopup];
	//		NSLog(@"NO");
	//	}
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	
	// Qui sta la chiave dello scroll, lavorarci per bene e ottenere il risultato richiesto
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
	//	if (thumbnailsPageControlUsed) {
	//        // do nothing - the scroll was initiated from the page control, not the user dragging
	//        return;
	//    }
	
	/*
	NSInteger limiteMinimo = page-6;
	NSInteger limiteMassimo = page+6;
	
	if (limiteMassimo > [thumbnailNumbers count]) {
		limiteMassimo = [thumbnailNumbers count];
	}else {
		limiteMassimo = page+6;
	}
	
	
	if (limiteMinimo<0) {
		limiteMinimo = 0;
	}else {
		limiteMinimo = page-6;
	}
	
	
	for (unsigned i=limiteMinimo; i<limiteMassimo; i++) {
		[self loadThumbnailViewWithPage:i];
	}
	*/
	
	[self loadAndUnloadWithPage:page];
	
	/*[self unloadThumbnailViewWithPage:page - 6];
	[self loadThumbnailViewWithPage:page - 5];
	[self loadThumbnailViewWithPage:page - 4];
	[self loadThumbnailViewWithPage:page - 3];
	[self loadThumbnailViewWithPage:page - 2];
	[self loadThumbnailViewWithPage:page - 1];
	[self loadThumbnailViewWithPage:page];
	[self loadThumbnailViewWithPage:page + 1];
	[self loadThumbnailViewWithPage:page + 2];
	[self loadThumbnailViewWithPage:page + 3];
	[self loadThumbnailViewWithPage:page + 4];
	[self loadThumbnailViewWithPage:page + 5];
	[self unloadThumbnailViewWithPage:page + 6];*/
	
	
	[self.delegate didSelectedPage:page ofType:sliderType withObject:[thumbnailNumbers objectAtIndex:page]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate{
	
	//	if 	(!goToPageUsed){
	//		[self hidePopup];
	//		NSLog(@"NO");
	//	}
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	
	// Qui sta la chiave dello scroll, lavorarci per bene e ottenere il risultato richiesto
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    thumbnailsPageControl.currentPage = page;
	currentThumbnail = page;
	
	// update the scroll view to the appropriate page
    CGRect frame = thumbnailsView.frame;
    frame.origin.x = thumbWidth * page;
	frame.origin.y = 0;
    [thumbnailsView scrollRectToVisible:frame animated:YES];
	
    thumbnailsPageControlUsed = NO;
	
	// [self loadAndUnloadWithPage:page];
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
