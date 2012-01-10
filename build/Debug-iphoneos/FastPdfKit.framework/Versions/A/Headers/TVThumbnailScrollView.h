//
//  TVThumbnailView.h
//  ThumbnailView
//
//  Created by Nicolò Tosi on 10/14/11.
//  Copyright (c) 2011 MobFarm S.a.s.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentManager.h"
#import "TVThumbnailView.h"

@class TVThumbnailScrollView;

@protocol TVThumbnailScrollViewDelegate

-(void)thumbnailScrollView:(TVThumbnailScrollView *)scrollView didSelectPage:(NSUInteger)page;

@end

@interface TVThumbnailScrollView : UIView <UIScrollViewDelegate, TVThumbnailViewDelegate> {
    
    NSUInteger thumbnailCount;
    
    NSUInteger page;
    NSUInteger pagesCount;
    
    NSArray * thumbnailViews;
    
    NSUInteger currentThumbnailPosition;
    
    CGSize thumbnailSize;
    CGFloat padding;
    
    id<TVThumbnailScrollViewDelegate> delegate;
    
    BOOL backgroundWorkStillGoingOn;
    BOOL shouldContinueBackgrounWork;
    
    MFDocumentManager * document;
    
    NSString * cacheFolderPath;
}

@property (nonatomic,readwrite) NSUInteger pagesCount;

@property (nonatomic,readwrite) CGSize thumbnailSize;
@property (nonatomic,readwrite) CGFloat padding;

@property (nonatomic,assign) id<TVThumbnailScrollViewDelegate> delegate;
@property (nonatomic, copy) NSString * cacheFolderPath;

@property (nonatomic,retain) MFDocumentManager * document;

-(void)setPage:(NSUInteger)page animated:(BOOL)animated;
-(NSUInteger)page;

-(void)start;
-(void)stop;

@end
