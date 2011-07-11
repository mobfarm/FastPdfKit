//
//  NotificationFactory.m
//  FastPdfKit Sample
//
//  Created by Nicolò Tosi on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationFactory.h"


@implementation NotificationFactory


+(NSNotification *)notificationSearchResultsAvailable:(NSArray *)results forSearchTerm:(NSString *)searchTerm onPage:(NSNumber *)page fromSender:(id)sender {
    
    NSNotification * notification = nil;
    NSDictionary * info = nil;
    
    info = [[NSDictionary alloc]initWithObjectsAndKeys: page,
                                                        kNotificationSearchInfoPage,
                                                        results,
                                                        kNotificationSearchInfoResults,
                                                        searchTerm,
                                                        kNotificationSearchInfoSearchTerm,
            nil];
                                                        
    notification = [NSNotification notificationWithName:kNotificationSearchResultAvailable object:self userInfo:info];
    
    [info release];
    
    return notification;
}


+(NSNotification *)notificationSearchDidStartWithSearchTerm:(NSString *)searchTerm onPage:(NSNumber *)page fromSender:(id)sender {
    NSNotification * notification = nil;
    NSDictionary * info = nil;
    
    info = [[NSDictionary alloc]initWithObjectsAndKeys: page,
                                                        kNotificationSearchInfoPage,
                                                        searchTerm,
                                                        kNotificationSearchInfoSearchTerm,
            nil];
    
    notification = [NSNotification notificationWithName:kNotificationSearchDidStart object:self userInfo:info];
    
    [info release];
    
    return notification;
}

+(NSNotification *)notificationSearchDidStopWithSearchTerm:(NSString *)searchTerm fromSender:(id)sender {
    NSNotification * notification = nil;
    NSDictionary * info = nil;
    
    info = [[NSDictionary alloc]initWithObjectsAndKeys: searchTerm,
                                                        kNotificationSearchInfoSearchTerm,
            nil];
    
    notification = [NSNotification notificationWithName:kNotificationSearchDidStop object:self userInfo:info];
    
    [info release];
    
    return notification;
}

+(NSNotification *)notificationSearchGotCancelledWithSearchTerm:(NSString *)searchTerm fromSender:(id)sender {
    NSNotification * notification = nil;
    NSDictionary * info = nil;
    
    info = [[NSDictionary alloc]initWithObjectsAndKeys: 
            searchTerm,
            kNotificationSearchInfoSearchTerm,
            nil];
    
    notification = [NSNotification notificationWithName:kNotificationSearchGotCancelled object:self userInfo:info];
    
    [info release];
    
    return notification;
}

@end
