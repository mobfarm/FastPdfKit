//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <Common/DDSocialDialog.h>

@interface FPKWebPopup : UIView <FPKView, DDSocialDialogDelegate>{
    CGRect _rect;
}
@end
