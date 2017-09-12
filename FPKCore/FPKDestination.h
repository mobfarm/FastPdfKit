//
//  FPKDestination.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' Tosi on 07/09/2017.
//

#import <Foundation/Foundation.h>
@class MFDocumentManager;

@protocol FPKDestination <NSObject>

-(NSUInteger)pageNumberOnDocument:(MFDocumentManager *)doc;

@end
