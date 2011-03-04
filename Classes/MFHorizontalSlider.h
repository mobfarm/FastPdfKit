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
	CGFloat sliderHeight;
	CGFloat viewHeight;
	BOOL goToPageUsed;
	id delegate;
	
	UIImageView *border;
	int sliderType;
	NSString *thumbFolderName;
}
@property (nonatomic, retain) UIScrollView *thumbnailsView;
@property (nonatomic, retain) UIPageControl *thumbnailsPageControl;
@property (nonatomic, retain) NSMutableArray *thumbnailViewControllers;
@property (nonatomic, retain) NSMutableArray *thumbnailNumbers;
@property (nonatomic, assign) id <MFSliderDelegate> delegate;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat sliderHeight;


- (MFHorizontalSlider *)initWithImages:(NSArray *)images size:(CGSize)size width:(CGFloat)_width height:(CGFloat)_height type:(int)_type andFolderName:(NSString *)_nomecartellapdf;
- (void)goToPage:(int)page animated:(BOOL)animated;
- (void)thumbTapped:(int)number withObject:(id)object;

- (void)changePage:(id)sender;
- (void)loadThumbnailViewWithPage:(int)page;
- (void)unloadThumbnailViewWithPage:(int)page;

- (id) getObjectForPage:(int)page;

- (void)loadAndUnloadWithPage:(int)_page;

@end
