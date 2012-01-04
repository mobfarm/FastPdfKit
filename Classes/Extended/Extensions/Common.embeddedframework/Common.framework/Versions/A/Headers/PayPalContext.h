//
//  PayPalContext.h
//
//  MPL Library - Developer Interface
//
//  Created by Paypal 2010
//  Modified by:
//			DiZoglio, James(jdizoglio) on 5/10/11.
//
//  Copyright 2011 Paypal. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "PayPal.h"

@interface PayPalContext : NSObject {
@private
	NSString *sessionToken;
	NSString *amount;
	NSString *tax;
	NSString *shipping;
	NSString *currencyCode;
	NSString *itemDesc;
	BOOL shippable;
	NSString *recipientEmail;
	NSString *merchantName;
	BOOL recipientPaysFee;
	BOOL enableDynamicAmountUpdate;
	PayPalEnvironment environment;
}

@property (nonatomic, retain) NSString *sessionToken;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSString *tax;
@property (nonatomic, retain) NSString *shipping;
@property (nonatomic, retain) NSString *currencyCode;
@property (nonatomic, retain) NSString *itemDesc;
@property BOOL shippable;
@property (nonatomic, retain) NSString *recipientEmail;
@property (nonatomic, retain) NSString *merchantName;
@property PayPalEnvironment environment;
@property BOOL recipientPaysFee;
@property BOOL enableDynamicAmountUpdate;

-(NSDictionary*)serialize;
-(BOOL)deserialize:(NSDictionary*)contextData;

@end
