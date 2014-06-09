//
//  MFPDFOutlineRemoteEntry.h
//  FastPdfKitLibrary
//
//  Created by Nicolò Tosi on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFPDFOutlineEntry.h"

@interface MFPDFOutlineRemoteEntry : MFPDFOutlineEntry {
    
    NSString * file;
    
    NSString * destination;
}

@property (nonatomic,copy) NSString * file;
@property (nonatomic,copy) NSString * destination;

-(id)initWithTitle:(NSString *)title;

@end
