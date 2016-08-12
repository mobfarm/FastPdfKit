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

/**
 Returns an array of UIView to be displayed as overlay on the PDF page view.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page;

/**
 Return the frame of the overlay view in the page view. 
 
 Remember that the
 CGRect returned must be in PDF Coordinate System, that is with the origin in the
 lower left.
 */
-(CGRect)documentViewController:(MFDocumentViewController *)dvc rectForOverlayView:(UIView *)view onPage:(NSUInteger)page;

/**
 Return the frame of the overlay view int the page view. 
 
 Note that, as opposed to
 documentViewController:frameForOverlayView:onPage: the CGRect returned is in
 UIView coordinate space, that is with the origin in the upper left.
 */
-(CGRect)documentViewController:(MFDocumentViewController *)dvc frameForOverlayView:(UIView *)view onPage:(NSUInteger)page;

/**
 These callbacks will be invoked when the overlay view is going to be added, 
 after is added, when is going to be removed and when it is actually removed from 
 the page view. Use these to change the status of the view and or start/stop any
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
