//
//  TVThumbnailView.h
//  ThumbnailView
//
//  Created by Nicolò Tosi on 10/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TVThumbnailScrollView;

@interface TVThumbnailView : UIView {

}

@property (nonatomic,retain) UIImage * image;
@property (nonatomic,readwrite) NSUInteger position;
@property (nonatomic,copy) NSString * pendingThumbnailName;
@property (nonatomic,assign) TVThumbnailScrollView * delegate;
@property (nonatomic,retain) UIActivityIndicatorView * activityIndicator;

@end
