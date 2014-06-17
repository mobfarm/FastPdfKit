//
//  FPKMap.m
//  Overlay
//

#import "FPKMap.h"
#import "FPKMapAnnotation.h"
#import "MFDocumentManager.h"

@implementation FPKMap

#pragma mark -
#pragma mark Initialization

-(UIView *)initWithParams:(NSDictionary *)params andFrame:(CGRect)frame from:(FPKOverlayManager *)manager{
    if (self = [super init]) 
    {        
        
        // NSLog(@"Init with parameters");
        [self setFrame:frame];
        _rect = frame;
        
        NSDictionary * paramsDictionary = params[@"params"];
        
        map = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [map setDelegate:self];
        MKCoordinateRegion newRegion;
        newRegion.center.latitude = [[paramsDictionary objectForKey:@"lat"] doubleValue];
        newRegion.center.longitude = [[paramsDictionary objectForKey:@"lon"] doubleValue];
        newRegion.span.latitudeDelta = [[paramsDictionary objectForKey:@"latd"] floatValue];
        newRegion.span.longitudeDelta = [[paramsDictionary objectForKey:@"lond"] floatValue];
                
        [map setRegion:newRegion animated:YES];
        MKMapType type = MKMapTypeStandard;
        if ([[paramsDictionary objectForKey:@"resource"] isEqualToString:@"hybrid"])
            type = MKMapTypeHybrid;
        else if ([[paramsDictionary objectForKey:@"resource"] isEqualToString:@"satellite"])
            type = MKMapTypeSatellite;
        else if ([[paramsDictionary objectForKey:@"resource"] isEqualToString:@"standard"])
            type = MKMapTypeStandard;

        animateDrops = YES;
        if ([paramsDictionary objectForKey:@"animate"] && ![[paramsDictionary objectForKey:@"animate"] boolValue]) {
            animateDrops = NO;
        }
        
        if([[paramsDictionary objectForKey:@"user"] boolValue])
            [map setShowsUserLocation:YES];
        
        if ([paramsDictionary objectForKey:@"pins"]) {
            

            
            NSString * jsonString = [[paramsDictionary objectForKey:@"pins"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            
            // NSLog(@"The json object: %@", [json objectForKey:@"pins"]);
            
            for(NSDictionary *pin in [json objectForKey:@"pins"]){
                FPKMapAnnotation *annotation = [[FPKMapAnnotation alloc] init];
                annotation.latitude = [NSNumber numberWithDouble:[[pin objectForKey:@"lat"] doubleValue]];            
                annotation.longitude = [NSNumber numberWithDouble: [[pin objectForKey:@"lon"] doubleValue]];            
                
                annotation.callout = NO;
                
                if([pin objectForKey:@"title"]){
                    annotation.title = [pin objectForKey:@"title"];
                    annotation.callout = YES;
                }
                
                if([pin objectForKey:@"title"]){
                    annotation.subtitle = [pin objectForKey:@"subtitle"];
                }
                
                MKPinAnnotationColor color = MKPinAnnotationColorRed;
                if ([[pin objectForKey:@"color"] isEqualToString:@"red"])
                    color = MKPinAnnotationColorRed;
                else if ([[pin objectForKey:@"color"] isEqualToString:@"green"])
                    color = MKPinAnnotationColorGreen;
                else if ([[pin objectForKey:@"color"] isEqualToString:@"purple"])
                    color = MKPinAnnotationColorPurple;
                
                [annotation setColor:color];                
                
                
                if([pin objectForKey:@"uri"]){
                    [annotation setUri:[pin objectForKey:@"uri"]];
                }
                
                
                if([pin objectForKey:@"image"]){
                    NSString * resource;
                    if([manager respondsToSelector:@selector(documentViewController)]){
                        resource = [[[manager documentViewController] document] resourceFolder];
                    } else {
                        resource = [manager performSelector:@selector(resourcePath)];
                    }
                    UIImage *imageI = [UIImage imageWithContentsOfFile:
                                       [NSString stringWithFormat:@"%@/%@",
                                        resource, 
                                        [pin objectForKey:@"image"]
                                        ]
                                       ];
                    [annotation setImage:imageI];
                }
                
                [map addAnnotation:annotation];
            }
        }
        
        // This is the new json-encapsulated pin expression, useful to place in future more pins
        if ([paramsDictionary objectForKey:@"pin"]) {
            // NSLog(@"There's a Pin");
            
            NSString * jsonString = [[paramsDictionary objectForKey:@"pin"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            
            FPKMapAnnotation *annotation = [[FPKMapAnnotation alloc] init];
            annotation.latitude = [NSNumber numberWithDouble:[[json objectForKey:@"lat"] doubleValue]];            
            annotation.longitude = [NSNumber numberWithDouble: [[json objectForKey:@"lon"] doubleValue]];            
            
            annotation.callout = NO;
            
            if([json objectForKey:@"title"]){
                annotation.title = [json objectForKey:@"title"];
                annotation.callout = YES;
            }
            
            if([json objectForKey:@"title"]){
                annotation.subtitle = [json objectForKey:@"subtitle"];
            }
            
            MKPinAnnotationColor color = MKPinAnnotationColorRed;
            if ([[json objectForKey:@"color"] isEqualToString:@"red"])
                color = MKPinAnnotationColorRed;
            else if ([[json objectForKey:@"color"] isEqualToString:@"green"])
                color = MKPinAnnotationColorGreen;
            else if ([[json objectForKey:@"color"] isEqualToString:@"purple"])
                color = MKPinAnnotationColorPurple;
            
            [annotation setColor:color];                
            

            // FIXME: the action uri is currently unsupported
//            if([json objectForKey:@"uri"] && [[json objectForKey:@"uri"] length] > 0){
//                [annotation setUri:[json objectForKey:@"uri"]];
//            }
            
            if([json objectForKey:@"image"] && ![[json objectForKey:@"image"] isEqualToString:@"no-name.png"]){
                NSString * resource;
                if([manager respondsToSelector:@selector(documentViewController)]){
                    resource = [[[manager documentViewController] document] resourceFolder];
                } else {
                    resource = [manager performSelector:@selector(resourcePath)];
                }
                UIImage *imageI = [UIImage imageWithContentsOfFile:
                                   [NSString stringWithFormat:@"%@/%@",
                                    resource, 
                                    [json objectForKey:@"image"]
                                    ]
                                   ];
                [annotation setImage:imageI];
            }
            
            [map addAnnotation:annotation];
        } else if([paramsDictionary objectForKey:@"pinlat"] && 
           [[paramsDictionary objectForKey:@"pinlat"] doubleValue] <= 90.0 && 
           [[paramsDictionary objectForKey:@"pinlat"] doubleValue] >= -90.0 && 
           [paramsDictionary objectForKey:@"pinlon"] && 
           [[paramsDictionary objectForKey:@"pinlon"] doubleValue] <= 180.0 && 
           [[paramsDictionary objectForKey:@"pinlon"] doubleValue] >= -180.0 ){
            
            FPKMapAnnotation *annotation = [[FPKMapAnnotation alloc] init];
            annotation.latitude = [NSNumber numberWithDouble:[[paramsDictionary objectForKey:@"pinlat"] doubleValue]];            
            annotation.longitude = [NSNumber numberWithDouble: [[paramsDictionary objectForKey:@"pinlon"] doubleValue]];            
            
            annotation.callout = NO;
            
            if([paramsDictionary objectForKey:@"pintitle"]){
                annotation.title = [paramsDictionary objectForKey:@"pintitle"];
                annotation.subtitle = [paramsDictionary objectForKey:@"pinsub"];
                annotation.callout = YES;
            }
            
            MKPinAnnotationColor color = MKPinAnnotationColorRed;
            if ([[paramsDictionary objectForKey:@"pincolor"] isEqualToString:@"red"])
                color = MKPinAnnotationColorRed;
            else if ([[paramsDictionary objectForKey:@"pincolor"] isEqualToString:@"green"])
                color = MKPinAnnotationColorGreen;
            else if ([[paramsDictionary objectForKey:@"pincolor"] isEqualToString:@"purple"])
                color = MKPinAnnotationColorPurple;
            
            [annotation setColor:color];                
            [map addAnnotation:annotation];
         
        }
        
        
        [map setMapType:type];
        [self addSubview:map];

    }
    return self;  
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(FPKMapAnnotation <MKAnnotation> *)annotation {
	
	MKPinAnnotationView * view = nil;
	
	if([annotation isMemberOfClass:[FPKMapAnnotation class]]) {
        
			view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"FPKMapAnnotation"];
            
            if ([annotation.uri length] > 0) {
                
                UIButton *disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                // add target for the action
                [view setRightCalloutAccessoryView:disclosure];    
            }
            
            if(annotation.image){
                [view setLeftCalloutAccessoryView:[[UIImageView alloc] initWithImage:annotation.image]];
            }
			
			[view setCanShowCallout:YES];
            [view setAnimatesDrop:animateDrops];
		
	} else {
        
		// Do nothing
		
	} 
	
	return view;
    
}
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(FPKMapAnnotation <MKAnnotation> *)annotation
//{   
//    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
//    
//    // Button
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    button.frame = CGRectMake(0, 0, 23, 23);
//    annotationView.rightCalloutAccessoryView = button;
//    
//    // Image and two labels
//    UIView *leftCAV = [[UIView alloc] initWithFrame:CGRectMake(0,0,23,23)];
//    [leftCAV addSubview: [[UIImageView alloc] initWithImage:annotation.image]];
//    annotationView.leftCalloutAccessoryView = leftCAV;
//    
//    return annotationView;
//}


+ (NSArray *)acceptedPrefixes{
    return [NSArray arrayWithObjects:@"map", nil];
}

+(BOOL)matchesURI:(NSString *)uri
{
    NSArray * prefixes = self.acceptedPrefixes;
    for(NSString * prefix in prefixes)
    {
        if([uri hasPrefix:prefix])
            return YES;
    }
    return NO;
}

+ (BOOL)respondsToPrefix:(NSString *)prefix
{
    
    NSArray * prefixes = self.acceptedPrefixes;
    for(NSString * supportedPrefix in prefixes)
    {
        if([prefix caseInsensitiveCompare:supportedPrefix] == 0)
        {
            return YES;
        }
    }
    return NO;
}

- (void)setRect:(CGRect)aRect{
    [self setFrame:aRect];
    _rect = aRect;
}

@end