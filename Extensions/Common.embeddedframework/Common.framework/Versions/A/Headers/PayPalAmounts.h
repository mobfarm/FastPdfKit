//
//  PayPalAmounts.h
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


@interface PayPalAmounts : NSObject {
	NSString *currency;
	NSDecimalNumber *payment_amount;
	NSDecimalNumber *tax;
	NSDecimalNumber *shipping;
}
@property (nonatomic, retain) NSString *currency;
@property (nonatomic, retain) NSDecimalNumber *payment_amount;
@property (nonatomic, retain) NSDecimalNumber *tax;
@property (nonatomic, retain) NSDecimalNumber *shipping;
@end
