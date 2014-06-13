//
//  FPKPayPalItem.h
//  FPKPayPal
//
//  Created by Matteo Gavagnin on 1/2/12.
//  Copyright (c) 2012 MobFarm s.a.s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPKPayPalItem : NSObject{
    NSString * price;
    NSString * tax;
    NSString * ship;
    NSString * name;
    NSString * description;
    NSString * merchant;
    NSString * currency;
}
@property(nonatomic, retain) NSString * price;
@property(nonatomic, retain) NSString * tax;
@property(nonatomic, retain) NSString * ship;
@property(nonatomic, retain) NSString * name;
@property(nonatomic, retain) NSString * description;
@property(nonatomic, retain) NSString * merchant;
@property(nonatomic, retain) NSString * currency;

- (FPKPayPalItem *)initWithName:(NSString *)_name andDescription:(NSString *)_description andPrice:(NSString *)_price andTax:(NSString *)_tax andShip:(NSString *)_ship andMerchant:(NSString *)_merchant andCurrency:(NSString *)_currency;
@end
