//
//  SearchResultView.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/20/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchResultView : UIView {
	
	NSString *text;			// Text snippet.
	NSRange boldRange;		// Range of the search term inside the snippet.
	NSUInteger page;		// Page of the pdf document.
	
	BOOL highlighted;		// If highlited.
	BOOL editing;			// If in editing mode.
}

@property (nonatomic,copy) NSString *text;
@property (nonatomic,readwrite) NSRange boldRange;
@property (nonatomic,readwrite) NSUInteger page;

@property (nonatomic,getter=isHighlighted) BOOL highlighted;
@property (nonatomic,getter=isEditing) BOOL editing;

@end
