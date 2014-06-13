//
//  FPKDraggableImageView.m
//  Overlay
//
//  Created by Matteo Gavagnin on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FPKDraggableImageView.h"

@implementation FPKDraggableImageView
@synthesize intermediateTransitionView = mIntermediateTransitionView;
@synthesize originalImageViewContainerView = mOriginalImageViewContainerView;
@synthesize page;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        animating = NO;
        start = self.center;
        
        self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
		self.exclusiveTouch = NO;
        
    }
    return self;
}

- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
	{
        
        animating = NO;
        start = self.center;
        
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
		self.exclusiveTouch = NO;
	}
	return self;
}

-(void)setStartPosition:(CGPoint)center{
    start = center;
    originalSize = self.frame.size;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc 
{
    if (touchBeginPoints) CFRelease(touchBeginPoints);
}

#pragma mark -
#pragma mark Animation methods
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

#pragma Multitouch image drag

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if( [touches count] == 1 ) {
        
        float difx = [[touches anyObject] locationInView:self].x - [[touches anyObject] previousLocationInView:self].x;
        
        float dify = [[touches anyObject] locationInView:self].y - [[touches anyObject] previousLocationInView:self].y;
        
        
        
        CGAffineTransform newTransform1 = CGAffineTransformTranslate(self.transform, difx, dify);
        
        self.transform = newTransform1;
        
    } else     if( [touches count] == 2 ) {
        
        int prevmidx = ([[[touches allObjects] objectAtIndex:0] previousLocationInView:self].x + [[[touches allObjects] objectAtIndex:1] previousLocationInView:self].x) / 2;
        
        int prevmidy = ([[[touches allObjects] objectAtIndex:0] previousLocationInView:self].y + [[[touches allObjects] objectAtIndex:1] previousLocationInView:self].y) / 2;
        
        int curmidx = ([[[touches allObjects] objectAtIndex:0] locationInView:self].x + [[[touches allObjects] objectAtIndex:1] locationInView:self].x) / 2;
        
        int curmidy = ([[[touches allObjects] objectAtIndex:0] locationInView:self].y + [[[touches allObjects] objectAtIndex:1] locationInView:self].y) / 2;
        
        int difx = curmidx - prevmidx;
        
        int dify = curmidy - prevmidy;
        
        
        
        CGPoint prevPoint1 = [[[touches allObjects] objectAtIndex:0] previousLocationInView:self];
        
        CGPoint prevPoint2 = [[[touches allObjects] objectAtIndex:1] previousLocationInView:self];
        
        CGPoint curPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        
        CGPoint curPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self];
        
        float prevDistance = [self distanceBetweenPoint1:prevPoint1 andPoint2:prevPoint2];
        
        float newDistance = [self distanceBetweenPoint1:curPoint1 andPoint2:curPoint2];
        
        float sizeDifference = (newDistance / prevDistance);
        
        
        
        CGAffineTransform newTransform1 = CGAffineTransformTranslate(self.transform, difx, dify);
        
        self.transform = newTransform1;
        
        
        
        CGAffineTransform newTransform2 = CGAffineTransformScale(self.transform, sizeDifference, sizeDifference);
        
        self.transform = newTransform2;
        
        
        
        
        
        float prevAngle = [self angleBetweenPoint1:prevPoint1 andPoint2:prevPoint2];
        
        float curAngle = [self angleBetweenPoint1:curPoint1 andPoint2:curPoint2];
        
        float angleDifference = curAngle - prevAngle;
        
        
        
        CGAffineTransform newTransform3 = CGAffineTransformRotate(self.transform, angleDifference);
        
        self.transform = newTransform3;
        
    }
    
}



- (NSInteger)distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
    
    CGFloat deltaX = fabsf(point1.x - point2.x);
    
    CGFloat deltaY = fabsf(point1.y - point2.y);
    
    CGFloat distance = sqrt((deltaY*deltaY)+(deltaX*deltaX));
    
    return distance;
    
}



- (CGFloat)angleBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2{ 
    
    CGFloat deltaY = point1.y - point2.y;
    
    CGFloat deltaX = point1.x - point2.x;
    
    CGFloat angle = atan2(deltaY, deltaX);
    
    return angle;
    
}


// Finish by removing touches, handling double-tap requests
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event  {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.transform = CGAffineTransformIdentity;
    self.center = start;
    [UIView commitAnimations];
}

// Redirect cancel to ended
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self touchesEnded:touches withEvent:event];
}



@end