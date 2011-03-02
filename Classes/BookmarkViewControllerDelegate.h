//
//  BookmarkViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarkViewController;

@protocol BookmarkViewControllerDelegate

-(NSUInteger)page;

-(void)dismissBookmarkViewController:(BookmarkViewController *)bvc;

-(void)bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page;

@end
