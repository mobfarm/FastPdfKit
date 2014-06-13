//
//  TransitionGalleryView.h
//  Overlay
//
//  Created by Matteo Gavagnin on 10/22/11.
//  Copyright (c) 2011 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionGalleryView : UIImageView{
    
    UIImageView *mOriginalImageViewContainerView;
    UIImageView *mIntermediateTransitionView;
    BOOL animating;
    int page;
    
    NSArray *images;
    
    NSTimer *fadeTimer;
    int index;
    
    float duration;
    
}
@property (nonatomic, retain) UIImageView *originalImageViewContainerView;
@property (nonatomic, retain) UIImageView *intermediateTransitionView;
@property (nonatomic) float duration;
@property (nonatomic, retain) NSArray *images;
#pragma mark -
#pragma mark Animation methods
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation withDuration:(float)time;
-(void)startFadeAnimation;
-(void)nextImage;
@end
