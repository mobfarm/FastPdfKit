//
//  PayPalAdvancedPayment.h
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
#import "PayPalReceiverPaymentDetails.h"

@interface PayPalAdvancedPayment : NSObject <NSCopying> {
	@private
	
//required
	NSString *paymentCurrency;              //you can specify only one currency, regardless of the number of receivers
	NSMutableArray *receiverPaymentDetails; //array of PPReceiverPaymentDetails
	
//optional
	NSString *merchantName;                 //this will be displayed at the top of all library screens
	NSString *ipnUrl;
	NSString *memo;
}

@property (nonatomic, retain) NSString *paymentCurrency;
@property (nonatomic, retain) NSMutableArray *receiverPaymentDetails;

//if set, the value of this property will be displayed at the top of all library screens
@property (nonatomic, retain) NSString *merchantName;

@property (nonatomic, retain) NSString *ipnUrl;
@property (nonatomic, retain) NSString *memo;

@property (nonatomic, readonly) NSDecimalNumber *subtotal; //summed over all receivers
@property (nonatomic, readonly) NSDecimalNumber *tax;      //summed over all receivers
@property (nonatomic, readonly) NSDecimalNumber *shipping; //summed over all receivers
@property (nonatomic, readonly) NSDecimalNumber *total;    //subtotal + tax + shipping, summed over all receivers

//returns primary receiver if we are doing chain payment
//returns single receiver if we only have one receiver
@property (nonatomic, readonly) PayPalReceiverPaymentDetails *singleReceiver;

//convenience property indicating if this is a personal payment
//this will return TRUE if any receiver has a payment type of personal
@property (nonatomic, readonly) BOOL isPersonal;

- (NSString *)getMerchantName;

@end
