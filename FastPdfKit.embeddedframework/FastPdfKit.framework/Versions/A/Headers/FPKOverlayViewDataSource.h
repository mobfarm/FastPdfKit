//
//  FPKOverlayViewDataSource.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 6/3/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFDocumentViewController;
@protocol FPKOverlayViewDataSource <NSObject>

@optional

/**
 This method shall return a set of view to display over the pdf page.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page;

/**
 This method needs to return the frame in page-coordinates for the view passed as arguments. Remember that, like drawables
 and touchables, the coordinate system's origin is in the bottom left corner of the page.
 */
-(CGRect)documentViewController:(MFDocumentViewController *)dvc rectForOverlayView:(UIView *)view onPage:(NSUInteger)page;

/**
 These callbacks will be invoked when the overlay view is going to be added, after is added, when is going to be removed
 and when it is actually removed from the page view. Use these to change the status of the view and or start/stop any
 action that needs to be synchronized with the lifecycle of the view.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc willAddOverlayView:(UIView *)view;

/**
 This method is called when the Overlay Views have been added
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didAddOverlayView:(UIView *)view;

/**
 This method is called when the Overlay View are going to be removed
 
 */
-(void)documentViewController:(MFDocumentViewController *)dvc willRemoveOverlayView:(UIView *)view;

/**
 This method is called when the Overlay View have been removed
 
 */
-(void)documentViewController:(MFDocumentViewController *)dvc didRemoveOverlayView:(UIView *)view;

@end
