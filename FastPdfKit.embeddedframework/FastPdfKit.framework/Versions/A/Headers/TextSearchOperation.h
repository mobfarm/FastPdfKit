//
//  MFSearchOperation.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mfprofile.h"

@protocol TextSearchOperationDelegate;

@class MFDocumentManager;
@interface TextSearchOperation : NSOperation {

	NSString *searchTerm;						// Search term.
	id<TextSearchOperationDelegate> delegate;   // Delegate.
	MFProfile profile;							// Search profile.
	MFDocumentManager *document;				// Document manager.
    
    BOOL ignoreCase;
    BOOL exactMatch;
}

@property (nonatomic, retain) MFDocumentManager *document;
@property (nonatomic, readwrite) NSUInteger page;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, assign) id<TextSearchOperationDelegate> delegate;
@property (nonatomic,readwrite) MFProfile profile;

@property (nonatomic, readwrite) BOOL ignoreCase;
@property (nonatomic, readwrite) BOOL exactMatch;

@end

@protocol TextSearchOperationDelegate

-(void)textSearchOperation:(TextSearchOperation *)operation didCompleteWithResults:(NSArray *)results;

@end
