//
//  MFWebView.m
//  FPKShared
//

#import "FPKWebView.h"

@implementation FPKWebView

-(void)removeBackground{
    self.scalesPageToFit = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    for (id subview in self.subviews){
        
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;        
            ((UIScrollView *)subview).bouncesZoom = NO;
            for(id subsubview in [subview subviews]) {
                if([[subsubview class] isSubclassOfClass:[UIImageView class]]) {
                    [subsubview setHidden:YES];
                }
            }
        }
    }
}

@end
