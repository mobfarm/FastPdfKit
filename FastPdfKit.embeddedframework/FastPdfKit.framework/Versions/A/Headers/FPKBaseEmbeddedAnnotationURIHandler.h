//
//  FPKEmbeddedAnnotationURIHandlerImpl.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' on 11/02/15.
//
//

#import <Foundation/Foundation.h>
#import "FPKEmbeddedAnnotationURIHandler.h"

@interface FPKBaseEmbeddedAnnotationURIHandler : NSObject <FPKEmbeddedAnnotationURIHandler>

@property (nonatomic,copy) NSSet * videoPrefixes;
@property (nonatomic,copy) NSSet * audioPrefixes;
@property (nonatomic,copy) NSSet * webPrefixes;
@property (nonatomic,copy) NSSet * remoteVideoPrefixes;
@property (nonatomic,copy) NSSet * remoteAudioPrefixes;
@property (nonatomic,copy) NSSet * remoteWebPrefixes;
@property (nonatomic,copy) NSSet * configPrefixes;
@property (nonatomic,copy) NSSet * multimediaPrefixes;

+(BOOL)hasStringPrefix:(NSString *)string prefixes:(NSSet *)prefixes;

@end
