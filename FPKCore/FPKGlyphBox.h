//
//  MFGlyphBox.h
//  FastPdfKitLibrary
//
//  Created by Nicolò Tosi on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface FPKGlyphBox : NSObject {
    
    CGRect box;
    
    BOOL synthesized;
    unsigned int * unicodes;
    int unicodes_len;
}

-(id)initWithBox:(CGRect)box unicodes:(unsigned int *)unicodes length:(int)len;

@property (nonatomic,readwrite) BOOL synthesized;

/**
 Bounding box of the glyph in page space.
 */
@property (nonatomic,readwrite) CGRect box;

/**
 UTF-8 string representation of the text of this glyph box, usually is just a 
 single unicode codepoint. It is synthesized from an opaque representation.
 */
-(NSString *)text;

/**
 Class method to convert an array of MFGlyphBox into an human-readable string. It
 does not call a concatenation of -text message, so it is faster.
 */
+(NSString *)textFromBoxArray:(NSArray *)array;

@end
