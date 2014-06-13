//
//  TransitionImageView.m
//  Overlay
//
//  Created by Matteo Gavagnin on 10/7/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//


#import "TransitionImageView.h"
#import <QuartzCore/QuartzCore.h>

#define TRANSITION_DURATION 1.5

@implementation TransitionImageView
@synthesize intermediateTransitionView = mIntermediateTransitionView;
@synthesize originalImageViewContainerView = mOriginalImageViewContainerView;
@synthesize page;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        animating = NO;
    }
    return self;
}

-(void)viewWillAppear{
    [UIView beginAnimations:@"AppearAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self setAlpha:1.0];
    [UIView commitAnimations];
}

- (void)dealloc 
{
    [self setOriginalImageViewContainerView:nil];
    [self setIntermediateTransitionView:nil];
}

#pragma mark -
#pragma mark Animation between two images methods

-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation withDuration:(float)time {
    if(!animating){
        if (!inAnimation)
        {
            [self setImage:inNewImage];
        }
        else
        {
            // Create a transparent imageView which will display the transition image.
            
            CGRect rectForNewView = [self frame];
            rectForNewView.origin = CGPointZero;
            UIImageView *intermediateView = [[UIImageView alloc] initWithFrame:rectForNewView];
            [intermediateView setBackgroundColor:[UIColor clearColor]];
            [intermediateView setContentMode:[self contentMode]];
            [intermediateView setClipsToBounds:[self clipsToBounds]];
            [intermediateView setImage:inNewImage];
            
            // Create the image view which will contain original imageView's contents:
            UIImageView *originalView = [[UIImageView alloc] initWithFrame:rectForNewView];
            [originalView setBackgroundColor:[UIColor clearColor]];
            [originalView setContentMode:[self contentMode]];
            [originalView setClipsToBounds:[self clipsToBounds]];
            [originalView setImage:[self image]];
            
            // Remove image from the main imageView and add the originalView as subView to mainView:
            [self setImage:nil];
            [self addSubview:originalView];
            
            // Add the transparent imageView as subview whose dimensions are same as the view which holds it.
            [self addSubview:intermediateView];
            
            // Set alpha value to 0 initially:
            [intermediateView setAlpha:0.0];
            [originalView setAlpha:1.0];
            [self setIntermediateTransitionView:intermediateView];
            [self setOriginalImageViewContainerView:originalView];
            
            // Begin animations:
            [UIView beginAnimations:@"ImageViewTransitions" context:nil];
            [UIView setAnimationDuration:(double)time];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            [[self intermediateTransitionView] setAlpha:1.0];
            [[self originalImageViewContainerView] setAlpha:0.0];
            [UIView commitAnimations];
            animating = YES;
            
        }
    }    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    animating = NO;
    // Reset the alpha of the main imageView
    [self setAlpha:1.0];
    
    // Set the image to the main imageView:
    [self setImage:[[self intermediateTransitionView] image]];
    
    [[self intermediateTransitionView] removeFromSuperview];
    [self setIntermediateTransitionView:nil];
    
    [[self originalImageViewContainerView] removeFromSuperview];
    [self setOriginalImageViewContainerView:nil];
}

@end