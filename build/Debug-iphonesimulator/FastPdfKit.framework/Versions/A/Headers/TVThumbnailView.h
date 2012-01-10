//
//  MFSliderDetailVIew.h
//  FastPdfKit Sample
//
//  Created by Nicolò Tosi on 7/7/11.
//  Copyright 2011 MobFarm S.a.s.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TVThumbnailScrollView;

@protocol TVThumbnailViewDelegate

-(void)thumbTapped:(NSInteger)position withObject:(id)obj;

@end

@interface TVThumbnailView : UIView {
    
    UIActivityIndicatorView * activityIndicator;
    
    NSInteger position;
    
    UILabel * pageNumberLabel;
    NSNumber * pageNumber;
    
    UIImageView * thumbnailView;
    NSString * thumbnailImagePath;
    
    UIImage * thumbnailImage;
    
    id<TVThumbnailViewDelegate> delegate;
}

@property (nonatomic,retain) NSNumber * pageNumber;
@property (nonatomic,retain) UILabel * pageNumberLabel;

@property (nonatomic,retain) UIImageView * thumbnailView;
@property (nonatomic,copy) NSString *thumbnailImagePath;

@property (nonatomic,retain) UIActivityIndicatorView * activityIndicator;

@property (nonatomic,assign) id<TVThumbnailViewDelegate> delegate;

@property (nonatomic,readwrite) NSInteger position;

@property (nonatomic,retain) UIImage * thumbnailImage;

-(void)reloadImage:(UIImage *)image;

@end
