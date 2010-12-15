//
//  MFDocumentManager.h
//  OffscreenRendererTest
//
//  Created by Nicolò Tosi on 4/20/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class MFOffscreenRenderer;

@interface MFDocumentManager : NSObject <UIAlertViewDelegate>{

	MFOffscreenRenderer *renderer;
	
	CGPDFDocumentRef document;
	NSLock * lock;
	NSURL * url;
	
	NSUInteger numberOfPages;
	
	NSString * password;
}

-(CGImageRef)createImageFromPDFPagesLeft:(NSInteger)leftPage andRight:(NSInteger)rightPage size:(CGSize)size andScale:(CGFloat)scale useLegacy:(BOOL)legacy;
-(CGImageRef)createImageFromPDFPage:(NSInteger)page size:(CGSize)size  andScale:(CGFloat)scale useLegacy:(BOOL)legacy;
-(CGImageRef)createImageForThumbnailOfPageNumber:(NSUInteger)pageNr ofSize:(CGSize)size andScale:(CGFloat)scale;

// Factory method.
+(MFDocumentManager *)documentManagerWithFilePath:(NSString *)filePath;

// Return an array of MFOutlineEntry as outline/TOC.
-(NSMutableArray *)outline;

// Init.
-(id)initWithFileUrl:(NSURL*)anUrl;
	
// Check if a document is encrypted and blocked by a password or not.
-(BOOL)isLocked;

// Try to unlock the document with a password.
-(BOOL)tryUnlockWithPassword:(NSString *)aPassword;

// Return the number of pages that make up the document.
-(NSUInteger)numberOfPages;

// Clear the page cache.
-(void)emptyCache;

// Draw the selected page on the graphic context.
-(void)drawPageNumber:(NSInteger)pageNumber onContext:(CGContextRef)ctx;

// Get cropbox and rotation angle for the selected page.
-(void)getCropbox:(CGRect *)cropbox andRotation:(int *)rotation forPageNumber:(NSInteger)pageNumber;

// Return the outline for the document
//-(MFPDFOutline *)newOutline;

@end
