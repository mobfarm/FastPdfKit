//
//  OutlineViewControllerDelegate.h
//  FastPdfKit
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPKDestination;
@class OutlineViewController;

@protocol OutlineViewControllerDelegate <NSObject>

-(void)dismissOutlineViewController:(OutlineViewController *)ovc;

@optional
-(void)outlineViewController:(OutlineViewController *)ovc didRequestDestination:(id<FPKDestination>)destination file:(NSString *)file;
@end
