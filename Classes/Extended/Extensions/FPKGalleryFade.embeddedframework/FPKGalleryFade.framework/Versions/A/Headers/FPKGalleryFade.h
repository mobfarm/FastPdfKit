//
//  FPKGalleryFade.h
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>

/**
This Extension is useful to create an image gallery with cross timed fade transitions.
You can for example place it on the index page and show the article top photos.

## Usage

* Prefix: **message://**
* Import: **#import <FPKGalleryFade/FPKGalleryFade.h>**
* String: **@"FPKGalleryFade"**

### Prefix

	galleryfade://

### Resources and Parameters

* any resource
	* *images* = **ARRAY** **STRING** the list of images separated by commas `,`
	* *time* = **FLOAT**: time interval between automatic transitions

### Sample url

	galleryfade://?time=2.0&images=img1.png,img2.png,img3.png,img4.png

*/


@interface FPKGalleryFade : UIView <FPKView>{
    CGRect _rect;
}
@end
