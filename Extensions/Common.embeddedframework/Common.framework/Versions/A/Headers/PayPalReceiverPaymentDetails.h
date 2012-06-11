//
//  PayPalReceiverPaymentDetails.h
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
#import "PayPalInvoiceData.h"

@interface PayPalReceiverPaymentDetails : NSObject <NSCopying> {
	@private
	
//required
	NSString *recipient;                    //email or phone number
	NSDecimalNumber *subTotal;              //subTotal amount for that receiver
	
//optional
	BOOL isPrimary;                         //This should be set only if we have a chained payment scenario.
	PayPalPaymentType paymentType;          //if not set, the value passed into getPayButton will be used
	PayPalPaymentSubType paymentSubType;    //if not set, the value passed into getPayButton will be used
	PayPalInvoiceData *invoiceData;
	NSString *description;                  //Payment note for each payment in the advanced payment
	NSString *customId;                     //custom id field per recipient
	NSString *merchantName;                 // To display for each recipient on the review screen
}

@property (nonatomic, retain) NSString *recipient;
@property (nonatomic, retain) NSDecimalNumber *subTotal;

@property (nonatomic, assign) BOOL isPrimary;
@property (nonatomic, assign) PayPalPaymentType paymentType;
@property (nonatomic, assign) PayPalPaymentSubType paymentSubType;
@property (nonatomic, retain) PayPalInvoiceData *invoiceData;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *customId;
@property (nonatomic, retain) NSString *merchantName;

@property (nonatomic, readonly) NSDecimalNumber *total; //subtotal + tax + shipping

@end
