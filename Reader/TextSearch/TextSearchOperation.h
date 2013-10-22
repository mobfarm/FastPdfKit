//
//  MFSearchOperation.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mfprofile.h"

@class MFDocumentManager;
@interface TextSearchOperation : NSOperation {

	NSString *searchTerm;						// Search term.
	id<NSObject> __weak delegate;                      // Delegate.
	MFProfile profile;							// Search profile.
	MFDocumentManager *document;				// Document manager.
    
    BOOL ignoreCase;
    BOOL exactMatch;
}

@property (strong) MFDocumentManager *document;
@property (readwrite) NSUInteger page;
@property (copy) NSString *searchTerm;
@property (weak) id<NSObject> delegate;
@property (nonatomic,readwrite) MFProfile profile;

@property (nonatomic, readwrite) BOOL ignoreCase;
@property (nonatomic, readwrite) BOOL exactMatch;

@end
