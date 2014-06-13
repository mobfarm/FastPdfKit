//
//  UIImagesScrollView.h
//  FPKGallerySlide
//

#import <UIKit/UIKit.h>
#import "DDPageControl.h"

@interface UIImagesScrollView : UIView <UIScrollViewDelegate> {
	UIScrollView* scrollView;
	DDPageControl* pageControl;
	
	BOOL pageControlBeingUsed;
    
    NSInteger numberOfPages;
    NSTimer *timerScrollImage;
    
    NSInteger numberOfLoopOk;
    NSInteger numberOfLoop;
}

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) DDPageControl* pageControl;
@property (nonatomic,assign) NSInteger numberOfPages;
@property (nonatomic,assign) NSInteger numberOfLoopOk;
@property (nonatomic,assign) NSInteger numberOfLoop;
@property (nonatomic,retain) NSTimer *timerScrollImage;

- (IBAction)changePage:(id)sender;
- (id)initWithFrame:(CGRect)frame andArrayImg:(NSArray *)image andLoop:(NSInteger)loop;
- (void)invalidateTimer;
@end
