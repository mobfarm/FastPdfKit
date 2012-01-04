//  
//  FPKPayPal
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <FPKPayPal/FPKPayPalItem.h>

@interface FPKPayPal : UIView <FPKView, UIPopoverControllerDelegate>{
    CGRect _rect;
    FPKPayPalItem *item;
    UIPopoverController *pop;
}

-(void)buttonPressed:(id)sender;
@end
