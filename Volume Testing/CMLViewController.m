//
//  CMLViewController.m
//  Volume Testing
//
//  Created by John Clayton on 10/14/13.
//  Copyright (c) 2013 Code Monkey Labs LLC. All rights reserved.
//

#import "CMLViewController.h"

@import AVFoundation;
@import MediaPlayer;

@interface CMLViewController ()

@property (nonatomic, strong) AVAudioPlayer *shortPlayer;
@property (nonatomic, strong) AVAudioPlayer *longPlayer;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation CMLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
    [session setMode:AVAudioSessionModeMeasurement error:nil];
    [session addObserver:self
              forKeyPath:@"outputVolume"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    
    [self systemVolumeDidChange];
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *recorderSettings = @{ AVSampleRateKey: [NSNumber numberWithFloat:44100.0],
                                        AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatAppleLossless],
                                        AVNumberOfChannelsKey: [NSNumber numberWithInt:1],
                                        AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityMax] };
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recorderSettings error:nil];
    self.recorder.meteringEnabled = YES;
    [self.recorder record];
    
    NSURL *shortWaveURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sin_2330Hz_0.5s" ofType:@"wav"]];
    self.shortPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:shortWaveURL error:nil];
    [self.shortPlayer prepareToPlay];
    self.shortPlayer.volume = session.outputVolume;
    
    NSURL *longWaveURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sin_2330Hz_10s" ofType:@"wav"]];
    self.longPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:longWaveURL error:nil];
    [self.longPlayer prepareToPlay];
    self.longPlayer.volume = session.outputVolume;
    
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    [self.shortPlayer addObserver:self
                       forKeyPath:@"volume"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    [self.longPlayer addObserver:self
                       forKeyPath:@"volume"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    
    [self playerVolumeDidChange:self.playerVolumeSlider];
}

- (void)dealloc
{
    [[AVAudioSession sharedInstance] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"outputVolume"]) {
        [self systemVolumeDidChange];
    } else if ([keyPath isEqualToString:@"volume"]) {
        [self showActualPlayerVolume];
    }
}

- (void)systemVolumeDidChange
{
    self.systemVolumeLabel.text = [NSString stringWithFormat:@"%.4f", [[AVAudioSession sharedInstance] outputVolume]];
}

- (IBAction)playerVolumeDidChange:(id)sender {
    UISlider *playerVolumeSlider = (UISlider *)sender;
    self.shortPlayer.volume = self.longPlayer.volume = playerVolumeSlider.value;
    self.playerVolumeLabel.text = [NSString stringWithFormat:@"%.4f", playerVolumeSlider.value];
}

- (void)showActualPlayerVolume
{
    self.actualPlayerVolume.text = [NSString stringWithFormat:@"%.4f", self.shortPlayer.volume];
}

- (IBAction)playShortTapped:(id)sender
{
    NSAssert(self.shortPlayer.volume == self.longPlayer.volume, @"Volumes should be identical");
    [self showActualPlayerVolume];
    [self.shortPlayer play];
}

- (IBAction)playLongTapped:(id)sender
{
    NSAssert(self.shortPlayer.volume == self.longPlayer.volume, @"Volumes should be identical");
    [self showActualPlayerVolume];
    [self.longPlayer play];
}

- (IBAction)speakTapped:(id)sender
{
    AVSpeechUtterance *speechUtterance = [AVSpeechUtterance speechUtteranceWithString:@"Pump up the volume."];
    speechUtterance.rate = 0.15;
    speechUtterance.volume = self.playerVolumeSlider.value;
    [self.speechSynthesizer speakUtterance:speechUtterance];
}



@end
