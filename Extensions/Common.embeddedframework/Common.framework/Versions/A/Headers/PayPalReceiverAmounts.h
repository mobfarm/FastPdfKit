//
//  PayPalReceiverAmounts.h
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
#import "PayPalAmounts.h"

@interface PayPalReceiverAmounts : NSObject {
	PayPalAmounts *amounts;
	NSString *recipient;
}

@property (nonatomic, retain) PayPalAmounts *amounts;
@property (nonatomic, copy) NSString *recipient;

@end
