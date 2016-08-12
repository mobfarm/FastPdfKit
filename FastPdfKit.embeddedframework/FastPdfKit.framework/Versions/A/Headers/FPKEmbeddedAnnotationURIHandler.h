//
//  FPKEmbeddedAnnotationURIHandler.h
//  FastPdfKitLibrary
//
//  Created by Nicolo' on 11/02/15.
//
//

@protocol FPKEmbeddedAnnotationURIHandler <NSObject>

-(BOOL)isVideoURI:(NSString *)uri;
-(BOOL)isRemoteVideoURI:(NSString *)uri;
-(BOOL)isAudioURI:(NSString *)uri;
-(BOOL)isRemoteAudioURI:(NSString *)uri;
-(BOOL)isWebURI:(NSString *)uri;
-(BOOL)isRemoteWebURI:(NSString *)uri;
-(BOOL)isConfigURI:(NSString *)uri;
-(BOOL)isMultimediaURI:(NSString *)uri;

@end