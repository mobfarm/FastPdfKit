//
//  SearchManager.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/10/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDocumentOverlayDataSource.h"
#import "FPKOverlayViewDataSource.h"

static NSString * const kNotificationSearchResultAvailable = @"FPKSearchResultAvailableNotification";
static NSString * const kNotificationSearchDidStart = @"FPKSearchDidStart";
static NSString * const kNotificationSearchDidStop = @"FPKSearchDidStop";
static NSString * const kNotificationSearchGotCancelled = @"FPKSearchGotCancelled";
static NSString * const kNotificationSearchInfoResults = @"searchResults";
static NSString * const kNotificationSearchInfoPage = @"page";
static NSString * const kNotificationSearchInfoSearchTerm = @"searchTerm";

@class MFDocumentManager;

@interface SearchManager : UIView <MFDocumentOverlayDataSource, FPKOverlayViewDataSource>

@property (nonatomic, weak) MFDocumentManager * document;
@property (nonatomic, copy) NSString * searchTerm;

@property (nonatomic, readwrite) NSUInteger maxPage;
@property (nonatomic, readwrite) NSUInteger startingPage;
@property (nonatomic, readwrite) BOOL running;
@property (nonatomic, readwrite) BOOL loop;
@property (nonatomic, readwrite) BOOL ignoreCase;
@property (nonatomic, readwrite) BOOL exactMatch;


-(NSArray *)searchResultOnPage:(NSUInteger)page;

@property (nonatomic, readonly) NSArray * allSearchResults;
@property (nonatomic, strong) NSMutableDictionary * pagedSearchResults;
@property (nonatomic, strong) NSMutableArray * sequentialSearchResults;

-(void)stopSearch;

-(void)startSearch;

@end
