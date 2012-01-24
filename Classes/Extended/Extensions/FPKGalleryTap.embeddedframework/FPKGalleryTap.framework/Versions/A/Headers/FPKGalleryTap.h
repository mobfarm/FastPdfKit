//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>

/**

This Extension is useful to create an image gallery with a big image and some small ones.
As soon as you tap on the small one you can change the content of the others.
You can even use just one annotation to place a single image over the page.

## Usage

* Prefix: **gallerytap://**
* Import: **#import <FPKGalleryTap/FPKGalleryTap.h>**
* String: **@"FPKGalleryTap"**

### Prefix

	gallerytap://

### Resources and Parameters

* *image* **STRING* the name or path for the image
	* *id* = **INT**: a unique identifier for the image
* **button**	
	* *target_id* = **INT** the id of the main image
	* *src* = **STRING** the name of the image that will be set on the main annotation
	* *animate* = **BOOL** perform animated transitions with cross fade
	* *time* = **FLOAT** duration of the transition
	* *self* = **STRING** image path to be placed on the small annotation
	* *id* = **INT** unique identifier
	* *selected* = **BOOL** if a border should be drawn around the small image at page load
	* *r* = **INT**	border red component between 0 and 255
	* *g* = **INT**	border green component between 0 and 255		
	* *b* = **INT**	border blue component between 0 and 255
	* *others* = **ARRAY** **INT** the list of ids of other small images separated by commas `,`

### Sample urls

	gallerytap://img1.png?id=1
	gallerytap://button?target_id=1&src=img1.png&animate=YES&time=1.0&self=img1.png&id=2&selected=YES&r=255&g=0&b=0&others=3,4

*/

@interface FPKGalleryTap : UIView <FPKView>{
    CGRect _rect;
}

@end
