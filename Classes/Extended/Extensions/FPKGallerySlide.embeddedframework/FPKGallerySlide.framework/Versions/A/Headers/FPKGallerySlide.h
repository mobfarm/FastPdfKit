//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>


/**
This Extension is useful to create an image gallery with horizontal slide transitions and page indicator.

## Usage

* Prefix: **galleryslide://**
* Import: **#import <FPKGallerySlide/FPKGallerySlide.h>**
* String: **@"FPKGallerySlide"**

### Prefix

	galleryslide://

### Resources and Parameters

* any resource
	* *images* = **ARRAY** **STRING** the list of images separated by commas `,`
	* *loop* = **INT**: times that the automatic slide needs to be performed, `-1` to infinite, `0` for no loop

### Sample url

	galleryslide://?images=img1.png,img2.png,img3.png&loop=1

*/

@interface FPKGallerySlide : UIView <FPKView>{
    CGRect _rect;
    id *pagingViewController; 
}
@end
