//
//  FPKURIAnnotation.h
//  FastPdfKitLibrary
//
//  Created by Nicolò Tosi on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPKAnnotation.h"

@interface FPKURIAnnotation : FPKAnnotation {
    NSString * uri;
}
@property (nonatomic,copy) NSString * uri;
@end
