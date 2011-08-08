//
//  MFHorizontalSlider.m
//  FastPdfKit Sample
//
//  Created by Matteo Gavagnin on 22/12/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFHorizontalSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "MFSliderDetailVIew.h"

@implementation MFHorizontalSlider

@synthesize thumbnailsScrollView, thumbnailsPageControl, thumbnailViewControllers, thumbnailNumbers,viewHeight,sliderHeight;
@synthesize delegate;


+(NSString *)thumbnailNameForPage:(NSUInteger)page {
    return [NSString stringWithFormat:@"thumb_%d.tmb",page];
}

+(NSString *)thumbnailFolderPathForDocumentId:(NSString *)docId {
    
    NSString * libCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    return [libCacheDir stringByAppendingPathComponent:docId];
}

+(NSString *)thumbnailImagePathForPage:(NSUInteger)page documentId:(NSString *)documentId {
    
    NSString * tmbName = [[self class]thumbnailNameForPage:page];
    NSString * tmbFolder = [[self class]thumbnailFolderPathForDocumentId:documentId];
    
    return [tmbFolder stringByAppendingPathComponent:tmbName];
}

-(id)initWithImages:(NSArray *)images size:(CGSize)size width:(CGFloat)_width height:(CGFloat)_height type:(int)_type andFolderName:(NSString *)_nomecartellapdf{
    
    if((self = [super init])) {
        
        thumbWidth = size.width;
        thumbHeight = size.height;
        sliderWidth = _width;
        sliderHeight = _height;
        sliderType = _type;
        
        thumbnailNumbers = [[NSMutableArray alloc] initWithArray:images];
        
        thumbFolderName = [[MFHorizontalSlider thumbnailFolderPathForDocumentId:_nomecartellapdf]copy];
        
        [self.view setFrame:CGRectMake(0,0, sliderWidth, sliderHeight)];
        
        [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
	    
    }
       return self;
}

CGRect rectForThumbnail(CGFloat width, CGFloat height, int position) {
    
    return CGRectMake(width * (float)position, 0, width, height);
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:[thumbnailNumbers count]];
	
    for (unsigned k = 0; k < [thumbnailNumbers count]; k++) {
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
	
	thumbnailsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sliderWidth, sliderHeight)]; // dimension of view 

	[thumbnailsScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[thumbnailsScrollView setDelegate:self];
	thumbnailsScrollView.alwaysBounceVertical = NO;
	thumbnailsScrollView.alwaysBounceHorizontal = NO;
	thumbnailsScrollView.pagingEnabled = NO;
	
    //create the contentsize of all thumb
    
    thumbnailsScrollView.contentSize = CGSizeMake(((thumbWidth)* ([thumbnailNumbers count]))+(thumbWidth/3), thumbnailsScrollView.frame.size.height);
    
    // hide horizontal and vertical scroll indicator
	
    thumbnailsScrollView.showsHorizontalScrollIndicator = NO;
	[thumbnailsScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    thumbnailsScrollView.showsVerticalScrollIndicator = NO;
	thumbnailsScrollView.scrollsToTop = NO;
	thumbnailsScrollView.alwaysBounceHorizontal = NO;
    thumbnailsScrollView.delegate = self;
	
    //add the view
	[self.view addSubview:thumbnailsScrollView];
	
	//add a view of the current thumb - on click changePage of pdf
	thumbnailsPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, thumbHeight)];
	thumbnailsPageControl.numberOfPages = [thumbnailNumbers count];
    thumbnailsPageControl.currentPage = currentThumbnail;
	[thumbnailsPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
	
	// update the scroll view to the appropriate page
//	CGRect frame = thumbnailsScrollView.frame;
//	frame.origin.x = thumbWidth * currentThumbnail;
//	frame.origin.y = 0;
//	frame.size.width = thumbWidth;
	[thumbnailsScrollView scrollRectToVisible:rectForThumbnail(thumbWidth, thumbHeight, currentThumbnail) animated:NO];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
	
    thumbnailsPageControlUsed = NO;
    goToPageUsed = NO;
    
	[thumbnailsPageControl setCurrentPage:currentThumbnail];
	[thumbnailsPageControl updateCurrentPageDisplay];
}	

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    /*for(unsigned i = 0; i < [thumbnailNumbers count]; i++){
        [self loadThumbnailViewWithPage:i];
    }*/
	[self performSelector:@selector(loadControllers) withObject:nil afterDelay:0.0];
	//[self performSelector:@selector(loadControllers) withObject:nil afterDelay:2.0];
}

- (void)loadControllers{
	[self loadAndUnloadWithPage:currentThumbnail];
}

