//
//  SearchResultView.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/20/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "SearchResultView.h"
#import <CoreText/CoreText.h>

@implementation SearchResultView

@synthesize text, boldRange, page;
@synthesize highlighted, editing;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		
        // Content mode is set to redraw to repaint the view when the bounds changes, for
		// example when the Table View goes from portrait to landscape.
		
		self.contentMode = UIViewContentModeRedraw;
		
    }
    return self;
}


#pragma mark -
#pragma mark Setters

// All the setters change their respective value and mark the view as dirty for redraw.

-(void)setBoldRange:(NSRange)aRange {
	
	boldRange = aRange;	
	[self setNeedsDisplay];	
	
}

-(void)setText:(NSString *)aText {
	
	if(![text isEqualToString:aText]) {
	
		[text release];
		text = [aText copy];
		
		[self setNeedsDisplay];
	}
}

-(void)setPage:(NSUInteger)aPage {

	if(aPage!=page) {
	
		page = aPage;
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Drawing

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	
	CGRect contentRect = self.bounds;
	
	if(!self.editing) {
		
		// Get the current context and push it.
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		
		// Flip on the vertical axis.
		// Keep in mind that now the origin of the rect is in the lower left, and the height measured going upward.
		
		CGContextScaleCTM(ctx, 1, -1);
		CGContextTranslateCTM(ctx, 0, -contentRect.size.height);
		
		// White background color for the view.
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
		CGContextFillRect(ctx, contentRect);
		
		
		// 1) Let's draw the Page X label first.
		
		/*// Set the text matrix to the identity.
		CGContextSaveGState(ctx);
		
		CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
		
		// Create the attributed string for the label.
		
		NSString * labelString = [NSString stringWithFormat:@"Page %d",page];
		NSMutableAttributedString * pageAttrString = [[NSMutableAttributedString alloc]init];
		[pageAttrString replaceCharactersInRange:NSMakeRange(0, 0) withString:labelString];
		
		// It's just a label, so we are going to use just a simple line of text.
		CTLineRef labelLine = CTLineCreateWithAttributedString((CFAttributedStringRef)pageAttrString);
		[pageAttrString release];
		
		// Start 16 pixel down from the top edge.
		CGContextSetTextPosition(ctx, 25, contentRect.size.height-50);
		
		// Draw the line.
		CTLineDraw(labelLine, ctx);
		
		CFRelease(labelLine);
		
		CGContextRestoreGState(ctx);*/
		
		// 2) Now let's proceed with the snippet.
		
		// Reset the text matrix first.
		CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
		
		// Build the string as before.
		CFStringRef snippetString = (CFStringRef)text;
		CFMutableAttributedStringRef snippetAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(snippetAttrString, CFRangeMake(0, 0), snippetString);
		
		// Now let's set a red color attribute for the sequence matching the search term to highlight it.
		
		// Here we prepare the color.
		CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat components [] = {1.0,0.0,0.0,1.0};
		CGColorRef red = CGColorCreate(rgbColorSpace, components);
		CGColorSpaceRelease(rgbColorSpace);
		
		// Here we set the color as red.
		//CFAttributedStringSetAttribute(snippetAttrString, CFRangeMake(boldRange.location, boldRange.length), kCTForegroundColorAttributeName, red);
		CGColorRelease(red);
		
		CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 12.0, NULL);
		[snippetAttrString addAttribute:(id)kCTFontAttributeName value:(id)helveticaBold range:NSMakeRange(boldRange.location, boldRange.length)];

		
		// Framesetter as before.
		CTFramesetterRef snippetFramesetter = CTFramesetterCreateWithAttributedString(snippetAttrString);
		CFRelease(snippetAttrString);
		
		// Rect for the snippet frame.
		CGRect snippetRect = CGRectMake(8, 0, contentRect.size.width, contentRect.size.height-10);
		
		// Cut and trim if necessary.
		CFRange snippetFitRange;
		CTFramesetterSuggestFrameSizeWithConstraints(snippetFramesetter, CFRangeMake(0, 0), NULL, snippetRect.size, &snippetFitRange);
		
		// Create the pat.
		CGMutablePathRef snippetPath = CGPathCreateMutable();
		CGPathAddRect(snippetPath, NULL, snippetRect);
		
		// Create the frame.
		CTFrameRef snippetFrame = CTFramesetterCreateFrame(snippetFramesetter, snippetFitRange, snippetPath, NULL);
		CFRelease(snippetFramesetter);
		
		// Draw the frame.
		CTFrameDraw(snippetFrame,ctx);
		
		CFRelease(snippetFrame);
		CGPathRelease(snippetPath);
		
		// Pop the stored context state.
		CGContextRestoreGState(ctx);
	}
}


- (void)dealloc {
	
	[text release],text = nil;
	
    [super dealloc];
}


@end
