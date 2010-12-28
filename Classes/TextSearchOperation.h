//
//  MFSearchOperation.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResultDelegate.h"

@class MFDocumentManager;
@interface TextSearchOperation : NSOperation {

	NSString *searchTerm;
	NSObject<SearchResultDelegate>* delegate;
	
	MFDocumentManager *document;
}
@property (retain) MFDocumentManager *document;
@property (readwrite) NSUInteger page;
@property (copy) NSString *searchTerm;
@property (assign) NSObject<SearchResultDelegate>* delegate;
@end
