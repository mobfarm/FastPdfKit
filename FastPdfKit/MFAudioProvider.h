//
//  MFAudioProvider.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 4/18/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFAudioPlayerViewProtocol.h"

@protocol MFAudioProvider <NSObject>

-(void)togglePlay;
-(BOOL)isPlaying;
-(void)setVolumeLevel:(float)volume;
-(float)volumeLevel;

@end
