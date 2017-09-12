//
//  FPKPageNumberDestination.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' Tosi on 07/09/2017.
//

#import <Foundation/Foundation.h>
#import "FPKDestination.h"
@interface FPKPageNumberDestination : NSObject <FPKDestination>
@property (nonatomic, readonly) NSUInteger pageNumber;
-(instancetype)initWithPageNumber:(NSUInteger)pageNumber;
@end
