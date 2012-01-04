//
//  PayPalInvoiceItem.h
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


@interface PayPalInvoiceItem : NSObject <NSCopying> {
	@private
	
//optional
	NSString *name;
	NSString *itemId;
	NSDecimalNumber *totalPrice;
	NSDecimalNumber *itemPrice;
	NSNumber *itemCount;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSDecimalNumber *totalPrice;
@property (nonatomic, retain) NSDecimalNumber *itemPrice;
@property (nonatomic, retain) NSNumber *itemCount;

@end
