//
//  DDSocialDialog.m
//
//  Created by digdog on 6/6/10.
//  Copyright 2010 Ching-Lan 'digdog' HUANG and digdog software. All rights reserved.
//  http://digdog.tumblr.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "DDSocialDialog.h"
#import <UIKit/UIKit.h>

static CGFloat kDDSocialDialogBorderWidth = 10;
static CGFloat kDDSocialDialogTransitionDuration = 0.3;
static CGFloat kDDSocialDialogTitleMarginX = 8.0;
static CGFloat kDDSocialDialogTitleMarginY = 4.0;
static CGFloat kDDSocialDialogPadding = 10;

@interface DDSocialDialog () 

@end

@implementation DDSocialDialog

@synthesize theme = theme_;
@synthesize titleLabel = titleLabel_;
@synthesize contentView = contentView_;
@synthesize dialogDelegate = dialogDelegate_;

- (id)initWithFrame:(CGRect)frame andOriginalFrame:(CGRect)original theme:(DDSocialDialogTheme)theme {
	
    if ((self = [super initWithFrame:CGRectZero])) {
        // Initialization code
		defaultFrameSize_ = frame.size;
        originalFrame_ = original;
		theme_ = theme;
		
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeRedraw;
		
        UIColor* color = [UIColor colorWithRed:0.0/255 green:184.0/255 blue:216.0/255 alpha:1];
        closeButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton_ setTitle:@"x" forState:UIControlStateNormal];
        [closeButton_ setTitleColor:color forState:UIControlStateNormal];
        [closeButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [closeButton_ addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        closeButton_.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        closeButton_.showsTouchWhenHighlighted = YES;
        closeButton_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:closeButton_];
        
        CGFloat titleLabelFontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 18 : 14;		
		titleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel_.text = NSStringFromClass([self class]);
		titleLabel_.backgroundColor = [UIColor clearColor];
		titleLabel_.textColor = [UIColor whiteColor];
		titleLabel_.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
		titleLabel_.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
		[self addSubview:titleLabel_];
		
		contentView_ = [[UIView alloc] initWithFrame:CGRectZero];
		contentView_.backgroundColor = [UIColor whiteColor];
		contentView_.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		contentView_.contentMode = UIViewContentModeRedraw;
		[self addSubview:contentView_];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	UIColor *DDSocialDialogTitleBackgroundColor;
	UIColor *DDSocialDialogTitleStrokeColor;
	UIColor *DDSocialDialogBlackStrokeColor;
	UIColor *DDSocialDialogBorderColor;

	if (theme_ == DDSocialDialogThemePlurk) {
		DDSocialDialogTitleBackgroundColor = [UIColor colorWithRed:0.953 green:0.49 blue:0.03 alpha:1.0];
		DDSocialDialogTitleStrokeColor = [UIColor colorWithRed:0.753 green:0.341 blue:0.145 alpha:1.0];
		DDSocialDialogBlackStrokeColor = [UIColor colorWithRed:0.753 green:0.341 blue:0.145 alpha:1.0];
		DDSocialDialogBorderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
	} else {
		// Default dialog theme colors are for DDSocialDialogThemeTwitter
		DDSocialDialogTitleBackgroundColor = [UIColor colorWithRed:0.557 green:0.757 blue:0.855 alpha:1.0];
		DDSocialDialogTitleStrokeColor = [UIColor colorWithRed:0.233 green:0.367 blue:0.5 alpha:1.0];
		DDSocialDialogBlackStrokeColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
		DDSocialDialogBorderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];		
	}
	
	CGRect grayRect = CGRectOffset(rect, -0.5, -0.5);
	[self drawRect:grayRect fill:DDSocialDialogBorderColor.CGColor radius:10];

    CGRect headerRect = CGRectIntegral(CGRectMake(rect.origin.x + kDDSocialDialogBorderWidth, rect.origin.y + kDDSocialDialogBorderWidth, rect.size.width - kDDSocialDialogBorderWidth*2, titleLabel_.frame.size.height));
	[self drawRect:headerRect fill:DDSocialDialogTitleBackgroundColor.CGColor radius:0];
	[self strokeLines:headerRect stroke:DDSocialDialogTitleStrokeColor.CGColor];
	
	CGRect contentRect = CGRectIntegral(CGRectMake(rect.origin.x + kDDSocialDialogBorderWidth, headerRect.origin.y + headerRect.size.height, rect.size.width - kDDSocialDialogBorderWidth*2, contentView_.frame.size.height+1));
	[self strokeLines:contentRect stroke:DDSocialDialogBlackStrokeColor.CGColor];
}

