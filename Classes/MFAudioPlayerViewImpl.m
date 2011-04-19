//
//  MFAudioPlayerViewImpl.m
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 19/04/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "MFAudioPlayerViewImpl.h"
#import "MFAudioProvider.h"


@implementation MFAudioPlayerViewImpl

@synthesize startStopButton;
@synthesize volumeSlider;
@synthesize audioProvider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        UIImageView *backgroundImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hud_player.png"]];
        [backgroundImageView setFrame:CGRectMake(0, 0, 272, 40)];
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [aBtn setBackgroundImage:[UIImage imageNamed:@"play_player.png"] forState:UIControlStateNormal];
        [aBtn addTarget:self action:@selector(actionTogglePlay:) forControlEvents:UIControlEventTouchUpInside];
        [aBtn setFrame:CGRectMake(8, 2, 33, 33)];
        [self addSubview:aBtn];
        self.startStopButton = aBtn;
        
        UISlider *aSlider = [[UISlider alloc] initWithFrame:CGRectMake(48, 8, 117, 23)];
        [aSlider addTarget:self action:@selector(actionAdjustVolume:) forControlEvents:UIControlEventValueChanged];
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
    
    self.audioProvider = provider;

}

/**
 Playback event methods.
 */

-(void)audioProviderDidStart:(id<MFAudioProvider>)mfeap{

    [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"pause_player.png"] forState:UIControlStateNormal];
    
    
}

-(void)audioProvider:(id<MFAudioProvider>)mfap volumeAdjustedTo:(float)volume{

        
}

-(void)audioProviderDidStop:(id<MFAudioProvider>)mfeap{
    
    NSLog(@"audioProviderDidStop");
    
    [self.startStopButton setBackgroundImage:[UIImage imageNamed:@"play_player.png"] forState:UIControlStateNormal];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [volumeSlider release];
    [startStopButton release];
    [super dealloc];
}

@end
