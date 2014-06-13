//
//  FPKPayPalItem.m
//  FPKPayPal
//

#import "FPKPayPalItem.h"

@implementation FPKPayPalItem
@synthesize name, description, price, tax, ship, merchant, currency;

- (FPKPayPalItem *)initWithName:(NSString *)_name andDescription:(NSString *)_description andPrice:(NSString *)_price andTax:(NSString *)_tax andShip:(NSString *)_ship andMerchant:(NSString *)_merchant andCurrency:(NSString *)_currency{
    if (self = [super init]) 
    {
        name = _name;
        description = _description;
        price = _price;
        tax = _tax;
        ship = _ship;
        merchant = _merchant;
        currency = _currency;
    }
    return self;  
}

-(void)dealloc{
    [super dealloc];
    [merchant release];
    [currency release];
    [name release];
    [merchant release];
    [price release];
    [tax release];
    [ship release];
}

@end
