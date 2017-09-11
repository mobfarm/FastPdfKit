//
//  MFPDFBookmark.h
//  PDFOutlineTest
//
//  Created by Nicolò Tosi on 5/16/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FPKDestination;

@interface MFPDFOutlineEntry : NSObject

/**
 * Indentation level of the outline entry. It is also the node level inside the outline tree.
 */
@property (readwrite, nonatomic) NSInteger indentation;

/**
 * Page number of the entry.
 */
@property (strong, nonatomic) id<FPKDestination> destination;

/**
 * Child entries.
 */
@property (strong, nonatomic) NSArray * bookmarks;

/**
 * Title for the outline entry.
 */
@property (copy, nonatomic) NSString * title;

/**
 * Default constructor.
 */
-(id)initWithTitle:(NSString *)aTitle;

@end
