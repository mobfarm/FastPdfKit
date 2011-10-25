//
//  TVThumbnailView.h
//  ThumbnailView
//
//  Created by Nicolò Tosi on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentManager.h"

@class TVThumbnailView;
@class TVThumbnailScrollView;

@protocol TVThumbnailScrollViewDelegate

-(void)thumbnailScrollView:(TVThumbnailScrollView *)scrollView didSelectPage:(NSUInteger)page;

//-(void)provideThumbnailForPage:(NSUInteger)page;
//-(void)cancelThumbnailForPage:(NSUInteger)page;

@end

@interface TVThumbnailScrollView : UIView <UIScrollViewDelegate> {
    
    NSUInteger thumbnailCount;
    
    NSUInteger page;
    NSUInteger pagesCount;
    
    NSArray * thumbnailViews;
    
    NSString * cacheFolder;
    
    NSUInteger currentThumbnailPosition;
    
    CGSize thumbnailSize;
    CGFloat padding;
    
    NSString * thumbnailFolder;
    
    id<TVThumbnailScrollViewDelegate> delegate;
    
    NSFileManager * fileManager;
    
    BOOL backgroundWorkStillGoingOn;
    BOOL shouldContinueBackgrounWork;
    
    MFDocumentManager * document;
    
    NSString * documentId;
}

@property (nonatomic,copy) NSString * cacheFolder;
@property (nonatomic,readwrite) NSUInteger pagesCount;

@property (nonatomic,copy) NSString * thumbnailFolder;

@property (nonatomic,readwrite) CGSize thumbnailSize;
@property (nonatomic,readwrite) CGFloat padding;

@property (nonatomic,assign) id<TVThumbnailScrollViewDelegate> delegate;

-(NSString *)imagePathForPosition:(int)position;
-(NSString *)imagePathForThumbnailView:(TVThumbnailView *)view;
-(void)requestImageForThumbnailView:(TVThumbnailView *)view;

//+(NSNotification *)thumbnailReadyNotification:(NSString *)thumbnail;
//
//extern NSString * kTVThumbnailName;
//extern NSString * kTVThumbnailReadyNotification;
@property (nonatomic,retain) MFDocumentManager * document;
-(void)setPage:(NSUInteger)page animated:(BOOL)animated;
-(void)page;

@end
