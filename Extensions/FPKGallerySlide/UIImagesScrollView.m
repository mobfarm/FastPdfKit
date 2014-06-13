//
//  UIImagesScrollView.m
//  FPKGallerySlide
//

#import "UIImagesScrollView.h"

@implementation UIImagesScrollView

@synthesize scrollView, pageControl;
@synthesize numberOfPages,numberOfLoopOk,numberOfLoop;
@synthesize timerScrollImage;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (id)initWithFrame:(CGRect)frame andArrayImg:(NSArray *)image andLoop:(NSInteger)loop{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        
        numberOfPages = image.count;
        
        pageControlBeingUsed = NO;
        
        scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:scrollView];
        
        [scrollView setScrollEnabled:YES];
        [scrollView setPagingEnabled:YES];
        
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        
        [scrollView setBackgroundColor:[UIColor whiteColor]];
        
        [scrollView setDelegate:self];
        
        
        pageControl = [[DDPageControl alloc] init] ;
        [pageControl setCenter:CGPointMake(scrollView.frame.size.width/2, scrollView.bounds.size.height-22)];
        [pageControl setNumberOfPages: image.count] ;
        [pageControl setCurrentPage: 0] ;
        [pageControl addTarget: self action: @selector(changePage:) forControlEvents: UIControlEventValueChanged] ;
        [pageControl setDefersCurrentPageDisplay: YES] ;
        [pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
        [pageControl setOnColor: [UIColor colorWithWhite: 0.9f alpha: 1.0f]] ;
        [pageControl setOffColor: [UIColor colorWithWhite: 0.7f alpha: 1.0f]] ;
        [pageControl setIndicatorDiameter: 10.0f] ;
        [pageControl setIndicatorSpace: 10.0f] ;
        
        /*pageControl = [[DDPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height-22, frame.size.width, 22)];
         
         [pageControl setNumberOfPages:image.count];
         
         [pageControl setBackgroundColor:[UIColor blackColor]];
         
         [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
         */
        [self addSubview:pageControl]; 
        
        for (int i = 0; i < image.count; i++) {
            CGRect frame;
            frame.origin.x = self.scrollView.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = self.scrollView.frame.size;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            [imageView setImage:[image objectAtIndex:i]];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [self.scrollView addSubview:imageView];
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * image.count, self.scrollView.frame.size.height);
        self.scrollView.bounces = NO;
        
        if (loop>0) {
            numberOfLoop = loop*image.count;
            numberOfLoopOk = 1;
            timerScrollImage = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(autoScrollImage:) userInfo:nil repeats:YES];
        } else if (loop == -1) {
            numberOfLoop = -1;
            numberOfLoopOk = 1;
            timerScrollImage = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(autoScrollImage:) userInfo:nil repeats:YES];
        }

    }
    
    	
	//self.pageControl.currentPage = 0;
	//self.pageControl.numberOfPages = image.count;
    
    return self;
}

- (void)invalidateTimer{
    if (timerScrollImage) {
        [timerScrollImage invalidate];
    }
}

-(void)autoScrollImage:(id)sender{
    
    numberOfLoopOk++;
    
    if (numberOfLoopOk>numberOfLoop && numberOfLoop != -1) {
        [timerScrollImage invalidate];
        timerScrollImage=nil;
    }

    CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    
    NSInteger nearestNumber = lround(fractionalPage) ;
    
    if ((nearestNumber+1)==numberOfPages) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        fractionalPage =(nearestNumber*pageWidth)+pageWidth;
        
        [self.scrollView setContentOffset:CGPointMake(fractionalPage, 0) animated:YES];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
	/*if (!pageControlBeingUsed) {
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
	}*/
    CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	
	if (pageControl.currentPage != nearestNumber)
	{
		pageControl.currentPage = nearestNumber ;
		
		// if we are dragging, we want to update the page control directly during the drag
		if (scrollView.dragging){
            
            if (timerScrollImage) {
                [timerScrollImage invalidate];
                timerScrollImage = nil;
            }
        
            
        }
        
        [pageControl updateCurrentPageDisplay] ;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
    [pageControl updateCurrentPageDisplay] ;
}

- (IBAction)changePage:(id)sender {
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
    pageControlBeingUsed = YES;
    
    DDPageControl *thePageControl = (DDPageControl *)sender ;
	
	// we need to scroll to the new index
	[scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * thePageControl.currentPage, scrollView.contentOffset.y) animated: YES] ;
    
    [pageControl updateCurrentPageDisplay] ;
    
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.scrollView = nil;
	self.pageControl = nil;
    if (timerScrollImage) {
        [timerScrollImage invalidate];
        timerScrollImage = nil;
    }
}

@end