- (void)loadAndUnloadWithPage:(int)aPage{
    
	if (aPage - 10 > 0) {
		for(unsigned i = 0; i < aPage - 10; i++){
			[self resetThumbnailViewWithPage:i];
		}		
	}
	
	//load the thumb display in the screen from page-10 to page+10
	//it allow the fast scrolling of the thumbnail
    [self refreshThumbnailViewWithPage:aPage - 9];
    [self refreshThumbnailViewWithPage:aPage - 8];
    [self refreshThumbnailViewWithPage:aPage - 7];
    [self refreshThumbnailViewWithPage:aPage - 6];
    [self refreshThumbnailViewWithPage:aPage - 5];
    [self refreshThumbnailViewWithPage:aPage - 4];
    [self refreshThumbnailViewWithPage:aPage - 3];
    [self refreshThumbnailViewWithPage:aPage - 2];
    [self refreshThumbnailViewWithPage:aPage - 1];
	
	[self refreshThumbnailViewWithPage:aPage];
    
	[self refreshThumbnailViewWithPage:aPage + 1];
	[self refreshThumbnailViewWithPage:aPage + 2];
	[self refreshThumbnailViewWithPage:aPage + 3];
	[self refreshThumbnailViewWithPage:aPage + 4];
	[self refreshThumbnailViewWithPage:aPage + 5];
    [self refreshThumbnailViewWithPage:aPage + 6];
    [self refreshThumbnailViewWithPage:aPage + 7];
	[self refreshThumbnailViewWithPage:aPage + 8];
	[self refreshThumbnailViewWithPage:aPage + 9];
	[self refreshThumbnailViewWithPage:aPage + 10];
    
	//unload the thumb out of the screen
	if (aPage + 11 < [thumbnailNumbers count]) {
		for(unsigned j = aPage + 11; j < [thumbnailNumbers count]; j++){
			[self resetThumbnailViewWithPage:j];
		}
	}
}

- (void)goToPage:(int)page animated:(BOOL)animated{
	
	//set the currect thumbanail number 
    CGRect frame = thumbnailsScrollView.frame;
    frame.origin.x = thumbWidth * page;
    frame.origin.y = 0;
    [thumbnailsScrollView scrollRectToVisible:frame animated:animated];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
	goToPageUsed = YES;
    thumbnailsPageControlUsed = NO;
	currentThumbnail = page;
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.7];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];		
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

CGRect rectForThumbnailView(int pos, CGFloat width, CGFloat height) {
    
    return CGRectMake(width * pos, 0, width, height);
}

- (void)refreshThumbnailViewWithPage:(int)page {
    
    NSString * fileName = nil;
    NSString * fullPathToFile = nil;
    MFSliderDetailVIew * detailView = nil;
    NSFileManager * fileManager = nil;
    
	//set the detail of the page ( img and numbers of page 
	// if page <0 or >of the number of pdf page exit 
	if (page < 0) return;
    if (page >= [thumbnailNumbers count]) return;
	
    detailView = [thumbnailViewControllers objectAtIndex:page];
    
    if([detailView isKindOfClass:[NSNull class]]) {
        
        CGRect detailViewFrame = rectForThumbnail(thumbWidth, thumbHeight, page);
        
        detailView = [[MFSliderDetailVIew alloc]initWithFrame:detailViewFrame];
        detailView.pageNumber = [NSNumber numberWithInt:page+1];    
        detailView.delegate = self;
        
        [thumbnailsScrollView addSubview:detailView];
        
        [thumbnailViewControllers replaceObjectAtIndex:page withObject:detailView];
        
        [detailView release];
    }
    
    fileManager = [NSFileManager defaultManager];
    fileName = [[self class]thumbnailNameForPage:page+1]; //name of the file on disk
    fullPathToFile = [thumbFolderName stringByAppendingPathComponent:fileName];
    
    if((![detailView.thumbnailImagePath isEqualToString:fullPathToFile])&&([fileManager fileExistsAtPath:fullPathToFile])) {
        detailView.thumbnailImagePath = fullPathToFile;
    }
    
//    MFSliderDetail *controller = [thumbnailViewControllers objectAtIndex:page];
//    
//	NSFileManager *filemanager = [NSFileManager defaultManager];
//    
//    if ((NSNull *)controller == [NSNull null]) {
//        
//		//get the path img of the thumb in chache directories
////		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
////		NSString *documentsDirectory = [paths objectAtIndex:0];
////		
//        fileName = [NSString stringWithFormat:@"png%d.jpg",page+1]; //name of the file on disk
//		fullPathToFile = [thumbFolderName stringByAppendingPathComponent:fileName];
//		
//        if([filemanager fileExistsAtPath: fullPathToFile]){
//            
//			controller = [[MFSliderDetail alloc] initWithPageNumber:page andImage:fullPathToFile andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
//			controller.delegate = self;
//			[controller.view setAutoresizingMask:UIViewAutoresizingNone];
//			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
//			
//			[controller release];
//            
//		} else {
//            
//			controller = [[MFSliderDetail alloc] initWithPageNumberNoThumb:page andImage:@"png0.png" andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
//			controller.delegate = self;
//			[controller.view setAutoresizingMask:UIViewAutoresizingNone];
//			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
//			[controller release];
//		
//        }
//        
//		//[filemanager release];
//		
//    } else if(controller.temp){
//		//get the path img of the thumb in chache directories
//		[thumbnailViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
//		
//        fileName = [NSString stringWithFormat:@"png%d.jpg",page+1]; //name of the file on disk
//		fullPathToFile = [thumbFolderName stringByAppendingPathComponent:fileName];
//		
//		//NSFileManager *filemanager = [[NSFileManager alloc]init];
//		if([filemanager fileExistsAtPath: fullPathToFile]){
//			//init the sliderdetail with img and number of page
//			controller = [[MFSliderDetail alloc] initWithPageNumber:page andImage:fullPathToFile andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
//			controller.delegate = self;
//			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
//			[controller release];
//		}else {
//			controller = [[MFSliderDetail alloc] initWithPageNumberNoThumb:page andImage:@"png0.png" andSize:CGSizeMake(thumbWidth, thumbHeight) andObject:[thumbnailNumbers objectAtIndex:page] andDataSource:self.delegate];
//			controller.delegate = self;
//			[thumbnailViewControllers replaceObjectAtIndex:page withObject:controller];
//			[controller release];
//		}
//		//[filemanager release];
//	}
//    
//    // add the controller's view to the scroll view
//    if (nil == controller.view.superview) {
//        
//        CGRect frame = thumbnailsScrollView.frame;
//        frame.origin.x = thumbWidth * page;
//		frame.origin.y = 0;
//		frame.size.width = thumbWidth;
//        controller.view.frame = frame;
//		controller.delegate = self;
//        [thumbnailsScrollView addSubview:controller.view];
//        
//    }
}

