//
//  MFSearchOperation.h
//  FastPdfKit
//
//  Created by Nicolò Tosi on 10/21/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mfprofile.h"

@class MFDocumentManager;

@protocol TextSearchOperationDelegate

-(void)handleSearchResult:(NSArray *)results;

@end

@interface TextSearchOperation : NSOperation

@property (retain) MFDocumentManager *document;
@property (readwrite) NSUInteger page;
@property (copy) NSString *searchTerm;
@property (assign) id<TextSearchOperationDelegate> delegate;
@property (nonatomic,readwrite) MFProfile profile;

@property (nonatomic, readwrite) BOOL ignoreCase;
@property (nonatomic, readwrite) BOOL exactMatch;

@end
