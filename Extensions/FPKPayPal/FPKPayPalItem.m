//
//  FPKPayPalItem.m
//  FPKPayPal
//

#import "FPKPayPalItem.h"

@implementation FPKPayPalItem

- (FPKPayPalItem *)initWithName:(NSString *)name andDescription:(NSString *)description andPrice:(NSString *)price andTax:(NSString *)tax andShip:(NSString *)ship andMerchant:(NSString *)merchant andCurrency:(NSString *)currency {
    if (self = [super init])
    {
        _name = name;
        _description = description;
        _price = price;
        _tax = tax;
        _ship = ship;
        _merchant = merchant;
        _currency = currency;
    }
    return self;  
}

@end
