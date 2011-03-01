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

@synthesize text, boldRange, page,boldStart;
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
		
		NSUInteger initBold = 0 ;
		
		CGRect labelRect = CGRectMake(0, 0, rect.size.height*1.5,rect.size.height);
		
		CGRect snippetRect = CGRectMake(rect.size.height*1.5, 0, rect.size.width-(rect.size.height*1.5), rect.size.height);
		
		snippetRect.size.height *= 0.5;
		snippetRect.origin.y = snippetRect.size.height * 0.5;
		
		labelRect.size.height *= 0.5;
		labelRect.origin.x += 10;
		labelRect.origin.y = labelRect.size.height * 0.5;
		labelRect.size.width -=20;
		
		
		
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
		
		//[self drawLabel:labelRect];
		
		
		// 1) Let's draw the Page X label first.
		
		CGContextSaveGState(ctx);
		
		CGContextSetRGBFillColor(ctx, 0.75, 0.75, 0.75, 1.0);
		//CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
		CGContextSetAllowsAntialiasing(ctx, 1);
		
		CGFloat radius = labelRect.size.height*0.5;	// Radius of the corners.
		
		
		// Draw a path resembling a rounded rect.
		
		CGContextTranslateCTM(ctx, labelRect.origin.x, labelRect.origin.y);
		CGContextBeginPath(ctx);
		CGContextAddArc(ctx, radius, radius, radius, M_PI, M_PI*3*0.5, 0);
		CGContextAddArc(ctx, labelRect.size.width-radius, radius, radius, M_PI*3*0.5, 0,0);
		CGContextAddArc(ctx, labelRect.size.width-radius, labelRect.size.height-radius, radius, 0, M_PI*0.5, 0);
		CGContextAddArc(ctx, radius, labelRect.size.height-radius, radius, M_PI*0.5, M_PI, 0);
		CGContextClosePath(ctx);
		CGContextDrawPath(ctx, kCGPathFill);
		
		CGContextRestoreGState(ctx);
		
		
		NSString *pageNumberString= [NSString stringWithFormat:@"%d",page];
		
		CFMutableAttributedStringRef labelAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(labelAttrString, CFRangeMake(0, 0), (CFStringRef) pageNumberString);
		
		CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 12.0, NULL);
		
		[labelAttrString addAttribute:(id)kCTFontAttributeName value:(id)helveticaBold range:NSMakeRange(0, pageNumberString.length)];
		
		CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat components [] = {1.0,1.0,1.0,1.0};
		CGColorRef white = CGColorCreate(rgbColorSpace, components);
		CGColorSpaceRelease(rgbColorSpace);
		
		CFAttributedStringSetAttribute(labelAttrString, CFRangeMake(0, pageNumberString.length), kCTForegroundColorAttributeName, white);
		CGColorRelease(white);
		
		CTTextAlignment alignment = kCTCenterTextAlignment;
		CTParagraphStyleSetting _settings[] = {    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
		     
		//    set paragraph style attribute
		CFAttributedStringSetAttribute(labelAttrString, CFRangeMake(0, CFAttributedStringGetLength(labelAttrString)), kCTParagraphStyleAttributeName, paragraphStyle);
		CFRelease(paragraphStyle);
		
		// Framesetter as before.
		CTFramesetterRef labelFramesetter = CTFramesetterCreateWithAttributedString(labelAttrString);
		
		// Rect for the snippet frame.
		//CGRect snippetRect = CGRectMake(8, 0, contentRect.size.width, contentRect.size.height-10);
		
		//CTFramesetterSuggestFrameSizeWithConstraints(labelFramesetter, CFRangeMake(0, 0), NULL, snippetRect.size, NULL);
		
		// Create the pat.
		CGMutablePathRef labelPath = CGPathCreateMutable();
		CGPathAddRect(labelPath, NULL, labelRect);
		
		// Create the frame.
		CTFrameRef labelFrame = CTFramesetterCreateFrame(labelFramesetter, CFRangeMake(0, pageNumberString.length), labelPath, NULL);
		CFRelease(labelFramesetter);
		
		// Draw the frame.
		CTFrameDraw(labelFrame,ctx);
		
		CFRelease(labelFrame);
		CGPathRelease(labelPath);
		CFRelease(labelAttrString);
		
		
		
		
		// Set the text matrix to the identity.
		/*CGContextSaveGState(ctx);
		
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
		/*NSString *stringPage = [@"@ " stringByAppendingString:[NSString stringWithFormat:@"%d",text]];
		stringPage = [stringPage stringByAppendingString:@"       "];
		initBold = stringPage.length;
		lengthDescritption = stringPage.length;
		//stringPage = [stringPage stringByAppendingString:text];*/
		CFStringRef snippetString = (CFStringRef)text;
		
		CFMutableAttributedStringRef snippetAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(snippetAttrString, CFRangeMake(0, 0), snippetString);
		
		// Now let's set a red color attribute for the sequence matching the search term to highlight it.
		
		// Here we prepare the color.
		/*CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat components [] = {1.0,0.0,0.0,1.0};
		CGColorRef red = CGColorCreate(rgbColorSpace, components);
		CGColorSpaceRelease(rgbColorSpace);
		
		// Here we set the color as red.
		//CFAttributedStringSetAttribute(snippetAttrString, CFRangeMake(boldRange.location, boldRange.length), kCTForegroundColorAttributeName, red);
		CGColorRelease(red);*/
		
		//CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 11.0, NULL);
		
		//int lenght = stringaModificata.length;
		initBold=boldRange.location+initBold;
		//[snippetAttrString addAttribute:(id)kCTFontAttributeName value:(id)helveticaBold range:NSMakeRange(0, lengthDescritption)];
		
		[snippetAttrString addAttribute:(id)kCTFontAttributeName value:(id)helveticaBold range:NSMakeRange(initBold, boldRange.length)];
		
		// Framesetter as before.
		CTFramesetterRef snippetFramesetter = CTFramesetterCreateWithAttributedString(snippetAttrString);
	
		
		// Rect for the snippet frame.
		//CGRect snippetRect = CGRectMake(8, 0, contentRect.size.width, contentRect.size.height-10);
		
		// Cut and trim if necessary.
		CFRange snippetFitRange;
		
		CTFramesetterSuggestFrameSizeWithConstraints(snippetFramesetter, CFRangeMake(0, (CFAttributedStringGetLength(snippetAttrString))), NULL, snippetRect.size, &snippetFitRange);
	
		NSLog(@"width %.3f height %.3f x: %.3f y: %.3f",snippetRect.size.width,snippetRect.size.height, snippetRect.origin.x,snippetRect.origin.y);
		NSLog(@"%@",snippetString);
		
		if (!(snippetFitRange.length> boldRange.location+boldRange.length)) {
			snippetFitRange.location = boldRange.location-((snippetFitRange.length-boldRange.length)/2);
		}
		
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
		CFRelease(snippetAttrString);
		
		
		// Pop the stored context state.
		CGContextRestoreGState(ctx);
	}
}

- (void)dealloc {
	
	[text release],text = nil;
	
    [super dealloc];
}


@end
