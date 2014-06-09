//
//  Drawable.m
//  FastPdfKit
//
//  Created by Matteo Gavagnin on 8/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Drawable.h"

@implementation Drawable
-(void)drawInContext:(CGContextRef)context{
	UIImage *image = [UIImage imageNamed:@"Icon.png"];
	CGRect rect = CGRectMake(20, 80, 61, 61);

    CGContextSetGrayFillColor(context, 0.0, 1.0);
    CGContextSelectFont(context, "Courier", 12, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetShouldAntialias(context, true);
    char* text = "This is an overlay, check classes";
    CGContextShowTextAtPoint(context, 101, 113, text, strlen(text));
    text = "OverlayManager and Drawable";
    CGContextShowTextAtPoint(context, 101, 100, text, strlen(text));
	CGContextDrawImage(context, rect, image.CGImage);
}

@end
