//
//  ThumbnailViewController.h
//  RoadView
//
//  Created by Matteo Gavagnin on 26/03/09.
//  Copyright 2009 MobFarm s.r.l.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MFSliderDetailDelegate <NSObject>
@required
- (void)thumbTapped:(int)number withObject:(id)object;
@end

@interface MFSliderDetail : UIViewController {
	id object;
	NSString *thumbnail;
	CGSize size;
	int page;
	id delegate;
	id dataSource;
	UIImageView *corner;
	BOOL temp;
}
@property (nonatomic,assign) id <MFSliderDetailDelegate> delegate;
@property (nonatomic,assign) id object;
@property (nonatomic,assign) id dataSource;
@property (nonatomic,retain) UIImageView *corner;
@property (nonatomic) BOOL temp;
- (id)initWithPageNumber:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source;
//not used initWithPageNumberNoThumb
- (id)initWithPageNumberNoThumb:(int)aPage andImage:(NSString *)_image andSize:(CGSize)_size andObject:(id)_object andDataSource:(id)_source;
- (void)setSelected:(BOOL)selected;
//not used updateCorner
- (void)updateCorner;

@end
