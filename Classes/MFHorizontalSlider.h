//
//  MFHorizontalSlider.h
//  FastPdfKit Sample
//
//  Created by Matteo Gavagnin on 22/12/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFSliderDetail.h"

@protocol MFSliderDelegate <NSObject>
@required
- (void)didSelectedPage:(int)number ofType:(int)type withObject:(id)object;
- (void)didTappedOnPage:(int)number ofType:(int)type withObject:(id)object;
@end

@interface MFHorizontalSlider : UIViewController <UIScrollViewDelegate, MFSliderDetailDelegate> {
	UIScrollView *thumbnailsView;
	UIPageControl *thumbnailsPageControl;
	NSMutableArray *thumbnailViewControllers;
	NSMutableArray *thumbnailNumbers;
	BOOL thumbnailsPageControlUsed;
	CGPoint startTouchPosition;
	NSString *dirString;
	int currentThumbnail;
	CGFloat thumbWidth;
	CGFloat thumbHeight;
	CGFloat sliderWidth;
	CGFloat viewHeight;
	BOOL goToPageUsed;
	id delegate;
	
	UIImageView *border;
	int sliderType;
	NSString *nomecartellathumb;
}
@property (nonatomic, retain) UIScrollView *thumbnailsView;
@property (nonatomic, retain) UIPageControl *thumbnailsPageControl;
@property (nonatomic, retain) NSMutableArray *thumbnailViewControllers;
@property (nonatomic, retain) NSMutableArray *thumbnailNumbers;
@property (nonatomic, assign) id <MFSliderDelegate> delegate;
@property (nonatomic, assign) CGFloat viewHeight;


- (MFHorizontalSlider *)initWithImages:(NSArray *)images andSize:(CGSize)size andWidth:(CGFloat)_width andType:(int)_type andNomeFile:(NSString *)_nomecartellapdf;
- (void)goToPage:(int)page animated:(BOOL)animated;
- (void)thumbTapped:(int)number withObject:(id)object;

- (void)changePage:(id)sender;
- (void)loadThumbnailViewWithPage:(int)page;
- (void)unloadThumbnailViewWithPage:(int)page;

- (id) getObjectForPage:(int)page;

- (void)loadAndUnloadWithPage:(int)_page;

@end
