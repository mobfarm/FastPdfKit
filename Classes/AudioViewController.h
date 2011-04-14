//
//  AudioViewController.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioViewController : UIViewController <AVAudioPlayerDelegate>{
	
	AVAudioPlayer *audioPlayer;
	UISlider *volumeControl;
	BOOL isLocal;
	NSURL *url;
    
}

@property (nonatomic, retain) IBOutlet UISlider *volumeControl;
@property (nonatomic, assign) AVAudioPlayer *audioPlayer;
@property BOOL isLocal;
@property (nonatomic, retain) NSURL *url; 

- (IBAction) playAudio;
- (IBAction) stopAudio;
- (IBAction) adjustVolume;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil audioFilePath:(NSString *)_audioFilePath isLocal:(BOOL)_isLocal;

@end
