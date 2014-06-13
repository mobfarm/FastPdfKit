//
//  FPKPayPalController.h
//  FPKExtension
//
//  Created by Matteo Gavagnin on 1/2/12.
//  Copyright (c) 2012 MobFarm s.a.s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Common/PayPal.h>
#import "FPKPayPalItem.h"

typedef enum PaymentStatuses {
	PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED,
} PaymentStatus;


@interface FPKPayPalController : UIViewController <PayPalPaymentDelegate>{
    PaymentStatus status;
    FPKPayPalItem *item;
}

- (id)initWithItem:(FPKPayPalItem *)_item;
- (void)simplePayment;
@end
