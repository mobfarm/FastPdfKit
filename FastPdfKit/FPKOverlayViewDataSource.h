//
//  FPKOverlayViewDataSource.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 6/3/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFDocumentViewController;
@protocol FPKOverlayViewDataSource <NSObject>

@optional

-(NSSet *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page;

-(CGRect)documentViewController:(MFDocumentViewController *)dvc rectForOverlayView:(UIView *)view;

-(void)documentViewController:(MFDocumentViewController *)dvc willAddOverlayView:(UIView *)view;
-(void)documentViewController:(MFDocumentViewController *)dvc didAddOverlayView:(UIView *)view;
-(void)documentViewController:(MFDocumentViewController *)dvc willRemoveOverlayView:(UIView *)view;
-(void)documentViewController:(MFDocumentViewController *)dvc didRemoveOverlayView:(UIView *)view;

@end
