//
//  MFDocumentOverlayDataSource.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 12/10/10.
//  Copyright 2010 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MFDocumentViewController;
@protocol MFDocumentOverlayDataSource


@optional

-(NSArray *)documentViewController:(MFDocumentViewController *)dvc drawablesForPage:(NSUInteger)page;

@end
