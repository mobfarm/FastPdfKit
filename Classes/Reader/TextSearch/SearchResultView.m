//
//  SearchResultView2.m
//  FastPdfKit
//
//  Created by Nicolo' on 13/01/15.
//
//

#import "SearchResultView.h"

@implementation SearchResultView

-(UIFont *)boldSnippetFont {
    if(!_boldSnippetFont) {
        _boldSnippetFont = [[UIFont boldSystemFontOfSize:14.0]retain];
    }
    return _boldSnippetFont;
}

-(UIFont *)regularSnippetFont {
    if(!_regularSnippetFont) {
        _regularSnippetFont = [[UIFont systemFontOfSize:14.0] retain];
    }
    return _regularSnippetFont;
}

-(void) setTextSnippet:(NSString *)newTextSnippet {
    /* Do nothing. Kept for backward compatibility only */
}

-(void) setPage:(NSUInteger)newPage {
    /* Do nothing. Kept for backward compatibility only */
}

-(void) setBoldRange:(NSRange)newRange {
    /* Do nothing. Kept for backward compatibility only */
}

-(void)setSnippet:(NSString *)snippet boldRange:(NSRange)range {
    
    NSDictionary * boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:self.boldSnippetFont, NSFontAttributeName,nil];
    NSDictionary * regularAttributes = [NSDictionary dictionaryWithObjectsAndKeys:self.regularSnippetFont, NSFontAttributeName,nil];
    
    NSMutableAttributedString * snippetAttributedString = [[NSMutableAttributedString alloc]initWithString:snippet attributes:regularAttributes];
    
    [snippetAttributedString setAttributes:boldAttributes range:range];
    
    self.snippetLabel.attributedText = snippetAttributedString;
    [snippetAttributedString release];
}

#pragma mark - UIView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        UILabel * pageNumberLabel = [[UILabel alloc]init];
        self.pageNumberLabel = pageNumberLabel;
        [pageNumberLabel release];
        [self addSubview:_pageNumberLabel];
        
        CGRect pageNumberFrame = CGRectMake(frame.size.width - 40, 0, 40, frame.size.height);
        _pageNumberLabel.frame = pageNumberFrame;
        
        UILabel * snippetLabel = [[UILabel alloc]init];
        self.snippetLabel = snippetLabel;
        [snippetLabel release];
        [self addSubview:_snippetLabel];
        
        CGRect snippetNumberFrame = CGRectMake(20, 0, frame.size.width - (20 + 40 + 20), frame.size.height);
        _snippetLabel.frame = snippetNumberFrame;
    }
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    // |<- snippet -><- margin, 20 pts-><- page number, 40 pts ->|
    
    CGRect pageNumberFrame = CGRectMake(bounds.size.width - 40, 0, 40, bounds.size.height);
    self.pageNumberLabel.frame = pageNumberFrame;
    
    CGRect snippetNumberFrame = CGRectMake(20, 0, bounds.size.width - (20 + 40 + 20), bounds.size.height);
    self.snippetLabel.frame = snippetNumberFrame;
}

-(void)dealloc {
    [super dealloc];
    
    [_pageNumberLabel release], _pageNumberLabel = nil;
    [_snippetLabel release], _snippetLabel = nil;
    
    [_boldSnippetFont release], _boldSnippetFont = nil;
    [_regularSnippetFont release], _regularSnippetFont = nil;
}

@end
