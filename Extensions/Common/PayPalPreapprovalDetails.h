//
//  PayPalPreapprovalDetails.h
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

typedef enum PayPalDayOfWeek {
	PP_DAYOFWEEK_NO_DAY_SPECIFIED = -1,
	PP_DAYOFWEEK_SUNDAY,
	PP_DAYOFWEEK_MONDAY,
	PP_DAYOFWEEK_TUESDAY,
	PP_DAYOFWEEK_WEDNESDAY,
	PP_DAYOFWEEK_THURSDAY,
	PP_DAYOFWEEK_FRIDAY,
	PP_DAYOFWEEK_SATURDAY,
} PayPalDayOfWeek;

typedef enum PayPalPaymentPeriod {
	PP_PAYMENTPERIOD_NO_PERIOD_SPECIFIED = -1,
	PP_PAYMENTPERIOD_DAILY,
	PP_PAYMENTPERIOD_WEEKLY,
	PP_PAYMENTPERIOD_BIWEEKLY,
	PP_PAYMENTPERIOD_SEMIMONTHLY,
	PP_PAYMENTPERIOD_MONTHLY,
	PP_PAYMENTPERIOD_ANNUALLY,
} PayPalPaymentPeriod;

@interface PayPalPreapprovalDetails : NSObject {
	@private
	
//required
	NSString *merchantName;                         //name of merchant to display in checkout flow
	NSString *currency;
	NSDecimalNumber *maxTotalAmountOfAllPayments;
	NSDate *startDate;
	NSDate *endDate;
	
//optional
	BOOL approved;                                  //status of the preaproval
	BOOL pinRequired;
	NSDecimalNumber *maxPerPayment;
	NSUInteger maxNumPayments;
	NSUInteger maxNumPaymentsPerPeriod;
	PayPalPaymentPeriod paymentPeriod;
	NSUInteger dateOfMonth;
	PayPalDayOfWeek dayOfWeek;
	NSString *ipnUrl;
	NSString *memo;
	NSString *senderEmail;
}

@property (nonatomic, retain) NSString *merchantName;
@property (nonatomic, assign) NSUInteger maxNumPayments;
@property (nonatomic, retain) NSDecimalNumber *maxPerPayment;
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSDecimalNumber *maxTotalAmountOfAllPayments;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

@property (nonatomic, assign) BOOL approved;        //status of the preaproval
@property (nonatomic, assign) BOOL pinRequired;
@property (nonatomic, assign) PayPalPaymentPeriod paymentPeriod;
@property (nonatomic, assign) NSUInteger dateOfMonth;
@property (nonatomic, assign) PayPalDayOfWeek dayOfWeek;
@property (nonatomic, assign) NSUInteger maxNumPaymentsPerPeriod;
@property (nonatomic, retain) NSString *ipnUrl;
@property (nonatomic, retain) NSString *memo;
@property (nonatomic, retain) NSString *senderEmail;

@end
