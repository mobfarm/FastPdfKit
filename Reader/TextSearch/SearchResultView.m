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
        _boldSnippetFont = [UIFont boldSystemFontOfSize:14.0];
    }
    return _boldSnippetFont;
}

-(UIFont *)regularSnippetFont {
    if(!_regularSnippetFont) {
        _regularSnippetFont = [UIFont systemFontOfSize:14.0];
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
}

#pragma mark - UIView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {

        UILabel * pageNumberLabel = [UILabel new];
        pageNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:pageNumberLabel];
        self.pageNumberLabel = pageNumberLabel;

        UILabel * snippetLabel = [UILabel new];
        snippetLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.snippetLabel = snippetLabel;
        [self addSubview:snippetLabel];
        
        NSDictionary * views = @{@"number":pageNumberLabel,
                                 @"snippet":snippetLabel};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[snippet]-[number(>=50)]-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[snippet]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[number]|" options:0 metrics:nil views:views]];
        
    }
    return self;
}

@end
