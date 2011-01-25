//
//  SearchResultCellView.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/20/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultView;

@interface SearchResultCellView : UITableViewCell {

	SearchResultView *searchResultView;	// The content view.
	
	// The properties reflect the one of the content view.
	
	NSString * textSnippet;		// Text snippet.
	NSRange boldRange;			// Range of the search term inside the snippet.
	NSUInteger page;			// Page of the pdf document with the search term.
}

@property (nonatomic,retain) SearchResultView *searchResultView;

@property (nonatomic, copy) NSString * textSnippet;
@property (nonatomic, readwrite) NSRange boldRange;
@property (nonatomic, readwrite) NSUInteger page;

@end
