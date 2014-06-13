//
//  MFMapAnnotation.m
//  Overlay
//

#import "FPKMapAnnotation.h"

@implementation FPKMapAnnotation

@synthesize image;
@synthesize latitude;
@synthesize longitude;
@synthesize title;
@synthesize subtitle;
@synthesize callout;
@synthesize color;
@synthesize uri;

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [self.latitude doubleValue];
    theCoordinate.longitude = [self.longitude doubleValue];
    return theCoordinate; 
}

@end
