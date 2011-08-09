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
#import "mfprofile.h"

@class MFOffscreenRenderer;

@interface MFDocumentManager : NSObject <UIAlertViewDelegate>{

	MFOffscreenRenderer *renderer;
	
	CGPDFDocumentRef document;
	NSLock * lock;
	NSURL * url;
    CGDataProviderRef provider;
    
    NSString * resourceFolder;  /* If nil, will default to Documents folder */
	
	NSUInteger numberOfPages;
	
	NSString * password;
	
	NSLock * pageDataLock;
	int *dataSetFlags;
	CGRect *cropboxes;
	int *rotations;
	
	MFProfile defaultProfile;
}

// These method are used internally.
-(CGImageRef)createImageFromPDFPagesLeft:(NSInteger)leftPage andRight:(NSInteger)rightPage size:(CGSize)size andScale:(CGFloat)scale useLegacy:(BOOL)legacy;
-(CGImageRef)createImageFromPDFPage:(NSInteger)page size:(CGSize)size  andScale:(CGFloat)scale useLegacy:(BOOL)legacy;

-(CGImageRef)createImageFromPDFPagesLeft:(NSInteger)leftPage andRight:(NSInteger)rightPage size:(CGSize)size andScale:(CGFloat)scale useLegacy:(BOOL)legacy showShadow:(BOOL)shadow andPadding:(CGFloat)padding;
-(CGImageRef)createImageFromPDFPage:(NSInteger)page size:(CGSize)size  andScale:(CGFloat)scale useLegacy:(BOOL)legacy showShadow:(BOOL)shadow andPadding:(CGFloat)padding;


-(void)drawPageNumber:(NSInteger)pageNumber onContext:(CGContextRef)ctx;

/**
 Use this method to get the cropbox and the rotation of a certain pdf page.
 */
-(void)getCropbox:(CGRect *)cropbox andRotation:(int *)rotation forPageNumber:(NSInteger)pageNumber;

/**
 Create a thumbnail for a specific page. It will look far better than the thumbnail integrated inside the pdf, but
 it is also slower.
 */
-(CGImageRef)createImageForThumbnailOfPageNumber:(NSUInteger)pageNr ofSize:(CGSize)size andScale:(CGFloat)scale;

/** 
 Factory method to create an MFDocumentManager instance from a know file path.
 */
+(MFDocumentManager *)documentManagerWithFilePath:(NSString *)filePath;

/** 
 Return an array of MFOutlineEntry as the outline/TOC of the pdf document.
 */
-(NSMutableArray *)outline;

/**
 Initializer. You can also use the factory method above. 
 */
-(id)initWithFileUrl:(NSURL*)anUrl;

/**
 Initializer with data provider.
 */
-(id)initWithDataProvider:(CGDataProviderRef)dataProvider;
	
/** 
 Check if a document is encrypted and blocked by a password or not.
 */
-(BOOL)isLocked;

/**
 Try to unlock the document with a password and return if the unlock has been successful or not.
*/
-(BOOL)tryUnlockWithPassword:(NSString *)aPassword;

/** 
 Return the number of pages that make up the document.
 */
-(NSUInteger)numberOfPages;

/**
 This method will return the page number of the destination with the name passed as argument.
 */
-(NSUInteger)pageNumberForDestinationNamed:(NSString *)name;

/** 
 Clear the page cache. It is important to call this method on memory warning as in the sample code
 to prevent the application being killed right for excessive memory usage.
 */
-(void)emptyCache;

/**
 Return an array of MFTextItem representing the matches of teh search term on the page passed
 as arguments. It is a good choice running this method in a secondary thread. Pass NULL as profile
 to use default search profile. Profile is not retained, so be sure to keep it in memory until the function
 returns.
 */
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr forSearchTerms:(NSString *)searchTerm withProfile:(MFProfile *)p;

/**
 This method return the same result as the above, but uses a differnt search engine. Look at the readme for instructions.
 */
-(NSArray *)test_searchResultOnPage:(NSUInteger)pageNr forSearchTerms:(NSString *)searchTerm;

/**
 Return a string representation of the text contained in a pdf page. Profile is not retained, so be sure to keep
 it in memory until the function returns. You can pass NULL to use the default profile.
 */
-(NSString *)wholeTextForPage:(NSUInteger)pageNr withProfile:(MFProfile *)p;

/**
 This method return the same result as the above, but uses a differnt extraction engine. Look at the readme for instructions.
 */
-(NSString *)test_wholeTextForPage:(NSUInteger)pageNr;

/**
 Build version of this library. Useful for debugging purposes.
 */
+(NSString *)version;

/**
 This is an experimental features. It will allow to customize the behaviour for search and extraction of text. You can
 set the values inside of this struct before launching a search or a text extraction action. Look at mfprofile.h for an explanation of the MFProfile struct and how to customize it. This is the default profile used as fallback when
 a NULL profile is passed to the search and extraction methods.
 */
@property (nonatomic,readwrite) MFProfile defaultProfile;

/**
 Resouce folder for the document. Video, audio and other files referenced in the pdf are contained here.
 */
@property (nonatomic,retain) NSString * resourceFolder;

@end
