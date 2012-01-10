//
//  MFAudioPlayerViewProtocol.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 4/18/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFAudioProvider.h"

@protocol MFAudioPlayerViewProtocol <NSObject>

/**
 This method will be called to provide a view instance to add to the overlay.
 */
+(UIView *)audioPlayerViewInstance;

/**
 This method will be called to give a chance to store the refernce to the provider
 that will notify the view about the playback. It is recommended to assign it, not retain to
 avoid circular retention between provider and review.
 */
-(void)setAudioProvider:(id<MFAudioProvider>)provider;

/**
 Playback and status event methods.
 */
-(void)audioProviderDidStart:(id<MFAudioProvider>)mfeap;
-(void)audioProviderDidStop:(id<MFAudioProvider>)mfeap;
-(void)audioProvider:(id<MFAudioProvider>)mfap volumeAdjustedTo:(float)volume;

@end
