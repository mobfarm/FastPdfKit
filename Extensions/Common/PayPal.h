//
//  PayPal.h
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

#import <UIKit/UIKit.h>

@class PPMEPRootViewController;
@class PayPalContext;
@class PayPalAmounts;
@class PayPalAddress;

@class PayPalPayment;
@class PayPalAdvancedPayment;

@class PayPalPreapprovalDetails;

typedef enum PayPalPaymentStatus {
	STATUS_COMPLETED,
	STATUS_CREATED,
	STATUS_OTHER,
} PayPalPaymentStatus;

typedef enum PayPalEnvironment {
	ENV_LIVE,
	ENV_SANDBOX,
	ENV_NONE,
} PayPalEnvironment;

typedef enum PayPalButtonType {
	BUTTON_152x33,
	BUTTON_194x37,
	BUTTON_278x43,
	BUTTON_294x43,
	BUTTON_TYPE_COUNT,
} PayPalButtonType;

typedef enum PayPalButtonText {
	BUTTON_TEXT_PAY, //default
	BUTTON_TEXT_DONATE,
} PayPalButtonText;

typedef enum PayPalFeePayer {
	FEEPAYER_SENDER,
	FEEPAYER_PRIMARYRECEIVER,
	FEEPAYER_EACHRECEIVER,
	FEEPAYER_SECONDARYONLY,
} PayPalFeePayer;

typedef enum PayPalFailureType {
	SYSTEM_ERROR,
	RECIPIENT_ERROR,
	APPLICATION_ERROR,
	CONSUMER_ERROR,
} PayPalFailureType;

typedef enum PayPalPaymentType {
	TYPE_NOT_SET = -1,
	TYPE_GOODS,
	TYPE_SERVICE,
	TYPE_PERSONAL,
} PayPalPaymentType;

typedef enum PayPalPaymentSubType {
	SUBTYPE_NOT_SET = -1,
	SUBTYPE_AFFILIATE_PAYMENTS,
	SUBTYPE_B2B,
	SUBTYPE_PAYROLL,
	SUBTYPE_REBATES,
	SUBTYPE_REFUNDS,
	SUBTYPE_REIMBURSEMENTS,
	SUBTYPE_DONATIONS,
	SUBTYPE_UTILITIES,
	SUBTYPE_TUITION,
	SUBTYPE_GOVERNMENT,
	SUBTYPE_INSURANCE,
	SUBTYPE_REMITTANCES,
	SUBTYPE_RENT,
	SUBTYPE_MORTGAGE,
	SUBTYPE_MEDICAL,
	SUBTYPE_CHILD_CARE,
	SUBTYPE_EVENT_PLANNING,
	SUBTYPE_GENERAL_CONTRACTORS,
	SUBTYPE_ENTERTAINMENT,
	SUBTYPE_TOURISM,
	SUBTYPE_INVOICE,
	SUBTYPE_TRANSFER,
} PayPalPaymentSubType;

typedef enum PayPalAmountErrorCode {
	AMOUNT_ERROR_NONE,
	AMOUNT_ERROR_SERVER,
	AMOUNT_ERROR_OTHER,
	AMOUNT_CANCEL_TXN,
} PayPalAmountErrorCode;

typedef enum PayPalInitializationStatus {
	STATUS_NOT_STARTED,
	STATUS_COMPLETED_SUCCESS,
	STATUS_COMPLETED_ERROR,
	STATUS_INPROGRESS,
} PayPalInitializationStatus;

@protocol PayPalPaymentDelegate
@required
- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus;
- (void)paymentFailedWithCorrelationID:(NSString *)correlationID;
- (void)paymentCanceled;
- (void)paymentLibraryExit;

/*
 Example: To parse the responseMessage containing the following key fields. You can check the responseMessage
 from couldNotFetchDeviceReferenceToken or receivedDeviceReferenceToken. You can create a local application log 
 to capture this output. The errors captured are both Network(Request) and Application catagory errors.
 
 NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
 NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
 NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
 NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
 */

@optional
- (PayPalAmounts *)adjustAmountsForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andAmount:(NSDecimalNumber const *)inAmount andTax:(NSDecimalNumber const *)inTax andShipping:(NSDecimalNumber const *)inShipping andErrorCode:(PayPalAmountErrorCode *)outErrorCode;
- (NSMutableArray *)adjustAmountsAdvancedForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andReceiverAmounts:(NSMutableArray *)receiverAmounts andErrorCode:(PayPalAmountErrorCode *)outErrorCode;

- (PayPalAmounts *)adjustAmountsForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andAmount:(NSDecimalNumber const *)inAmount andTax:(NSDecimalNumber const *)inTax andShipping:(NSDecimalNumber const *)inShipping __attribute__((deprecated));
- (NSMutableArray *)adjustAmountsAdvancedForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andReceiverAmounts:(NSMutableArray *)receiverAmounts __attribute__((deprecated));
@end

@interface PayPal : NSObject <UIWebViewDelegate> {
	@private 
	id<PayPalPaymentDelegate> delegate;
	BOOL paymentsEnabled;                           //readonly, TRUE if the device is allowed to make payments
	BOOL shippingEnabled;
	BOOL dynamicAmountUpdateEnabled;
	
	NSString *appID;
	NSString *lang;
	
	PayPalEnvironment environment;
	PayPalButtonText buttonText;
	PayPalFeePayer feePayer;

	PayPalAdvancedPayment *payment;
	PayPalPreapprovalDetails *preapprovalDetails;
	
	NSMutableArray *payButtons;
	NSMutableDictionary *responseMessage;
	
	PPMEPRootViewController *rootvc;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) BOOL paymentsEnabled;
@property (nonatomic, assign) BOOL shippingEnabled;
@property (nonatomic, assign) BOOL dynamicAmountUpdateEnabled;

@property (nonatomic, retain, readonly) NSString *appID;
@property (nonatomic, retain) NSString *lang;

@property (nonatomic, readonly) PayPalEnvironment environment;
@property (nonatomic, readonly) PayPalButtonText buttonText;
@property (nonatomic, assign) PayPalFeePayer feePayer;

@property (nonatomic, retain, readonly) PayPalAdvancedPayment *payment;
@property (nonatomic, retain, readonly) PayPalPreapprovalDetails *preapprovalDetails;

@property (nonatomic, retain) NSMutableArray *payButtons;
@property (nonatomic, retain) NSMutableDictionary *responseMessage;

+(PayPal*)getPayPalInst;
+(PayPal*)initializeWithAppID:(NSString const *)inAppID;
+(PayPal*)initializeWithAppID:(NSString const *)inAppID forEnvironment:(PayPalEnvironment)env;
+(PayPalInitializationStatus)initializationStatus;
+(NSString *)buildVersion;

-(UIButton *)getPayButtonWithTarget:(const id<PayPalPaymentDelegate>)target andAction:(SEL)action andButtonType:(PayPalButtonType)theButtonType andButtonText:(PayPalButtonText)theButtonText;
//calls getPayButton with text PAY
-(UIButton *)getPayButtonWithTarget:(const id<PayPalPaymentDelegate>)target andAction:(SEL)action andButtonType:(PayPalButtonType)theButtonType; 

-(void)checkoutWithPayment:(PayPalPayment *)inPayment;
-(void)advancedCheckoutWithPayment:(PayPalAdvancedPayment *)inPayment;
-(void)preapprovalWithKey:(NSString *)preapprovalKey andMerchantName:(NSString *)merchantName;

@end
