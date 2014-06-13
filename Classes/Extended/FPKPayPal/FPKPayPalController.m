//
//  FPKPayPalController.m
//  FPKPayPal
//

#import "FPKPayPalController.h"

#import <Common/PayPalPayment.h>
#import <Common/PayPalAdvancedPayment.h>
#import <Common/PayPalAmounts.h>
#import <Common/PayPalReceiverAmounts.h>
#import <Common/PayPalAddress.h>
#import <Common/PayPalInvoiceItem.h>

#import "SuccessViewController.h"

@interface FPKPayPalController ()

@end

@implementation FPKPayPalController

- (id)initWithItem:(FPKPayPalItem *)_item; {
    self = [super init];
    if (self) {
        item = _item;
        self.contentSizeForViewInPopover = CGSizeMake(152.0, 33.0);
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
    [item release];
}

- (void)loadView {    
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 152.0, 33.0)];
	self.view.autoresizesSubviews = FALSE;
	UIColor *color = [UIColor groupTableViewBackgroundColor];
	if (CGColorGetPattern(color.CGColor) == NULL) {
		color = [UIColor lightGrayColor];
	}
	self.view.backgroundColor = color;
	
	status = PAYMENTSTATUS_CANCELED;
	
	[self addLabelWithText:@"" andButtonWithType:BUTTON_152x33 withAction:@selector(simplePayment)];
}

- (void)addLabelWithText:(NSString *)text andButtonWithType:(PayPalButtonType)type withAction:(SEL)action {
	//you should call getPayButton to have the library generate a button for you.
	//this button will be disabled if device interrogation fails for any reason.
	//
	//-- required parameters --
	//target is a class which implements the PayPalPaymentDelegate protocol.
	//action is the selector to call when the button is clicked.
	//inButtonType is the button type (desired size).
	//
	//-- optional parameter --
	//inButtonText can be either BUTTON_TEXT_PAY (default, displays "Pay with PayPal"
	//in the button) or BUTTON_TEXT_DONATE (displays "Donate with PayPal" in the
	//button). the inButtonText parameter also affects some of the library behavior
	//and the wording of some messages to the user.
	UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:action andButtonType:type];
	CGRect frame = CGRectMake(0.0, 1.0-button.frame.size.height/4.0, button.frame.size.width, button.frame.size.height/2.);
	button.frame = frame;
	[self.view addSubview:button];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark Actions triggered by Pay with PayPal buttons

- (void)simplePayment {
    //optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getPayPalInst].shippingEnabled = TRUE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = TRUE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with a single recipient, use a PayPalPayment object
	PayPalPayment *payment = [[[PayPalPayment alloc] init] autorelease];
	payment.recipient = @"example-merchant-1@paypal.com";
	payment.paymentCurrency = [item currency];
	payment.description = [item description];
	payment.merchantName = [item merchant];
    
	//subtotal of all items, without tax and shipping
	payment.subTotal = [NSDecimalNumber decimalNumberWithString:[item price]];
	    
	//invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
	payment.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
	payment.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithString:[item ship]];
	payment.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithString:[item tax]];
	
	//invoiceItems is a list of PayPalInvoiceItem objects
	//NOTE: sum of totalPrice for all items must equal payment.subTotal
	//NOTE: example only shows a single item, but you can have more than one
	payment.invoiceData.invoiceItems = [NSMutableArray array];
	PayPalInvoiceItem *ppItem = [[[PayPalInvoiceItem alloc] init] autorelease];
	ppItem.totalPrice = payment.subTotal;
	ppItem.name = [item name];
    
	[payment.invoiceData.invoiceItems addObject:ppItem];
    
	[[PayPal getPayPalInst] checkoutWithPayment:payment];
}


#pragma mark -
#pragma mark PayPalPaymentDelegate methods

//paymentSuccessWithKey:andStatus: is a required method. in it, you should record that the payment
//was successful and perform any desired bookkeeping. you should not do any user interface updates.
//payKey is a string which uniquely identifies the transaction.
//paymentStatus is an enum value which can be STATUS_COMPLETED, STATUS_CREATED, or STATUS_OTHER
- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
    
	status = PAYMENTSTATUS_SUCCESS;
}

