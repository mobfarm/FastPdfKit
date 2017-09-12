//
//  AudioViewController.h
//  FastPdfKit
//
//  Created by Mac Book Pro on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ReaderViewController.h"


@interface AudioViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) IBOutlet UISlider *volumeControl;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, readwrite, getter = isLocal) BOOL local;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, weak) ReaderViewController *documentViewController;

- (IBAction) playAudio;
- (IBAction) stopAudio;
- (IBAction) closeController;
- (IBAction) adjustVolume;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil audioFilePath:(NSString *)anAudioFilePath local:(BOOL)isLocal;

@end
