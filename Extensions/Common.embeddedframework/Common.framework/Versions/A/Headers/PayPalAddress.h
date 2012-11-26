//
//  PayPalAddress.m
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


@interface PayPalAddress : NSObject {
	NSString *name;
	NSString *street1;
	NSString *street2;
	NSString *city;
	NSString *state;
	NSString *postalcode;
	NSString *countrycode;
}
@property (readonly) NSString *name;
@property (readonly) NSString *street1;
@property (readonly) NSString *street2;
@property (readonly) NSString *city;
@property (readonly) NSString *state;
@property (readonly) NSString *postalcode;
@property (readonly) NSString *countrycode;
@end
