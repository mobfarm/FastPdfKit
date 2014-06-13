
#import "SuccessViewController.h"
#import <Common/PayPal.h>
#import <Common/PayPalAdvancedPayment.h>
#import <Common/PayPalPreapprovalDetails.h>


@implementation SuccessViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
	self.view.autoresizesSubviews = FALSE;
	UIColor *color = [UIColor groupTableViewBackgroundColor];
	if (CGColorGetPattern(color.CGColor) == NULL) {
		color = [UIColor lightGrayColor];
	}
	self.view.backgroundColor = color;
	self.title = @"Success!";
	
	NSMutableString *buf = [NSMutableString string];
	
	[buf appendString:@"Congratulations!  You successfully "];
	
	if ([PayPal getPayPalInst].payment != nil) {
		NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[formatter setCurrencyCode:[PayPal getPayPalInst].payment.paymentCurrency];
		[formatter setNegativeFormat:[NSString stringWithFormat:@"-%@", [formatter positiveFormat]]];
		[buf appendFormat:@"paid %@ to ", [formatter stringFromNumber:[PayPal getPayPalInst].payment.total]];
		
		NSString *recipient = nil;
		if ([PayPal getPayPalInst].payment.singleReceiver != nil) {
			recipient = [PayPal getPayPalInst].payment.singleReceiver.merchantName;
			if (recipient == nil || [PayPal getPayPalInst].payment.isPersonal) {
				recipient = [PayPal getPayPalInst].payment.singleReceiver.recipient;
			}
		} else {
			for (PayPalReceiverPaymentDetails *receiver in [PayPal getPayPalInst].payment.receiverPaymentDetails) {
				if (receiver.merchantName.length > 0) {
					recipient = receiver.merchantName;
					break;
				}
			}
			if (recipient == nil) { //no merchant name provided on any of the recipients
				recipient = [NSMutableString string];
				for (PayPalReceiverPaymentDetails *receiver in [PayPal getPayPalInst].payment.receiverPaymentDetails) {
					if (receiver.recipient.length > 0) {
						if (recipient.length > 0) {
							[(NSMutableString *)recipient appendString:@", "];
						}
						[(NSMutableString *)recipient appendString:receiver.recipient];
					}
				}
			}
		}
		[buf appendFormat:@"%@.", recipient];
	} else if ([PayPal getPayPalInst].preapprovalDetails != nil) {
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterNoStyle];
		
		NSString *recipient = [PayPal getPayPalInst].preapprovalDetails.merchantName;
		NSString *startDate = [formatter stringFromDate:[PayPal getPayPalInst].preapprovalDetails.startDate];
		NSString *endDate = [formatter stringFromDate:[PayPal getPayPalInst].preapprovalDetails.endDate];
		[buf appendFormat:@"preapproved payments to %@ from %@ until %@.", recipient, startDate, endDate];
	}
	
	UIFont *font = [UIFont systemFontOfSize:16.];
	CGSize size = [buf sizeWithFont:font constrainedToSize:CGSizeMake(self.view.frame.size.width - 20., MAXFLOAT)];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10., 10., self.view.frame.size.width - 20., size.height)] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.numberOfLines = 0;
	label.font = font;
	label.text = buf;
	[self.view addSubview:label];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(round((self.view.frame.size.width - 294.) / 2.), label.frame.origin.y + label.frame.size.height + 10., 294., 43.);
	[button setTitle:@"Done" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(backToMainMenu) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.navigationItem.hidesBackButton = TRUE;
}

- (void)backToMainMenu {
	[self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
