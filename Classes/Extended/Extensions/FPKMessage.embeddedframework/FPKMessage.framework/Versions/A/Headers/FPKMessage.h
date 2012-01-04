//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <Common/DDSocialDialog.h>

@interface FPKMessage : UIView <FPKView, DDSocialDialogDelegate>{
    CGRect _rect;
}
@end