//paymentFailedWithCorrelationID is a required method. in it, you should
//record that the payment failed and perform any desired bookkeeping. you should not do any user interface updates.
//correlationID is a string which uniquely identifies the failed transaction, should you need to contact PayPal.
//errorCode is generally (but not always) a numerical code associated with the error.
//errorMessage is a human-readable string describing the error that occurred.
- (void)paymentFailedWithCorrelationID:(NSString *)correlationID {
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
    
	status = PAYMENTSTATUS_FAILED;
}

//paymentCanceled is a required method. in it, you should record that the payment was canceled by
//the user and perform any desired bookkeeping. you should not do any user interface updates.
- (void)paymentCanceled {
	status = PAYMENTSTATUS_CANCELED;
}

//paymentLibraryExit is a required method. this is called when the library is finished with the display
//and is returning control back to your app. you should now do any user interface updates such as
//displaying a success/failure/canceled message.
- (void)paymentLibraryExit {
	UIAlertView *alert = nil;
	switch (status) {
		case PAYMENTSTATUS_SUCCESS:
			[self.navigationController pushViewController:[[[SuccessViewController alloc] init] autorelease] animated:TRUE];
			break;
		case PAYMENTSTATUS_FAILED:
			alert = [[UIAlertView alloc] initWithTitle:@"Order failed" 
											   message:@"Your order failed. Touch \"Pay with PayPal\" to try again." 
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
			break;
		case PAYMENTSTATUS_CANCELED:
//			alert = [[UIAlertView alloc] initWithTitle:@"Order canceled" 
//											   message:@"You canceled your order. Touch \"Pay with PayPal\" to try again." 
//											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
	}
	
}

//adjustAmountsForAddress:andCurrency:andAmount:andTax:andShipping:andErrorCode: is optional. you only need to
//provide this method if you wish to recompute tax or shipping when the user changes his/her shipping address.
//for this method to be called, you must enable shipping and dynamic amount calculation on the PayPal object.
//the library will try to use the advanced version first, but will use this one if that one is not implemented.
- (PayPalAmounts *)adjustAmountsForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andAmount:(NSDecimalNumber const *)inAmount
									andTax:(NSDecimalNumber const *)inTax andShipping:(NSDecimalNumber const *)inShipping andErrorCode:(PayPalAmountErrorCode *)outErrorCode {
	//do any logic here that would adjust the amount based on the shipping address
	PayPalAmounts *newAmounts = [[[PayPalAmounts alloc] init] autorelease];
	newAmounts.currency = @"USD";
	newAmounts.payment_amount = (NSDecimalNumber *)inAmount;
	
	//change tax based on the address
	if ([inAddress.state isEqualToString:@"CA"]) {
		newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .1]];
	} else {
		newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .08]];
	}
	newAmounts.shipping = (NSDecimalNumber *)inShipping;
	
	//if you need to notify the library of an error condition, do one of the following
	//*outErrorCode = AMOUNT_ERROR_SERVER;
	//*outErrorCode = AMOUNT_CANCEL_TXN;
	//*outErrorCode = AMOUNT_ERROR_OTHER;
    
	return newAmounts;
}

//adjustAmountsAdvancedForAddress:andCurrency:andReceiverAmounts:andErrorCode: is optional. you only need to
//provide this method if you wish to recompute tax or shipping when the user changes his/her shipping address.
//for this method to be called, you must enable shipping and dynamic amount calculation on the PayPal object.
//the library will try to use this version first, but will use the simple one if this one is not implemented.
- (NSMutableArray *)adjustAmountsAdvancedForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency
								 andReceiverAmounts:(NSMutableArray *)receiverAmounts andErrorCode:(PayPalAmountErrorCode *)outErrorCode {
	NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:[receiverAmounts count]];
	for (PayPalReceiverAmounts *amounts in receiverAmounts) {
		//leave the shipping the same, change the tax based on the state 
		if ([inAddress.state isEqualToString:@"CA"]) {
			amounts.amounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[amounts.amounts.payment_amount floatValue] * .1]];
		} else {
			amounts.amounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[amounts.amounts.payment_amount floatValue] * .08]];
		}
		[returnArray addObject:amounts];
	}
	
	//if you need to notify the library of an error condition, do one of the following
	//*outErrorCode = AMOUNT_ERROR_SERVER;
	//*outErrorCode = AMOUNT_CANCEL_TXN;
	//*outErrorCode = AMOUNT_ERROR_OTHER;
	
	return returnArray;
}



@end
