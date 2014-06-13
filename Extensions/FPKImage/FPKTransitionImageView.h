//
//  FPKTransitionImageView.h
//  Overlay
//
//  Created by Matteo Gavagnin on 10/7/11.
//  Copyright (c) 2011 Mobfarm. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol FPKTransitionImageViewDelegate;

@interface FPKTransitionImageView : UIImageView <UIGestureRecognizerDelegate>
{
    UIImageView * _originalImageViewContainerView;
    UIImageView * _intermediateTransitionView;
    BOOL _animating;
    
    CGPoint _touch1;
    CGPoint _touch2;
    CGPoint _start;
    
    float _distance0;
    
    BOOL _open;
    BOOL _goingToOpen;
    
    float _actualScale;
    CGRect _rect0;
}

@property (nonatomic, strong) UIImageView *originalImageViewContainerView;
@property (nonatomic, strong) UIImageView *intermediateTransitionView;
@property (nonatomic, readwrite) int page;
@property (nonatomic, weak) id<FPKTransitionImageViewDelegate> delegate;

#pragma mark -
#pragma mark Animation methods
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation withDuration:(float)time;
-(void)setStartPosition:(CGPoint)center;
-(void)viewWillAppear;
@end

@protocol FPKTransitionImageViewDelegate

-(void)setScrollLock:(BOOL)lockOrNot;

@end