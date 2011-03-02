//
//  OutlineViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OutlineViewController;

@protocol OutlineViewControllerDelegate

-(void)dismissOutline:(id)self;
-(void)OutlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page;

@end
