//  
//  FPKPayPal
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <FPKPayPal/FPKPayPalItem.h>

/**
 <img src="../docs/fpkpaypal.png">
 
This Extension is useful to let the user purchase a physical good or a service not consumable from inside the app using PayPal mobile checkout. To purchase services or digital goods that will be consumed inside the app you are supposed to use In-App purchases.
This Extension contains a **UIPopover** so for now is compatible only with iPad. You can easily subclass the FPKPayPal class and write the conditional code to extend the support to iPhone and iPod touch.

## Disclaimer

The PayPal classes are located inside the **Common** framework in the PayPal subfolder folder. There you can find some other sample projects and the specific documentation.
The PayPal code and the library have been downloaded from the [x.com](http://www.x.com) PayPal development website.

## Usage

* Prefix: **paypal://**
* Import: **#import <FPKPaPal/FPKPaPal.h>**
* String: **@"FPKPayPal"**

### Prefix

	paypal://

### Resources and Parameters

* *Name* **STRING** 
	* *price* = **FLOAT** item price 
	* *tax* = **FLOAT** item tax that will be added to the price
	* *ship* = **FLOAT** item ship cost that will be added to the price
	* *mer* = **STRING** merchant name
	* *desc* = **STRING** item description
	* *cur* = **STRING** currency used for the payment, default *USD*

### Sample urls

	paypal://FastPdfKit?price=49.9&tax=3.49&ship=2&mer=MobFarm&desc=iOS%20PDF%20Library&cur=EUR

*/

@interface FPKPayPal : UIView <FPKView, UIPopoverControllerDelegate>{
    CGRect _rect;
    FPKPayPalItem *item;
    UIPopoverController *pop;
}

-(void)buttonPressed:(id)sender;
@end
