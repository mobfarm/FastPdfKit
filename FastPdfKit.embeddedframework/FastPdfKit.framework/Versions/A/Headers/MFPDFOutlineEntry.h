//
//  MFPDFBookmark.h
//  PDFOutlineTest
//
//  Created by Nicolò Tosi on 5/16/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MFPDFOutlineEntry : NSObject {
	
	// Presentation
	NSString * title;
	NSInteger indentation;
	
	// Link
	NSUInteger pageNumber;
	
	// Structure
	NSArray * bookmarks;
	
}

/**
 Indentation level of the outline entry. It is also the node level inside the outline tree.
 */
@property NSInteger indentation;

/**
 Page number of the entry.
 */
@property NSUInteger pageNumber;

/**
 Child entries.
 */
@property (retain) NSArray * bookmarks;

/**
 Title for the outline entry.
 */
@property (copy) NSString * title;

@end
