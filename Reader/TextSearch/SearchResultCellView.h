//
//  SearchResultCellView.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 1/20/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultView;

@interface SearchResultCellView : UITableViewCell

@property (nonatomic, strong) SearchResultView *searchResultView;

@property (nonatomic, copy) NSString * textSnippet;
@property (nonatomic, readwrite) NSRange boldRange;
@property (nonatomic, readwrite) NSUInteger page;

@end