#pragma mark -

- (void)show {
	
	[self sizeToFitOrientation:NO];
	
	CGFloat innerWidth = self.frame.size.width - (kDDSocialDialogBorderWidth+1)*2;  
	[titleLabel_ sizeToFit];
	[closeButton_ sizeToFit];
	
    titleLabel_.frame = CGRectMake(kDDSocialDialogBorderWidth + kDDSocialDialogTitleMarginX,
                                   kDDSocialDialogBorderWidth,
                                   innerWidth - (titleLabel_.frame.size.height + kDDSocialDialogTitleMarginX*2),
                                   titleLabel_.frame.size.height + kDDSocialDialogTitleMarginY*2);    
    closeButton_.frame = CGRectMake(self.frame.size.width - (titleLabel_.frame.size.height + kDDSocialDialogBorderWidth),
                                    kDDSocialDialogBorderWidth,
                                    titleLabel_.frame.size.height,
                                    titleLabel_.frame.size.height);

	
	contentView_.frame = CGRectMake(kDDSocialDialogBorderWidth+1,
									kDDSocialDialogBorderWidth + titleLabel_.frame.size.height,
									innerWidth,
									self.frame.size.height - (titleLabel_.frame.size.height + 1 + kDDSocialDialogBorderWidth*2));
	
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	
	// Touch background to dismiss dialog
	touchInterceptingControl_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
	touchInterceptingControl_.userInteractionEnabled = YES;
	[window addSubview:touchInterceptingControl_];
	
	[window addSubview:self];
	
    CGPoint center;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        center = CGPointMake(window.frame.size.height/2.0, window.frame.size.width/2.0);        
    } else {
        center = CGPointMake(window.frame.size.width/2.0, window.frame.size.height/2.0);
    }
    
    float spanX = (originalFrame_.origin.x + originalFrame_.size.width/2.0) - center.x;
    float spanY = (originalFrame_.origin.y + originalFrame_.size.height/2.0) - center.y;
    
    self.transform = CGAffineTransformScale(CGAffineTransformTranslate([self transformForOrientation], spanX, spanY), 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kDDSocialDialogTransitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
	[UIView commitAnimations];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:) name:@"UIKeyboardDidShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];	
}

- (void)cancel {

	if ([dialogDelegate_ conformsToProtocol:@protocol(DDSocialDialogDelegate)]) {
		if ([dialogDelegate_ respondsToSelector:@selector(socialDialogDidCancel:)]) {
			[dialogDelegate_ socialDialogDidCancel:self];
		}		
	}
	
	[self dismiss:YES];		
}

- (void)dismiss:(BOOL)animated {
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kDDSocialDialogTransitionDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
		self.alpha = 0;
		[UIView commitAnimations];
	} else {
		[self postDismissCleanup];
	}
}

- (void)postDismissCleanup {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardDidShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillHideNotification" object:nil];
	[self removeFromSuperview];
	[touchInterceptingControl_ removeFromSuperview];
}

