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
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        NSString * pageNumberString = nil;
        CFMutableAttributedStringRef labelAttrString = NULL;
        
        CTFontRef helveticaBoldNumber = NULL;
        CTFontRef helveticaBoldSnippet = NULL;
        CTFontRef helveticaSnippet = NULL;
        CGColorSpaceRef rgbColorSpace = NULL;
        CGFloat whiteComponents [] = {1.0,1.0,1.0,1.0};
        CGColorRef whiteColor = NULL;
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
		CTParagraphStyleSetting _settings[] = {{kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
		CTParagraphStyleRef paragraphStyle = NULL;
		
        // Label variables.
        
        CGRect labelRect = CGRectNull;
        CGRect labelTextRect = CGRectNull;
        CGFloat labelRadius = 0.0f;
        CTFramesetterRef labelFramesetter = NULL;
        CTFrameRef labelFrame = NULL;
        CGMutablePathRef labelPath = NULL;
        
        // Snippet variables.
        
        CGRect snippetRect = CGRectNull;
        CFStringRef snippetString = NULL;
        CTFramesetterRef snippetFramesetter = NULL;
        CFRange snippetFitRange = CFRangeMake(0, 0);
        CGMutablePathRef snippetPath = NULL;
		CTFrameRef snippetFrame = NULL;
        CFMutableAttributedStringRef snippetAttrString = NULL;
        
        // Calculate label size and position.
        
		labelRect = CGRectMake(0, 0, rect.size.height*1.5,rect.size.height);
		labelRect.size.height *= 0.5;
		labelRect.origin.x += 10;
		labelRect.origin.y = labelRect.size.height * 0.5;
		labelRect.size.width -=20;
		
		labelTextRect = CGRectMake(0, 0, rect.size.height*1.5,rect.size.height);
		labelTextRect.size.height *= 0.5;
		labelTextRect.origin.x += 10;
		labelTextRect.origin.y = labelRect.size.height * 0.5 + 0.0;
		labelTextRect.size.width -=20;
        
        snippetRect = CGRectMake(rect.size.height*0.2, 0, rect.size.width-(rect.size.height*1.5), rect.size.height);
		snippetRect.size.height *= 0.5;
		snippetRect.origin.y = snippetRect.size.height * 0.5;
	
		
		// Save the current context.
		
		CGContextSaveGState(ctx);
		
		// Flip on the vertical axis.
		// Keep in mind that now the origin of the rect is in the lower left, and the height measured going upward.
		
		CGContextScaleCTM(ctx, 1, -1);
		CGContextTranslateCTM(ctx, 0, -contentRect.size.height);
		
		// White background color for the view.
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
		CGContextFillRect(ctx, contentRect);
		
		//[self drawLabel:labelRect];
        
        /*
		
		// 1) Let's draw the Page X label first.
		
		CGContextSaveGState(ctx);
		
		CGContextSetRGBFillColor(ctx, 0.75, 0.75, 0.75, 1.0);
		CGContextSetRGBStrokeColor(ctx, 0.85, 0.85, 0.85, 1.0);
		CGContextSetAllowsAntialiasing(ctx, 1);
		
		labelRadius = labelRect.size.height*0.5;	// Radius of the corners.
		
		// Draw a path resembling a rounded rect.
		
		CGContextTranslateCTM(ctx, labelRect.origin.x, labelRect.origin.y);
		CGContextBeginPath(ctx);
		CGContextAddArc(ctx, labelRadius, labelRadius, labelRadius, M_PI, M_PI*3*0.5, 0);
		CGContextAddArc(ctx, labelRect.size.width-labelRadius, labelRadius, labelRadius, M_PI*3*0.5, 0,0);
		CGContextAddArc(ctx, labelRect.size.width-labelRadius, labelRect.size.height-labelRadius, labelRadius, 0, M_PI*0.5, 0);
		CGContextAddArc(ctx, labelRadius, labelRect.size.height-labelRadius, labelRadius, M_PI*0.5, M_PI, 0);
		CGContextClosePath(ctx);
		CGContextDrawPath(ctx, kCGPathFillStroke);
		
		CGContextRestoreGState(ctx); // Pop.
		
        
		pageNumberString= [[NSString alloc]initWithFormat:@"%d",page];
		
		labelAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(labelAttrString, CFRangeMake(0, 0), (CFStringRef) pageNumberString);
         
	    
		// Bold.
		
		helveticaBoldNumber = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 14.0, NULL);
		CFAttributedStringSetAttribute(labelAttrString, CFRangeMake(0, CFAttributedStringGetLength(labelAttrString)), kCTFontAttributeName, helveticaBoldNumber);
        
		// White color.
		
		rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		
		whiteColor = CGColorCreate(rgbColorSpace, whiteComponents);
		CGColorSpaceRelease(rgbColorSpace);
		
		CFAttributedStringSetAttribute(labelAttrString, CFRangeMake(0, pageNumberString.length), kCTForegroundColorAttributeName, whiteColor);
		CGColorRelease(whiteColor);
		
		
		// Align to center.
		
		paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
        
		CFAttributedStringSetAttribute(labelAttrString, CFRangeMake(0, CFAttributedStringGetLength(labelAttrString)), kCTParagraphStyleAttributeName, paragraphStyle);
		
		// Framesetter.
		labelFramesetter = CTFramesetterCreateWithAttributedString(labelAttrString);
		
		// Create the pat.
		labelPath = CGPathCreateMutable();
		CGPathAddRect(labelPath, NULL, labelTextRect);
		
		// Create the frame.
		labelFrame = CTFramesetterCreateFrame(labelFramesetter, CFRangeMake(0, pageNumberString.length), labelPath, NULL);
		
		// Draw the frame.
		CTFrameDraw(labelFrame,ctx);
		
        // Label cleanup.
        
        if(labelFrame)
            CFRelease(labelFrame);
        
        if(labelPath)
            CGPathRelease(labelPath);
        
        if(labelAttrString)
            CFRelease(labelAttrString);
        
        if(paragraphStyle)
            CFRelease(paragraphStyle);
		
        if(labelFramesetter)
            CFRelease(labelFramesetter);
    
        [pageNumberString release];
        
        */
        
		// 2) Now let's proceed with the snippet.
		
		// Reset the text matrix first.
		
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
		
		snippetString = (CFStringRef)text;
		
		snippetAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(snippetAttrString, CFRangeMake(0, 0), snippetString);

		
        // Set the font size for the whole string
        helveticaSnippet = CTFontCreateWithName(CFSTR("Helvetica"), 14.0, NULL);
        CFAttributedStringSetAttribute(snippetAttrString, CFRangeMake(0, CFStringGetLength(snippetString)), kCTFontAttributeName, helveticaSnippet);
        
		// Bold.
		helveticaBoldSnippet = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 14.0, NULL);
		CFAttributedStringSetAttribute(snippetAttrString, CFRangeMake(boldRange.location, boldRange.length), kCTFontAttributeName, helveticaBoldSnippet);
       
		// Now the framesetter.
		
		snippetFramesetter = CTFramesetterCreateWithAttributedString(snippetAttrString);
		
		// Cut and trim if necessary to be sure the bold show up in the view.
    	CTFramesetterSuggestFrameSizeWithConstraints(snippetFramesetter, CFRangeMake(0, (CFAttributedStringGetLength(snippetAttrString))), NULL, snippetRect.size, &snippetFitRange);
	
		if (!(snippetFitRange.length > (boldRange.location + boldRange.length))) {
            
            if(snippetFitRange.length < boldRange.length) {
                snippetFitRange.location = boldRange.location;
            } else {
                
                snippetFitRange.location = boldRange.location + (snippetFitRange.length - boldRange.length)/2;
                
            }
		}
		
    	// Create the path.
		snippetPath = CGPathCreateMutable();
		CGPathAddRect(snippetPath, NULL, snippetRect);
		
		// Create the frame.
		snippetFrame = CTFramesetterCreateFrame(snippetFramesetter, snippetFitRange, snippetPath, NULL);
		
		// Draw the frame.
		CTFrameDraw(snippetFrame,ctx);
       
        
        // Snippet frame cleanup.
        
        if(snippetFrame)
            CFRelease(snippetFrame);
        
        if(snippetPath)
            CGPathRelease(snippetPath);
        
        if(snippetFramesetter)
            CFRelease(snippetFramesetter);
        
        if(snippetAttrString)
            CFRelease(snippetAttrString);
        
        if(helveticaBoldNumber)
            CFRelease(helveticaBoldNumber);

        if(helveticaBoldSnippet)
            CFRelease(helveticaBoldSnippet);        

        if(helveticaSnippet)
            CFRelease(helveticaSnippet);        

		// Pop the stored context state.
		CGContextRestoreGState(ctx);
	}
}

- (void)dealloc {
	
	[text release],text = nil;
	
    [super dealloc];
}


@end
