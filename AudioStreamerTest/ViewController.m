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
@property AEAudioFilePlayer* oneShotFilePlayer;

@end

@implementation ViewController

- (void) dealloc {
    [_audioController removeObserver:self forKeyPath:@"numberOfInputChannels"];

    [_audioController removeChannels:@[_audioFilePlayer]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupAudioEngine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPushed:(id)sender {
    _audioFilePlayer.channelIsMuted = !_audioFilePlayer.channelIsMuted;
}

- (IBAction)playOnceButtonPushed:(id)sender {
    if(_oneShotFilePlayer) {
        // Kill it
    }
    else {
        // Start the file playing
        NSError* error;
        _oneShotFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Southern Rock Drums" withExtension:@"m4a"] audioController:_audioController error:&error];
        if(error != NULL) {
            NSLog(@"Error reading the file: %@",error.description);
        }
        _oneShotFilePlayer.volume = 1.0;
        _oneShotFilePlayer.loop = NO;
        _oneShotFilePlayer.removeUponFinish = YES;
        __weak ViewController* weakSelf = self;
        
        _oneShotFilePlayer.completionBlock = ^{
            ViewController *strongSelf = weakSelf;
            strongSelf.oneShotFilePlayer = nil;
        };
        
        [_audioController addChannels:@[_oneShotFilePlayer]];
    }
    
}

- (void) setupAudioEngine {
    // Set up AEAudioController
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:NO];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    [_audioController start:NULL];
    
    // Set up audio file player
    NSError* error;
    _audioFilePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[[NSBundle mainBundle] URLForResource:@"Southern Rock Drums" withExtension:@"m4a"] audioController:_audioController error:&error];
    if(error != NULL) {
        NSLog(@"File Could Not Be Loaded:%@",error.description);
    }
    else {
        NSLog(@"Loaded Successfully");
    }
    
    _audioFilePlayer.volume = 1.0;
    _audioFilePlayer.loop = YES;
    _audioFilePlayer.channelIsMuted = YES;
    
    // Add audio channels
    [_audioController addChannels:@[_audioFilePlayer]];
    
    [_audioController addObserver:self forKeyPath:@"numberOfInputChannels" options:0 context:(void*)&kInputChannelsChangedContext];
}

@end
