//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>

@interface FPKGallerySlide : UIView <FPKView>{
    CGRect _rect;
    id *pagingViewController; 
}
@end
