//
//  OutlineViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OutlineViewController;

@protocol OutlineViewControllerDelegate

-(void)dismissOutlineViewController:(OutlineViewController *)ovc;

-(void)outlineViewController:(OutlineViewController *)ovc didRequestPage:(NSUInteger)page;

@end
