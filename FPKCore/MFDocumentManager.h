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
#import "Stuff.h"

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
    
    NSMutableDictionary * fontCache;
    
    BOOL fontCacheEnabled;
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
-(void)getCropbox:(CGRect *)cropbox andRotation:(int *)rotation forPageNumber:(NSInteger)pageNumber withBuffer:(BOOL)withOrWithout;

/**
 Create a thumbnail for a specific page. It will look far better than the 
 thumbnail integrated inside the pdf, but it is also slower.
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
 Try to unlock the document with a password and return if the unlock has been 
 successful or not.
*/
-(BOOL)tryUnlockWithPassword:(NSString *)aPassword;

/** 
 Return the number of pages that make up the document.
 */
-(NSUInteger)numberOfPages;

/**
 This method will return the page number of the destination with the name passed 
 as argument.
 */
-(NSUInteger)pageNumberForDestinationNamed:(NSString *)name;

/** 
 Clear the page cache. It is important to call this method on memory warning as 
 in the sample code to prevent the application being killed right for excessive 
 memory usage.
 */
-(void)emptyCache;

/**
 Return an array of MFTextItem representing the matches of teh search term on 
 the page passed as arguments. It is a good choice running this method in a 
 secondary thread.
 FPKSearchMode has the following values:
 FPKSearchModeHard - if you search for 'bèzier' it will match 'bèzier' only but not
 'bezier'. If you search for 'bezier' it will match 'bezier' only.
 FPKSearchModeSoft - if you search for term 'bèzier' it will match both 'bezier' and 'bèzier'. Same
 if you search for 'bezier'.
 FPKSearchModeSmart - if you search for term 'bezier', it will also match 'bèzier', but if you
 search for 'bèzier' it will match 'bèzier' only.
 Ignore case is self explanatory.
 Default parameters are FPKSearchModeSmart and ignoreCase to YES.
 */
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr forSearchTerms:(NSString *)searchTerm mode:(FPKSearchMode)mode ignoreCase:(BOOL)ignoreOrNot;

/**
 Compatibility methods for older version. It will call the above method with default values.
 */
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr forSearchTerms:(NSString *)searchTerm;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr forSearchTerms:(NSString *)searchTerm ignoreCase:(BOOL)ignoreOrNot;

/**
 Return a string representation of the text contained in a pdf page.
 */
-(NSString *)wholeTextForPage:(NSUInteger)pageNr;

/**
 Build version of this library. Useful for debugging purposes.
 */
+(NSString *)version;

/**
 Array of every uri annotation for a selected page.
 */
-(NSArray *)uriAnnotationsForPageNumber:(NSUInteger)pageNr;

/**
 Get the parameters for a generic uri, useful to parse options passed with the 
 annotations to customize the behaviour.
 */
+(NSDictionary *)paramsFromURI:(NSString *)uri;

/**
 Resouce folder for the document. Video, audio and other files referenced in the
 pdf are contained here.
 */
@property (nonatomic,retain) NSString * resourceFolder;

/**
 Enable/disable the font cache. Tipically, you want the cache turned on. If you
 get a lot of [] (notdef) characters in the text extracted or the search turn
 up nothing, try to disabled set this to NO. Default value is YES.
 */
@property (nonatomic,assign) BOOL fontCacheEnabled;

/**
 Return an array of FPKGlyphBox, that is, the bounding box of each glyph on the
 page and its unicode representation. Check FPKGlyphBox interface for details.
 */
-(NSArray *)glyphBoxesForPage:(NSUInteger)pageNr;

@end
