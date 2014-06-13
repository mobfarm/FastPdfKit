//
//  FPKPayPalItem.h
//  FPKPayPal
//
//  Created by Matteo Gavagnin on 1/2/12.
//  Copyright (c) 2012 MobFarm s.a.s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPKPayPalItem : NSObject

@property(nonatomic, retain) NSString * price;
@property(nonatomic, retain) NSString * tax;
@property(nonatomic, retain) NSString * ship;
@property(nonatomic, retain) NSString * name;
@property(nonatomic, retain) NSString * description;
@property(nonatomic, retain) NSString * merchant;
@property(nonatomic, retain) NSString * currency;

- (FPKPayPalItem *)initWithName:(NSString *)name andDescription:(NSString *)description andPrice:(NSString *)price andTax:(NSString *)tax andShip:(NSString *)ship andMerchant:(NSString *)merchant andCurrency:(NSString *)currency;
@end
