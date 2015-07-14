//
//  ViewController.h
//  AudioStreamerTest
//
//  Created by Ryan King on 7/13/15.
//  Copyright (c) 2015 Ryan King. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *playheadSlider;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playButtonPushed:(id)sender;
- (IBAction)loopSwitchChanged:(id)sender;
- (IBAction)playheadSliderTouchBegin:(id)sender;
- (IBAction)playheadSliderTouchEnd:(id)sender;

@end

