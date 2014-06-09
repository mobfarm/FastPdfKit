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
	
	NSURL * url;
    CGDataProviderRef provider;
    
    NSString * resourceFolder;  /* If nil, will default to Documents folder */
	
	NSUInteger numberOfPages;
	
	NSLock * pageDataLock;
    
	int *dataSetFlags;
	CGRect *cropboxes;
	int *rotations;
    
    NSMutableDictionary * fontCache;
    
    BOOL fontCacheEnabled;
    
    BOOL alternateURISchemesEnabled;
}

// These method are used internally.
-(CGImageRef)createImageFromPDFPagesLeft:(NSInteger)leftPage andRight:(NSInteger)rightPage size:(CGSize)size andScale:(CGFloat)scale useLegacy:(BOOL)legacy;
-(CGImageRef)createImageFromPDFPage:(NSInteger)page size:(CGSize)size  andScale:(CGFloat)scale useLegacy:(BOOL)legacy;

-(CGImageRef)createImageFromPDFPagesLeft:(NSInteger)leftPage andRight:(NSInteger)rightPage size:(CGSize)size andScale:(CGFloat)scale useLegacy:(BOOL)legacy showShadow:(BOOL)shadow andPadding:(CGFloat)padding;
-(CGImageRef)createImageFromPDFPage:(NSInteger)page size:(CGSize)size  andScale:(CGFloat)scale useLegacy:(BOOL)legacy showShadow:(BOOL)shadow andPadding:(CGFloat)padding;

-(CGImageRef)createImageWithPage:(NSUInteger)page pixelScale:(float)scale imageScale:(NSUInteger)scaling screenDimension:(CGFloat)dimension;

-(CGImageRef)createImageWithImage:(CGImageRef)imageToBeDrawn;

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
 * Clear the page cache. It is important to call this method on memory warning 
 * as in the sample code to prevent the application being killed right for 
 * excessive memory usage.
 */
-(void)emptyCache;

/**
 * Return an array of MFTextItem representing the matches of teh search term on 
 * the page passed as arguments. It is a good idea running this method in a 
 * secondary thread.
 *
 * mode is of type FPKSearchMode and has the following values:
 * FPKSearchModeHard - if you search for 'bèzier' it will match 'bèzier' only 
 * but not 'bezier'. If you search for 'bezier' it will match 'bezier' only.
 * FPKSearchModeSoft - if you search for term 'bèzier' it will match both 
 * 'bezier' and 'bèzier'. Same if you search for 'bezier'.
 * FPKSearchModeSmart - if you search for term 'bezier', it will also match 
 * 'bèzier', but if you search for 'bèzier' it will match 'bèzier' only.
 *
 * ignoreOrNot tell the function if it should ignore case or not.
 *
 * exactMatchOrNot tell the function if it should match the term as a whole or 
 * search for each component separated by spaces.
 *
 * Default parameters are FPKSearchModeSmart, ignoreCase to YES and exactMatch 
 * to NO.
 */
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                          mode:(FPKSearchMode)mode 
                    ignoreCase:(BOOL)ignoreOrNot 
                    exactMatch:(BOOL)exactMatchOrNot;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                          mode:(FPKSearchMode)mode 
                    ignoreCase:(BOOL)ignoreOrNot;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                    ignoreCase:(BOOL)ignoreOrNot 
                    exactMatch:(BOOL)exactMatchorNot;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                          mode:(FPKSearchMode)mode 
                    exactMatch:(BOOL)exactMatchOrNot;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                          mode:(FPKSearchMode)mode;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                    ignoreCase:(BOOL)ignoreOrNot;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm 
                    exactMatch:(BOOL)exactMatchOrNot;
-(NSArray *)searchResultOnPage:(NSUInteger)pageNr 
                forSearchTerms:(NSString *)searchTerm; 


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

/**
 Enable alternate URI annotations schemes like video://, videoremote://, audio://,
 audioremote://, etcetera.
 Default value is YES.
 */
@property (nonatomic,assign) BOOL alternateURISchemesEnabled;

/**
 This will return a Cocoa representation of the annotations array for each page.
 The returned value is actually a ditionary, where the value you are looking for
 is store with the key "object".
 The other entries are there to allow the handling of circular refernces while
 maintaining proper memory management.
 
 By Cocoa representation is meant the following conversions from PDF to Cocoa
 objects:
 
 array -> NSArray
 dictionary -> NSDictionary
 name -> NSString
 number -> NSNumber
 real -> NSNumber
 string -> NSString
 
 The exception is the stream object, that is represented by a dictionary
 
 stream -> NSDictionary
 
 that stores stream data, the stream dictionary and the stream format. The stream
 data is an NSData object with key @"streamData", the stream format is an 
 NSString with the key @"streamFormat" whose value are @"raw", @"jpegEncoded" or
 @"jpeg2000" and the dictionary is an NSDictionary with the key @"streamDictionary".
 
 In other words, if you are looking for Text annotations and you want the position
 of the annotation and the text associated with it, you'll do something
 like this:
 1. Invoke the method and get the dictionary
 2. Get the object associated with the @"object" key in the dictionary. This
 object will be an Array according to the pdf reference
 3. Each entry in the array will be a dictionary
 4. For each of this dictionary, check the key @"subtype", should be @"Text" for
 a Text annotation
 5. Get the @"Rect" array to calculate the rect for the annotation
 6. Get the @"Contents" string to get the text for the annotation
 
 like
 
 NSDictionary * annotationsDict = [self.document cocoaAnnotationsForPage:self.page];
    NSArray * annotations = [annotationsDict objectForKey:@"object"];
    for (NSDictionary * annotation in annotations) {
        NSLog(@"Found Annotations with Subtype: %@", [annotation valueForKey:@"Subtype"]);
        if ([[annotation valueForKey:@"Subtype"] isEqualToString:@"Text"]){
            NSLog(@"Note: %@", [annotation objectForKey:@"Contents"]);
        }
        if([annotation valueForKey:@"Rect"]) {
            // Handle annotation rect (array of floats, two pairs of point) here
            NSArray * rect = [annotation valueForKey:@"Rect"];
            CGPoint p0 = CGPointMake([[rect objectAtIndex:0]floatValue], [[rect objectAtIndex:1]floatValue]);
            CGPoint p1 = ...
        }
        if([annotation valueForKey:@"Popup"]) {
            NSDictionary * popup = [annotation valueForKey:@"Popup"];
            if([popup valueForKey:@"Rect"]) {
 
                // Handle the annotation's popup frame
            }
        }
    }
 
 */
-(NSDictionary *)cocoaAnnotationsForPage:(NSUInteger)pageNr;

@end
