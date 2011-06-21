//
//  MFAudioPlayerViewImpl.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 19/04/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFAudioPlayerViewImpl.h"
#import "MFAudioProvider.h"

#define PLAY_IMG @"play_player.png"
#define PAUSE_IMG @"pause_player.png"
#define BCKGR_IMG @"hud_player.png"

@implementation MFAudioPlayerViewImpl

@synthesize startStopButton;
@synthesize volumeSlider;
@synthesize audioProvider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        UIImageView *backgroundImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:BCKGR_IMG]];
        [backgroundImageView setFrame:CGRectMake(0, 0, 272, 40)];
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [aBtn setBackgroundImage:[UIImage imageNamed:PLAY_IMG] forState:UIControlStateNormal];
        [aBtn addTarget:self action:@selector(actionTogglePlay:) forControlEvents:UIControlEventTouchUpInside];
        [aBtn setFrame:CGRectMake(8, 2, 33, 33)];
        [self addSubview:aBtn];
        self.startStopButton = aBtn;
        
        UISlider *aSlider = [[UISlider alloc] initWithFrame:CGRectMake(48, 8, 117, 23)];
        [aSlider addTarget:self action:@selector(actionAdjustVolume:) forControlEvents:UIControlEventValueChanged];
        [aSlider setMinimumTrackImage:[[UIImage imageNamed:@"blackslider.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [self addSubview:aSlider];
        self.volumeSlider = aSlider;
        [aSlider release];
              
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
    return [view autorelease];
}


-(void)setAudioProvider:(id<MFAudioProvider>)provider{
    
    float volumeLevel = 0;
    
    audioProvider = provider;
    
    if([audioProvider isPlaying]) {
         [startStopButton setBackgroundImage:[UIImage imageNamed:PAUSE_IMG] forState:UIControlStateNormal];
    } else {
         [startStopButton setBackgroundImage:[UIImage imageNamed:PLAY_IMG] forState:UIControlStateNormal];
    }
    
    volumeLevel = [audioProvider volumeLevel];
    [volumeSlider setValue:volumeLevel];
    
}

/**
 Playback event methods.
 */

-(void)audioProviderDidStart:(id<MFAudioProvider>)mfeap{

    [self.startStopButton setBackgroundImage:[UIImage imageNamed:PAUSE_IMG] forState:UIControlStateNormal];
    
    
}

-(void)audioProvider:(id<MFAudioProvider>)mfap volumeAdjustedTo:(float)volume{

        
}

-(void)audioProviderDidStop:(id<MFAudioProvider>)mfeap{
    
    [self.startStopButton setBackgroundImage:[UIImage imageNamed:PLAY_IMG] forState:UIControlStateNormal];

}

- (void)dealloc
{
    [volumeSlider release];
    [startStopButton release];
    [super dealloc];
}

@end
