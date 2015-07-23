//
//  MFFPKAnnotation.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 4/15/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFAnnotation.h"

@interface MFFPKAnnotation : MFAnnotation
@property (nonatomic, copy) NSString * originalUri;
@property (nonatomic, strong) NSURL * url;
@property (nonatomic, readwrite) CGRect quadPointsRect;
@end
