//
//  MFAudioProvider.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 4/18/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MFAudioPlayerViewProtocol.h"

@protocol MFAudioProvider <NSObject>

/**
 Play when stopped and viceversa.
 */
-(void)togglePlay;

/**
 Tell if the audio clip is playing.
 */
-(BOOL)isPlaying;

/**
 Set the volume level, from 0.0 to 1.0.
 */
-(void)setVolumeLevel:(float)volume;

/**
 Return the volume level.
 */
-(float)volumeLevel;

@end
