//
//  FPKNamedDestination.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' Tosi on 07/09/2017.
//

#import <Foundation/Foundation.h>
#import "FPKDestination.h"
@interface FPKNamedDestination : NSObject <FPKDestination>
@property (nonatomic, readonly, copy) NSString * destinationName;
-(instancetype)initWithDestinationName:(NSString *)name;
@end
