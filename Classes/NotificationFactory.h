//
//  NotificationFactory.h
//  FastPdfKit Sample
//
//  Created by Nicolò Tosi on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * kNotificationSearchResultAvailable = @"FPKSearchResultAvailableNotification";

static NSString * kNotificationSearchDidStart = @"FPKSearchDidStart";

static NSString * kNotificationSearchDidStop = @"FPKSearchDidStop";

static NSString * kNotificationSearchGotCancelled = @"FPKSearchGotCancelled";

static NSString * kNotificationSearchInfoResults = @"searchResults";
static NSString * kNotificationSearchInfoPage = @"page";
static NSString * kNotificationSearchInfoSearchTerm = @"searchTerm";

@interface NotificationFactory : NSObject {
    
}

+(NSNotification *)notificationSearchResultsAvailable:(NSArray *)results forSearchTerm:(NSString *)searchTerm onPage:(NSNumber *)page fromSender:(id)sender; 
+(NSNotification *)notificationSearchDidStartWithSearchTerm:(NSString *)searchTerm onPage:(NSNumber *)page fromSender:(id)sender; 
+(NSNotification *)notificationSearchDidStopWithSearchTerm:(NSString *)searchTerm fromSender:(id)sender; 
+(NSNotification *)notificationSearchGotCancelledWithSearchTerm:(NSString *)searchTerm fromSender:(id)sender;

@end
