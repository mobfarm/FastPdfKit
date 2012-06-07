//
//  MFAudioPlayerViewImpl.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 19/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFAudioPlayerViewProtocol.h"
#import "MFAudioProvider.h"


@interface MFAudioPlayerViewImpl : UIView <MFAudioPlayerViewProtocol> {
    
    UIButton *startStopButton;
    UISlider *volumeSlider;
    
    id<MFAudioProvider> audioProvider;
    
}

@property (nonatomic,retain) UIButton *startStopButton;
@property (nonatomic,retain) UISlider *volumeSlider;
@property (nonatomic,assign) id<MFAudioProvider> audioProvider;

@end
