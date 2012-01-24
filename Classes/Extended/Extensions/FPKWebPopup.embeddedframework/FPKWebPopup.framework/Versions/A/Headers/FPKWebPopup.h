//  
//  FPKWebPopup
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <Common/DDSocialDialog.h>

/**
This Extension is useful to open a web page in a popup view.

## Usage

* Prefix: **webpopup://** or **webpopups://**
* Import: **#import <FPKWebPopup/FPKWebPopup.h>**
* String: **@"FPKWebPopup"**

### Prefixes

	webpopup://
	webpopups://
	
Use *webpopup* in replacement of *http* protocol.
Use *webpopups* in replacement of *https* protocol.

### Resources and Parameters

* *URL* **STRING** 
	* *h* = **FLOAT** popup width *(optional)*
	* *w* = **FLOAT** popup height *(optional)*

### Sample url

	webpopup://fastpdfkit.com?h=400&w=400

*/

@interface FPKWebPopup : UIView <FPKView, DDSocialDialogDelegate>{
    CGRect _rect;
}
@end
