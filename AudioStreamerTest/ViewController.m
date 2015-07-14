//
//  ViewController.m
//  AudioStreamerTest
//
//  Created by Ryan King on 7/13/15.
//  Copyright (c) 2015 Ryan King. All rights reserved.
//

#import "ViewController.h"
#import "TheAmazingAudioEngine.h"

static const int kInputChannelsChangedContext;


@interface ViewController ()

@property AEAudioController* audioController;
@property AEAudioFilePlayer* audioFilePlayer;

@property BOOL loopingEnabled;
@property NSTimeInterval audioDuration;
@property NSTimer* updateTimer;
@property BOOL resumePlayAfterPlayheadSlide;
@property BOOL changingSliderPosition;

@end

@implementation ViewController

- (void) dealloc {
    [_audioController removeObserver:self forKeyPath:@"numberOfInputChannels"];

    [_audioController removeChannels:@[_audioFilePlayer]];
}

- (void) updatePlayheadSlider:(NSTimer*) timer {
    if(!_changingSliderPosition)
        _playheadSlider.value = _audioFilePlayer.currentTime / _audioDuration;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupAudioEngine];
    _changingSliderPosition = false;
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updatePlayheadSlider:) userInfo:nil repeats:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPushed:(id)sender {
    UIButton* button = sender;
    if(button.selected) {
        button.selected = false;
        _audioFilePlayer.channelIsPlaying = false;
    }
    else {
        button.selected = true;
        _audioFilePlayer.channelIsPlaying = true;
    }
}

- (IBAction)loopSwitchChanged:(id)sender {
    self.loopingEnabled = !self.loopingEnabled;
    
    // set this property of the audio file player
    _audioFilePlayer.loop = self.loopingEnabled;
}

- (IBAction)playheadSliderTouchBegin:(id)sender {
    // Stop playing if we are playing
    _resumePlayAfterPlayheadSlide = _playButton.selected;
    if(_playButton.selected) {
        _playButton.selected = false;
        _audioFilePlayer.channelIsPlaying = false;
    }
    _changingSliderPosition = true;
}

- (IBAction)playheadSliderTouchEnd:(id)sender {
    _audioFilePlayer.currentTime = _playheadSlider.value*_audioDuration;
    if(_resumePlayAfterPlayheadSlide) {
        _playButton.selected = true;
        _audioFilePlayer.channelIsPlaying = true;
    }
    _changingSliderPosition = false;
}

- (void) setupAudioEngine {
    // Set up AEAudioController
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:NO];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    
    NSError* error;
    [_audioController start:&error];
    if(error != NULL) {
        NSLog(@"Error starting audio engine: %@",error.description);
    }
    
    // Set up audio file player
    error = NULL;
    _audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Southern Rock Drums" withExtension:@"m4a"] audioController:_audioController error:&error];
    if(error != NULL) {
        NSLog(@"File Could Not Be Loaded:%@",error.description);
    }
    else {
        NSLog(@"Loaded Successfully");
    }
    
    _audioFilePlayer.volume = 1.0;
    _audioFilePlayer.loop = false;
    _audioFilePlayer.channelIsPlaying = false;
    self.loopingEnabled = false;
    _audioDuration = _audioFilePlayer.duration;
    
    // Make sure audio file player turns off play button if looping is off. Should only be called if looping is off
    __weak ViewController *weakSelf = self;
    _audioFilePlayer.completionBlock = ^{
        ViewController* strongSelf = weakSelf;
        
        strongSelf.playButton.selected = false;
    };
    
    // Add audio channels
    [_audioController addChannels:@[_audioFilePlayer]];
    
    [_audioController addObserver:self forKeyPath:@"numberOfInputChannels" options:0 context:(void*)&kInputChannelsChangedContext];
}

@end
