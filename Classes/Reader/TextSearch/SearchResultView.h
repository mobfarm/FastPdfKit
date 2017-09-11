//
//  SearchResultView2.h
//  FastPdfKit
//
//  Created by Nicolo' on 13/01/15.
//
//

#import <UIKit/UIKit.h>

@interface SearchResultView : UIView

@property (nonatomic, strong) IBOutlet UILabel * pageNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel * snippetLabel;

@property (nonatomic, strong) UIFont * boldSnippetFont;
@property (nonatomic, strong) UIFont * regularSnippetFont;

/**
 * Utility method to set an NSSAttributedString as attributeText of
 * the snippet label, where the substring in the range passed as argument
 * is marked as bold.
 * @param snippet NSString with the text snippet to show
 * @param range NSRange indicating where the bold attribute should be applied
 */
-(void)setSnippet:(NSString *)snippet boldRange:(NSRange)range;

@end
