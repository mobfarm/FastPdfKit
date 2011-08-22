//
//  MFSliderDetailVIew.h
//  FastPdfKit Sample
//
//  Created by Nicolò Tosi on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSliderDetail.h"

@interface MFSliderDetailVIew : UIView {
    
    UIActivityIndicatorView * activityIndicator;
    
    UILabel * pageNumberLabel;
    NSNumber * pageNumber;
    
    UIImageView * thumbnailView;
    NSString * thumbnailImagePath;
    
    id<MFSliderDetailDelegate> delegate;
    
}

@property (nonatomic,retain) NSNumber * pageNumber;
@property (nonatomic,retain) UILabel * pageNumberLabel;

@property (nonatomic,retain) UIImageView * thumbnailView;
@property (nonatomic,copy) NSString *thumbnailImagePath;

@property (nonatomic,retain) UIActivityIndicatorView * activityIndicator;

@property (nonatomic,assign) id<MFSliderDetailDelegate> delegate;

@end
