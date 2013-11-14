//
//  MFFPKAnnotation.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 4/15/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFAnnotation.h"

@interface MFFPKAnnotation : MFAnnotation {
    
    NSURL * url;
    NSString * originalUri;
    CGRect quadPointsRect;
}

@property (nonatomic,copy) NSString * originalUri;
@property (nonatomic,retain) NSURL * url;
@property (nonatomic,readwrite) CGRect quadPointsRect;

@end
