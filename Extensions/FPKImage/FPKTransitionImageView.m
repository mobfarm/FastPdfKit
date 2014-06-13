//
//  FPKTransitionImageView.m
//  Overlay
//
//  Created by Matteo Gavagnin on 10/7/11.
//  Copyright (c) 2011 MobFarm. All rights reserved.
//


#import "FPKTransitionImageView.h"
#import <QuartzCore/QuartzCore.h>

#define TRANSITION_DURATION 1.5

@implementation FPKTransitionImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        _animating = NO;
        _start = self.center;
        // self.alpha = 0;
        _rect0 = frame;
    }
    return self;
}

#pragma mark -
#pragma mark === Utility methods  ===
#pragma mark

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

// display a menu with a single item to allow the piece's transform to be reset
- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Reset" action:@selector(resetPiece:)];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
    }
}

// animate back to the default anchor point and transform
- (void)resetPiece:(UIMenuController *)controller {
    CGPoint locationInSuperview = [self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:[self superview]];
    
    [[self layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self setCenter:locationInSuperview];
    
    [UIView beginAnimations:nil context:nil];
    [self setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"Image Should Receive Touch");
    
    [_delegate setScrollLock:YES];
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != self && otherGestureRecognizer.view != self)
        return NO;
    
    return YES;
}

-(void)setStartPosition:(CGPoint)center{
    _start = center;
    // self.alpha = 0.0;    
    _open = NO;
    _actualScale = 1.0;
    _rect0 = self.frame;
    [self setBackgroundColor:[UIColor whiteColor]];
    
     UIGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
    pinch.delegate = self;
     [self addGestureRecognizer:pinch];

     
     UIGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    pan.delegate = self;
     [self addGestureRecognizer:pan];
    
     UIGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateFrom:)];
    rotate.delegate = self;
     [self addGestureRecognizer:rotate];
}

-(void)viewWillAppear{
    [UIView beginAnimations:@"AppearAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self setAlpha:1.0];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)handlePanFrom:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(!open){
        [self.superview bringSubviewToFront:self];
        [_delegate setScrollLock:YES];
        
        UIView *piece = [gestureRecognizer view];
        
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
            [_delegate setScrollLock:NO];
            if(!_goingToOpen){
                /*
                 NSLog(@"Not going to open");
                 [delegate setScrollLock:NO];
                 actualScale = 1.0;
                 open = NO;
                 [delegate setScrollLock:NO];
                 [UIView beginAnimations:nil context:NULL];
                 [UIView setAnimationDuration:0.3];
                 self.layer.anchorPoint = CGPointMake(0.5, 0.5);            
                 self.transform = CGAffineTransformIdentity;
                 self.center = start;
                 [UIView commitAnimations]; 
                 */
            }
        }
    }
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)handleRotateFrom:(UIRotationGestureRecognizer *)gestureRecognizer
{
    
    [self.superview bringSubviewToFront:self];
    [_delegate setScrollLock:YES];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        /*
         if(!open){
         actualScale = 1.0;
         open = NO;
         [delegate setScrollLock:NO];
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:0.3];
         self.layer.anchorPoint = CGPointMake(0.5, 0.5);            
         self.transform = CGAffineTransformIdentity;
         self.center = start;
         [UIView commitAnimations];        
         }
         */
        [_delegate setScrollLock:NO];
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)handlePinchFrom:(UIPinchGestureRecognizer *)gestureRecognizer
{
    
    [self.superview bringSubviewToFront:self];
    [_delegate setScrollLock:YES];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        _actualScale += [gestureRecognizer scale];
        [gestureRecognizer setScale:1];
    } else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        if (!open) {
            _goingToOpen = YES;
            _open = YES;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            
            self.layer.anchorPoint = CGPointMake(0.5, 0.5);
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            CGPoint center = CGPointMake(ceil(screenSize.width/2), ceil((screenSize.height-20.0)/2));
            self.center = center;	
            
            // double angleFromOrigin = atan2(self.transform.b, self.transform.a);
            // double scaleFromOrigin = sqrt(pow(self.transform.a,2.0)+pow(self.transform.c,2.0));
            
            // NSLog(@"Angle: %f", angleFromOrigin);
            // NSLog(@"Scale: %f", scaleFromOrigin);
            
            float scaleW = [UIScreen mainScreen].bounds.size.width / _rect0.size.width;
            // TODO: e se non c'è la StatusBar
            float scaleH = ([UIScreen mainScreen].bounds.size.height -20.0) / _rect0.size.height;
            
            float scale = scaleH;
            if (scaleW > scaleH)
                scale = scaleW;
            
            /*
             NSLog(@"ZoomScale: %f", [delegate zoomScale]);
             NSLog(@"Scale: %f", scale);            
             scale -= [delegate zoomScale] - 1;
             NSLog(@"Scale: %f", scale);
             */
            
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
            self.transform = CGAffineTransformRotate(self.transform, 0.0);
            [UIView commitAnimations];        
            
        } else {
            _actualScale = 1.0;
            _open = NO;
            [_delegate setScrollLock:NO];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            self.layer.anchorPoint = CGPointMake(0.5, 0.5);            
            self.transform = CGAffineTransformIdentity;
            self.center = _start;
            [UIView commitAnimations];        
        }
        
        [_delegate setScrollLock:NO];
    }
}

#pragma mark -
#pragma mark Animation between two images methods

-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation withDuration:(float)time {
    if(!_animating){
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
            _animating = YES;
        }
    }    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    _animating = NO;
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