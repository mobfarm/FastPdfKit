//
//  Drawable.m
//  FastPdfKit
//
//  Created by Matteo Gavagnin on 8/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Drawable.h"


@implementation Drawable

-(CFDictionaryRef)fontAttributes {
    if(!_fontAttributes) {
        
        CTFontRef font = CTFontCreateWithName((CFStringRef)@"Helvetica-Neue", 12.0, NULL);
        
        CFStringRef keys[] = { kCTFontAttributeName };
        
        CFTypeRef values[] = { font };
        
        _fontAttributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        CFRelease(font);
    }
    return _fontAttributes;
}

-(CTLineRef)firstLine {
    if(!_firstLine) {
        CFStringRef string = CFStringCreateWithCString(NULL, "This is an overlay, check classes", kCFStringEncodingMacRoman);
        CFAttributedStringRef attr_string = CFAttributedStringCreate(NULL, string, [self fontAttributes]);
        _firstLine = CTLineCreateWithAttributedString(attr_string);
        CFRelease(string);
        CFRelease(attr_string);

    }
    return _firstLine;
}

-(CTLineRef)secondLine {
    if(!_secondLine) {
        CFStringRef string = CFStringCreateWithCString(NULL, "OverlayManager and Drawable", kCFStringEncodingMacRoman);
        CFAttributedStringRef attr_string = CFAttributedStringCreate(NULL, string, [self fontAttributes]);
        _secondLine = CTLineCreateWithAttributedString(attr_string);
        CFRelease(string);
        CFRelease(attr_string);
    }
    return _secondLine;
}

-(void)drawInContext:(CGContextRef)context{

    CGContextSaveGState(context);
    
    CGRect clipBoundingBox = CGContextGetClipBoundingBox(context);
    
    const char *text = "Hello World!";
    
    CGContextSetTextPosition(context, 101, 113);
    CTLineDraw([self firstLine], context);
    
    CGContextSetTextPosition(context, 101, 100);
    CTLineDraw([self secondLine], context);
    
    UIImage *image = [UIImage imageNamed:@"Icon.png"];
	CGContextDrawImage(context, CGRectMake(20, 80, 61, 61), image.CGImage);
    
    CGContextRestoreGState(context);
}

-(void)dealloc {
    if(_firstLine)
    CFRelease(_firstLine);
    if(_secondLine)
    CFRelease(_secondLine);
    if(_fontAttributes)
    CFRelease(_fontAttributes);
}

@end
