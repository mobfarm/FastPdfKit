//
//  MFAudioPlayerViewImpl.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 19/04/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFAudioPlayerViewImpl.h"
#import "MFAudioProvider.h"
#import "Stuff.h"

#define PAUSE_IMG @"pause"

@implementation MFAudioPlayerViewImpl

@synthesize startStopButton;
@synthesize volumeSlider;
@synthesize audioProvider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        UIImage * backgroundImage = [UIImage imageNamed:@"alpha_75"];
        UIImageView *backgroundImageView =[[UIImageView alloc]initWithImage:backgroundImage];
        [backgroundImageView setFrame:CGRectMake(0, 0, 272, 40)];
        [self addSubview:backgroundImageView];
        
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage * playImage = [UIImage imageNamed:@"play"];
        [aBtn setBackgroundImage:playImage
                        forState:UIControlStateNormal];
        [aBtn addTarget:self
                 action:@selector(actionTogglePlay:)
       forControlEvents:UIControlEventTouchUpInside];
        [aBtn setFrame:CGRectMake(8, 2, 33, 33)];
        [self addSubview:aBtn];
        
        self.startStopButton = aBtn;
        
        UIImage * sliderImage = [UIImage imageNamed:@"slider_black"];
        UISlider *aSlider = [[UISlider alloc] initWithFrame:CGRectMake(48, 8, 117, 23)];
        [aSlider addTarget:self
                    action:@selector(actionAdjustVolume:)
          forControlEvents:UIControlEventValueChanged];
        [aSlider setMinimumTrackImage:sliderImage
                             forState:UIControlStateNormal];
        [self addSubview:aSlider];
        self.volumeSlider = aSlider;
              
    }
    return self;
}

-(void)actionTogglePlay:(id)sender
{
    [self.audioProvider togglePlay];
}

-(void)actionAdjustVolume:(id)sender
{
    [self.audioProvider setVolumeLevel:[self.volumeSlider value]];
}

+(UIView *)audioPlayerViewInstance{
    
    MFAudioPlayerViewImpl *view = [[MFAudioPlayerViewImpl alloc] initWithFrame:CGRectMake(0, 0, 272, 40)];
    return view;
}

-(void)setAudioProvider:(id<MFAudioProvider>)provider
{
    float volumeLevel = 0;
    
    audioProvider = provider;

    if([audioProvider isPlaying])
    {
        UIImage * pauseImage = [UIImage imageNamed:@"pause"];
        [startStopButton setBackgroundImage:pauseImage
                                   forState:UIControlStateNormal];
    } else {
        
        UIImage * playImage = [UIImage imageNamed:@"play"];
        [startStopButton setBackgroundImage:playImage
                                   forState:UIControlStateNormal];
    }
    
    volumeLevel = [audioProvider volumeLevel];
    [volumeSlider setValue:volumeLevel];
}

/**
 Playback event methods.
 */

-(void)audioProviderDidStart:(id<MFAudioProvider>)mfeap{

    UIImage * pauseImage = [UIImage imageNamed:@"pause"];
    [self.startStopButton setBackgroundImage:pauseImage
                                    forState:UIControlStateNormal];
}

-(void)audioProvider:(id<MFAudioProvider>)mfap
    volumeAdjustedTo:(float)volume
{

}

-(void)audioProviderDidStop:(id<MFAudioProvider>)mfeap
{
    UIImage * playImage = [UIImage imageNamed:@"play"];
    [self.startStopButton setBackgroundImage:playImage
                                    forState:UIControlStateNormal];

}


@end
