//
//  TransitionImageView.h
//  Overlay
//
//  Created by Matteo Gavagnin on 10/7/11.
//  Copyright (c) 2011 Mobfarm. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface TransitionImageView : UIImageView
{
    UIImageView *mOriginalImageViewContainerView;
    UIImageView *mIntermediateTransitionView;
    BOOL animating;
    int page;
}
@property (nonatomic, retain) UIImageView *originalImageViewContainerView;
@property (nonatomic, retain) UIImageView *intermediateTransitionView;
@property (nonatomic) int page;
#pragma mark -
#pragma mark Animation methods
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation withDuration:(float)time;
-(void)viewWillAppear;
@end