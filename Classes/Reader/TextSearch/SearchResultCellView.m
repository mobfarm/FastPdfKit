//
//  SearchResultCellView.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/20/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "SearchResultCellView.h"
#import "SearchResultView.h"

@implementation SearchResultCellView


@synthesize searchResultView;
@synthesize textSnippet, boldRange, page;


// This Cell View is following the example in the Table View Programming Guide, especially the chapter about
// customizing UITableCellView. Take a look a the official Apple documentation for more details.


#pragma mark -
#pragma mark Setters

// All the setters set the respective value inside the content view.

-(void) setTextSnippet:(NSString *)newTextSnippet {

	if(![newTextSnippet isEqualToString:textSnippet]) {
		
		[textSnippet release];
		textSnippet = [newTextSnippet copy];
		
		[searchResultView setText:textSnippet];
	}
}

-(void) setPage:(NSUInteger)newPage {

	if(page!=newPage) {
	
		page = newPage;
		[searchResultView setPage:newPage];
	}
}

-(void) setBoldRange:(NSRange)newRange {

	if(!NSEqualRanges(boldRange, newRange)) {
		
		boldRange = newRange;
		[searchResultView setBoldRange:newRange];
	}
}

#pragma mark -
#pragma mark UITableCellView methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		
		CGRect srvFrame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		searchResultView = [[SearchResultView alloc]initWithFrame:srvFrame];
		
		searchResultView.text = textSnippet;
		searchResultView.page = page;
		searchResultView.boldRange = boldRange;
		
		searchResultView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		
		[self.contentView addSubview:searchResultView];
        
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	
	[textSnippet release],textSnippet = nil;
	[searchResultView release],searchResultView = nil;
	
    [super dealloc];
}


@end
