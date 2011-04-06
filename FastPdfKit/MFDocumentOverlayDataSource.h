//
//  MFDocumentOverlayDataSource.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 12/10/10.
//  Copyright 2010 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MFDocumentViewController;
@protocol MFDocumentOverlayDataSource <NSObject>


@optional

/**
 This method is invoked when a new detail page is going to be drawn and overlayEnabled of the MFDocumentViewController is set
 to YES. The object setted as overlayDataSource is then required to return an array of MFOverlayDrawable object to be
 drawn on the page as overlay.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page;

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc overlayViewsForPage:(NSUInteger)page;

-(void)documentViewController:(MFDocumentViewController *)dvc willRemoveOverlayView:(UIView *)ov;

-(void)documentViewController:(MFDocumentViewController *)dvc didRemoveOverlayView:(UIView *)ov;

-(void)documentViewController:(MFDocumentViewController *)dvc willAddOverlayView:(UIView *)ov;

-(void)documentViewController:(MFDocumentViewController *)dvc didAddOverlayView:(UIView *)ov;


@end
