//
//  AudioViewController.h
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DocumentViewController_Kiosk.h"


@interface AudioViewController : UIViewController <AVAudioPlayerDelegate>{
	
	AVAudioPlayer *audioPlayer;
	UISlider *volumeControl;
	BOOL local;
	NSURL *url;
	DocumentViewController_Kiosk *documentViewController;
}

@property (nonatomic, retain) IBOutlet UISlider *volumeControl;
@property (nonatomic, assign) AVAudioPlayer *audioPlayer;
@property (nonatomic, readwrite, getter = isLocal) BOOL local;
@property (nonatomic, retain) NSURL *url; 
@property (nonatomic,assign) DocumentViewController_Kiosk *documentViewController;

- (IBAction) playAudio;
- (IBAction) stopAudio;
- (IBAction) closeController;
- (IBAction) adjustVolume;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil audioFilePath:(NSString *)anAudioFilePath local:(BOOL)isLocal;

@end
