//
//  MFAudioPlayerViewImpl.m
//  FastPdfKit
//
//  Created by Gianluca Orsini on 19/04/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFAudioPlayerViewImpl.h"
#import "MFAudioProvider.h"
#import "Stuff.h"

#define PLAY_IMG @"Reader/play_player"
#define PAUSE_IMG @"Reader/pause_player"

@implementation MFAudioPlayerViewImpl

@synthesize startStopButton;
@synthesize volumeSlider;
@synthesize audioProvider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [aBtn setBackgroundImage:[UIImage imageNamed:PLAY_IMG inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [aBtn addTarget:self action:@selector(actionTogglePlay:) forControlEvents:UIControlEventTouchUpInside];
        [aBtn setFrame:CGRectMake(8, 2, 33, 33)];
        [self addSubview:aBtn];
        self.startStopButton = aBtn;
        
        UISlider *aSlider = [[UISlider alloc] initWithFrame:CGRectMake(48, 8, 117, 23)];
        [aSlider addTarget:self action:@selector(actionAdjustVolume:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:aSlider];
        self.volumeSlider = aSlider;
    }
    return self;
}


-(void)actionTogglePlay:(id)sender{
     
    [self.audioProvider togglePlay];
}

-(void)actionAdjustVolume:(id)sender{
    
    [self.audioProvider setVolumeLevel:[self.volumeSlider value]];
    
}


+(UIView *)audioPlayerViewInstance{
    
    MFAudioPlayerViewImpl *view = [[MFAudioPlayerViewImpl alloc] initWithFrame:CGRectMake(0, 0, 272, 40)];
    return view;
}


-(void)setAudioProvider:(id<MFAudioProvider>)provider{
    
    float volumeLevel = 0;
    
    audioProvider = provider;
    
    if([audioProvider isPlaying]) {
         [startStopButton setBackgroundImage:[UIImage imageNamed:PAUSE_IMG inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    } else {
         [startStopButton setBackgroundImage:[UIImage imageNamed:PLAY_IMG inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }
    
    volumeLevel = [audioProvider volumeLevel];
    [volumeSlider setValue:volumeLevel];
    
}

/**
 Playback event methods.
 */

-(void)audioProviderDidStart:(id<MFAudioProvider>)mfeap{

    [self.startStopButton setBackgroundImage:[UIImage imageNamed:PAUSE_IMG inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    
}

-(void)audioProvider:(id<MFAudioProvider>)mfap volumeAdjustedTo:(float)volume{

        
}

-(void)audioProviderDidStop:(id<MFAudioProvider>)mfeap{
    
    [self.startStopButton setBackgroundImage:[UIImage imageNamed:PLAY_IMG inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

}

@end
