//
//  MFMapAnnotation.h
//  Overlay
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface FPKMapAnnotation : NSObject <MKAnnotation> {
    UIImage *image;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *title;
    NSString *subtitle;
    BOOL callout;
    MKPinAnnotationColor color;
    NSString *uri;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) BOOL callout;
@property (nonatomic) MKPinAnnotationColor color;
@property (nonatomic, retain) NSString *uri;
@end