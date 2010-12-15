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

@property NSInteger indentation;
@property NSUInteger pageNumber;
@property (retain) NSArray * bookmarks;
@property (copy) NSString * title;

@end
