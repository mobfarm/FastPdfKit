//
//  FPKYouTube.h
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <FPKShared/FPKWebView.h>

/**
This Extension is useful to place a YouTube video over the page

## Usage

* Prefix: **utube://**
* Import: **#import <FPKYouTube/FPKYouTube.h>**
* String: **@"FPKYouTube"**

### Prefixes

	utube://xtmmuGIh0F4://

### Resources and Parameters

* *VIDEO_KEY* **STRING**

With VIDEO_KEY that represents the unique identifier assigned by YouTube to the video itself.
To obtain it open the video in a browser and look at the address bar. 

    http://www.youtube.com/watch?v=xtmmuGIh0F4
    
the VIDEO_KEY is xtmmuGIh0F4

### Sample url

	utube://xtmmuGIh0F4

*/


@interface FPKYouTube : FPKWebView <FPKView>{
    CGRect _rect;
}
@end
