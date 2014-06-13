//
//  FPKDraggableImageView.h
//  Overlay
//
//  Created by Matteo Gavagnin on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FPKDraggableImageView : UIImageView 
{
    UIImageView *mOriginalImageViewContainerView;
    UIImageView *mIntermediateTransitionView;
    BOOL animating;
    int page;
    
    CGPoint start;
    
    CGPoint startLocation;
	CGSize originalSize;
	CGAffineTransform originalTransform;
    CFMutableDictionaryRef touchBeginPoints;
}
@property (nonatomic, retain) UIImageView *originalImageViewContainerView;
@property (nonatomic, retain) UIImageView *intermediateTransitionView;
@property (nonatomic) int page;
#pragma mark -
#pragma mark Animation methods
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation withDuration:(float)time;
-(void)setStartPosition:(CGPoint)center;

- (NSInteger)distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;
- (CGFloat)angleBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;
@end