#pragma mark -
#pragma mark Drawing

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
	
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	
	if (radius == 0) {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
	} else {
		rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
		CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
		CGContextScaleCTM(context, radius, radius);
		float fw = CGRectGetWidth(rect) / radius;
		float fh = CGRectGetHeight(rect) / radius;
		
		CGContextMoveToPoint(context, fw, fh/2);
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(CGColorRef)fillColor radius:(CGFloat)radius {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	if (fillColor) {
		CGContextSaveGState(context);
		CGContextSetFillColor(context, CGColorGetComponents(fillColor));
		if (radius) {
			[self addRoundedRectToPath:context rect:rect radius:radius];
			CGContextFillPath(context);
		} else {
			CGContextFillRect(context, rect);
		}
		CGContextRestoreGState(context);
	}
	
	CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(CGColorRef)strokeColor {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	CGContextSaveGState(context);
	CGContextSetStrokeColorSpace(context, space);
	CGContextSetStrokeColor(context, CGColorGetComponents(strokeColor));
	CGContextSetLineWidth(context, 3.0);
    
	{
		CGPoint points[] = {rect.origin.x+0.5, rect.origin.y-0.5,
			rect.origin.x+rect.size.width, rect.origin.y-0.5};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5,
			rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {rect.origin.x+rect.size.width-0.5, rect.origin.y,
			rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {rect.origin.x+0.5, rect.origin.y,
			rect.origin.x+0.5, rect.origin.y+rect.size.height};
		CGContextStrokeLineSegments(context, points, 2);
	}
	
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
}

#pragma mark Animation

- (void)bounce1AnimationStopped {
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kDDSocialDialogTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kDDSocialDialogTransitionDuration/2];
	self.transform = [self transformForOrientation];
	[UIView commitAnimations];
}

#pragma mark Rotation

- (CGAffineTransform)transformForOrientation {
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}

- (void)sizeToFitOrientation:(BOOL)transform {
	
	if (transform) {
		self.transform = CGAffineTransformIdentity;
	}
	
	orientation_ = [UIApplication sharedApplication].statusBarOrientation;
	
	CGSize frameSize = defaultFrameSize_;
	self.frame = CGRectMake(kDDSocialDialogPadding, kDDSocialDialogPadding, frameSize.width - kDDSocialDialogPadding * 2, frameSize.height - kDDSocialDialogPadding * 2);
	
	if (!showingKeyboard_) {
		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGPoint center = CGPointMake(ceil(screenSize.width/2), ceil(screenSize.height/2));
		self.center = center;		
	}
	
	if (transform) {
		self.transform = [self transformForOrientation];
	}
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation {
	
	if (orientation == orientation_) {
		return NO;
	} else {
		return orientation == UIInterfaceOrientationLandscapeLeft
			|| orientation == UIInterfaceOrientationLandscapeRight
			|| orientation == UIInterfaceOrientationPortrait
			|| orientation == UIInterfaceOrientationPortraitUpsideDown;
	}
}

#pragma mark Notifications

- (void)deviceOrientationDidChange:(void*)object {
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	if ([self shouldRotateToOrientation:orientation]) {
		if (!showingKeyboard_) {
			if (UIInterfaceOrientationIsLandscape(orientation)) {
				contentView_.frame = CGRectMake(kDDSocialDialogBorderWidth + 1,
												kDDSocialDialogBorderWidth + titleLabel_.frame.size.height,
												self.frame.size.width - (kDDSocialDialogBorderWidth+1)*2,
												self.frame.size.height - (titleLabel_.frame.size.height + 1 + kDDSocialDialogBorderWidth*2));
			} else {
				contentView_.frame = CGRectMake(kDDSocialDialogBorderWidth + 1,
												kDDSocialDialogBorderWidth + titleLabel_.frame.size.height,
												self.frame.size.height - (kDDSocialDialogBorderWidth+1)*2,
												self.frame.size.width - (titleLabel_.frame.size.height + 1 + kDDSocialDialogBorderWidth*2));
			}
		} 
		
		CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
		[self sizeToFitOrientation:YES];
		[UIView commitAnimations];		
	}	
}

- (void)keyboardDidShow:(NSNotification*)notification {

	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;	

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(orientation)) {
		// On the iPad the screen is large enough that we don't need to 
		// resize the dialog to accomodate the keyboard popping up
		return;
	}

	CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
	CGSize keyboardSize = [self convertRect:[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:nil].size;
	
	CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			self.center = CGPointMake(self.center.x, ceil((screenSize.height - keyboardSize.height)/2) + 10.);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			self.center = CGPointMake(self.center.x, screenSize.height - (ceil((screenSize.height - keyboardSize.height)/2) + 10.));
			break;
		case UIInterfaceOrientationLandscapeLeft:
			self.center = CGPointMake(ceil((screenSize.width - keyboardSize.height)/2), self.center.y);
			break;
		case UIInterfaceOrientationLandscapeRight:
			self.center = CGPointMake(screenSize.width - (ceil((screenSize.width - keyboardSize.height)/2)), self.center.y);
			break;
	}	
	[UIView commitAnimations];
	
	showingKeyboard_ = YES;
}

- (void)keyboardWillHide:(NSNotification*)notification {

	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(orientation)) {
		return;
	}
	
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	self.center = CGPointMake(ceil(screenSize.width/2), ceil(screenSize.height/2));
	[UIView commitAnimations];
	
	showingKeyboard_ = NO;
}

@end
