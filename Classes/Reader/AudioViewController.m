//
//  AudioViewController.m
//  FastPdfKit Sample
//
//  Created by Mac Book Pro on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioViewController.h"


@implementation AudioViewController

@synthesize volumeControl;
@synthesize local;
@synthesize url;
@synthesize audioPlayer;
@synthesize documentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil audioFilePath:(NSString *)_audioFilePath local:(BOOL)_isLocal{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        // Custom initialization
		local = _isLocal;
		if (local) {
			url = [NSURL fileURLWithPath:_audioFilePath];
		} else {
			url = [NSURL URLWithString:_audioFilePath];
		}
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    NSData * audioData = nil;
    NSError *error = nil;
    
    [super viewDidLoad];
    
	if (local) {
        
		audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	} else {
		
        audioData = [[NSData alloc] initWithContentsOfURL:url];
		audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
		[audioData release];
	}

	if (error) {
        
		NSLog(@"Error in audioPlayer: %@", 
			  [error localizedDescription]);
	} else {
        
		[audioPlayer setDelegate:self];
        [audioPlayer play];
	}
	
}


-(void)playAudio {
    [audioPlayer play];
}

-(void)stopAudio {
    [audioPlayer stop];
}

-(void)adjustVolume {
    
    if (audioPlayer) {
        
		audioPlayer.volume = volumeControl.value;
    }
}

-(void)closeController{
	documentViewController.multimediaVisible=NO;
    [audioPlayer stop];
    [[self view] removeFromSuperview];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	documentViewController.multimediaVisible=NO;
	[[self view] removeFromSuperview];
	
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
	
}
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
	
}
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player{
	
}

- (void)dealloc{
	
    [audioPlayer release];
    [volumeControl release];
    [url release];
    
    [super dealloc];
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    
    audioPlayer = nil;
    volumeControl = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
