//
//  FPKPayPal
//  FastPdfKit Extension
//

#import "FPKPayPal.h"
#import <Common/PayPal.h>
#import "FPKPayPalController.h"

@implementation FPKPayPal

#pragma mark -
#pragma mark Initialization

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        [self setFrame:frame];
        _rect = frame;
        
        if ([[params objectForKey:@"load"] boolValue]){
            NSString *name;
            NSString *description;
            NSString * price;
            NSString * tax;
            NSString * ship;
            NSString *merchant;
            NSString *currency; 
            
            if([[params objectForKey:@"params"] objectForKey:@"resource"]){
                name = [[params objectForKey:@"params"] objectForKey:@"resource"];
            } else {
                NSLog(@"FPKPayPal - Resource name not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name");
                name = @"FastPdfKit";
            }
            
            if([[params objectForKey:@"params"] objectForKey:@"desc"]){
                description = [[params objectForKey:@"params"] objectForKey:@"desc"];
            } else {
                NSLog(@"FPKPayPal - Parameter desc not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name?desc=Description");
                description = @"iOS pdf library";
            }
            
            if([[params objectForKey:@"params"] objectForKey:@"mer"]){
                merchant = [[params objectForKey:@"params"] objectForKey:@"mer"];
            } else {
                NSLog(@"FPKPayPal - Parameter mer not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name?mer=Merchant");
                merchant = @"MobFarm";
            }
            
            if([[params objectForKey:@"params"] objectForKey:@"cur"]){
                currency = [[params objectForKey:@"params"] objectForKey:@"cur"];
            } else {
                NSLog(@"FPKPayPal - Parameter cur not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name?cur=USD");
                currency = @"USD";
            }
            
            if([[params objectForKey:@"params"] objectForKey:@"price"]){
                price = [[params objectForKey:@"params"] objectForKey:@"price"];
            } else {
                NSLog(@"FPKPayPal - Parameter price not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name?price=49.90");
                price = @"49.90";
            }

            if([[params objectForKey:@"params"] objectForKey:@"tax"]){
                tax = [[params objectForKey:@"params"] objectForKey:@"tax"];
            } else {
                NSLog(@"FPKPayPal - Parameter tax not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name?tax=3.49");
                tax = @"3.90";
            }
            
            if([[params objectForKey:@"params"] objectForKey:@"ship"]){
                ship = [[params objectForKey:@"params"] objectForKey:@"ship"];
            } else {
                NSLog(@"FPKPayPal - Parameter ship not found, check the uri, it should be in the form: ");
                NSLog(@"FPKPayPal - paypal://name?ship=0.0");
                ship = @"0.00";
            }       
            
            item = [[FPKPayPalItem alloc] initWithName:name
                                                       andDescription:description
                                                             andPrice:price 
                                                               andTax:tax 
                                                              andShip:ship
                                                          andMerchant:merchant
                                                          andCurrency:currency
                    ];
            
            CGRect origin = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
            UIButton *button = [[UIButton alloc] initWithFrame:origin];
            [button setUserInteractionEnabled:YES];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button setAlpha:1.0];
            [self addSubview:button];
            [button release];
            
            [PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
            // [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
            // [PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
        }
    }
    return self;  
}

-(void)buttonPressed:(id)sender{
    FPKPayPalController *pp = [[FPKPayPalController alloc] initWithItem:item];
    pop = [[UIPopoverController alloc] initWithContentViewController:pp];
    [pop setDelegate:self];
    
    [pop presentPopoverFromRect:CGRectMake(self.frame.size.width/2-5.0, self.frame.size.height/2-5.0, 10, 10) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    // [[popoverController contentViewController] release];
    [popoverController release];
}

+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"paypal", nil];
}

+ (BOOL)respondsToPrefix:(NSString *)prefix{
    if([prefix isEqualToString:@"paypal"])
        return YES;
    else 
        return NO;
}

- (CGRect)rect{
    return _rect;
}

- (void)setRect:(CGRect)aRect{
    [self setFrame:aRect];
    _rect = aRect;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc 
{
    [super dealloc];
}

@end