//
//  MFDocumentOverlayDataSource.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 12/10/10.
//  Copyright 2010 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFOverlayTouchable.h"

@class MFDocumentViewController;

@protocol MFDocumentOverlayDataSource <NSObject>

@optional

/**
 You can implement this method to provide MFOverlayDrawables to be drawn over 
 the PDF page.
 This method can be called multiple times without notice. Ensure you can provide
 the drawables without blocking the main thread. A caching mechanism for the
 drawables might be useful.
 
 Consider using overlay views instead.
 
 @param dvc The MFDocumentViewController asking for drawables.
 @param page The page that will be drawn.

 @return An NSArray with the drawables.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc
                  drawablesForPage:(NSUInteger)page;

/**
 Same as documentViewController:drawablesForPage: but you are also provided a 
 flip flag you can set to true to have the drawable drawn in a coordinate system
 with the origin set in the upper left.
 
 Consider using overlay views instead.
 
 @param dvc The MFDocumentViewController asking for drawables.
 @param page The page that will be drawn.
 @param pdf Set this to YES if the drawables are defined in PDF coordinates space.
 
 @return An NSArray with the drawables.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc
                  drawablesForPage:(NSUInteger)page
                    pdfCoordinates:(BOOL *)pdf;

/**
 Return the touchables that will be tested when the user
 touch the screen. 
 The first touchable that will pass the test will be returnd in
 -documentViewController:didReceiveTapOnTouchable:.
 
 Consider using overlay views instead.
 
 @param dvc The MFDocumentViewController asking for touchables.
 @param page The page.
 
 @return Your touchables in an NSArray.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc
                 touchablesForPage:(NSUInteger)page;

/**
 Return the touchables that will be tested when the user
 touch the screen.
 The first touchable that will pass the test will be returnd in
 -documentViewController:didReceiveTapOnTouchable:.
 
 Consider using overlay views instead.
 
 @param dvc The MFDocumentViewController asking for touchables.
 @param page The page.
 @param pdf Se this to YES if the touchables are defined in PDF coordinate space.
 
 @return Your touchables in an NSArray.
 */
-(NSArray *)documentViewController:(MFDocumentViewController *)dvc
                 touchablesForPage:(NSUInteger)page
                   pdfCoordinates:(BOOL *)pdf;

/**
 Implement this method to be notified when the user tap on a touchable.
 @param dvc The MFDocumentViewController.
 @param touchable The MFTouchable being tapped.
 */
-(void)documentViewController:(MFDocumentViewController *)dvc
     didReceiveTapOnTouchable:(id<MFOverlayTouchable>)touchable;
@end
