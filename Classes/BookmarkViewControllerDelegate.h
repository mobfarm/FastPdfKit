//
//  BookmarkViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarkViewController;

@protocol BookmarkViewControllerDelegate

-(NSUInteger)page;

-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc;

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page;

-(NSString *)documentId;

@end
