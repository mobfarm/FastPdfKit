//
//  PayPalInvoiceData.h
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


@interface PayPalInvoiceData : NSObject <NSCopying> {
	@private
	
//optional
	NSDecimalNumber *totalTax;
	NSDecimalNumber *totalShipping;
	NSMutableArray *invoiceItems; // Array of PayPalInvoiceItems
}

@property (nonatomic, retain) NSDecimalNumber *totalTax;
@property (nonatomic, retain) NSDecimalNumber *totalShipping;
@property (nonatomic, retain) NSMutableArray *invoiceItems;

@end
