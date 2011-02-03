//
//  MFSearchOperation.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResultDelegate.h"
#import "mfprofile.h"

@class MFDocumentManager;
@interface TextSearchOperation : NSOperation {

	NSString *searchTerm;						// Search term.
	NSObject<SearchResultDelegate>* delegate;	// Delegate.
	MFProfile profile;							// Search profile.
	MFDocumentManager *document;				// Document manager.
}

@property (retain) MFDocumentManager *document;
@property (readwrite) NSUInteger page;
@property (copy) NSString *searchTerm;
@property (assign) NSObject<SearchResultDelegate>* delegate;
@property (nonatomic,readwrite) MFProfile profile;

@end