- (void)resetThumbnailViewWithPage:(int)page {
    
    id obj = nil;
    
    if ((page < 0) || (page >= [thumbnailNumbers count])) 
        return;
    
    obj = [thumbnailViewControllers objectAtIndex:page];
    
    if([obj isKindOfClass:[MFSliderDetailVIew class]]) {
        
        MFSliderDetailVIew * detail = (MFSliderDetailVIew *)obj;
        
        [detail removeFromSuperview];
        
        [thumbnailViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];    
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
    if (thumbnailsPageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
    int page = floor((thumbnailsScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if(page!=thumbnailsPageControl.currentPage) {
        thumbnailsPageControl.currentPage = page;
        [self loadAndUnloadWithPage:page];    
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView{
    
    //NSLog(@"%@",NSStringFromSelector(@selector(scrollViewDidEndScrollingAnimation:)));
    
	 // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
	
	if (thumbnailsPageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	
	if (page > 0 && page < 800) { // Why this arbitrary upper limit?
        
		thumbnailsPageControl.currentPage = page;
		
		currentThumbnail = page;
		
		// update the scroll view to the appropriate page
		CGRect frame = thumbnailsScrollView.frame;
		frame.origin.x = thumbWidth * page;
		frame.origin.y = 0;
		[thumbnailsScrollView scrollRectToVisible:frame animated:YES];
		
		[self loadAndUnloadWithPage:page];
		
		[self.delegate didSelectedPage:page ofType:sliderType withObject:[thumbnailNumbers objectAtIndex:page]];		
	}
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
//    NSLog(@"%@",NSStringFromSelector(@selector(scrollViewDidEndDecelerating:)));
    
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    thumbnailsPageControl.currentPage = page;
	currentThumbnail = page;
	
	// update the scroll view to the appropriate page
    CGRect frame = thumbnailsScrollView.frame;
    frame.origin.x = thumbWidth * page;
	frame.origin.y = 0;
    [thumbnailsScrollView scrollRectToVisible:frame animated:YES];
	
	
    thumbnailsPageControlUsed = NO;
	goToPageUsed = NO;
	
	[self loadAndUnloadWithPage:page];
	
	[self.delegate didSelectedPage:page ofType:sliderType withObject:[thumbnailNumbers objectAtIndex:page]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate{
	
//    NSLog(@"%@",NSStringFromSelector(@selector(scrollViewDidEndDragging:willDecelerate:)));
    
    
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = thumbWidth;
	
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    thumbnailsPageControl.currentPage = page;
	currentThumbnail = page;
	
	// update the scroll view to the appropriate page
    CGRect frame = thumbnailsScrollView.frame;
    frame.origin.x = thumbWidth * page;
	frame.origin.y = 0;
    [thumbnailsScrollView scrollRectToVisible:frame animated:YES];
	
    thumbnailsPageControlUsed = NO;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
									 // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[thumbnailsScrollView release];
	[thumbnailsPageControl release];
	[thumbnailViewControllers release];
	[thumbnailNumbers release];
    //[fileManager release], fileManager = nil;
    [super dealloc];
}



@end
