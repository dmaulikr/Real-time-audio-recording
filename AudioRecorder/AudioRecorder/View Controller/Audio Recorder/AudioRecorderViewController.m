//
//  AudioRecorderViewController.m
//  AudioRecorder
//
//  Created by Pardeep on 10/02/15.
//
//

#import "AudioRecorderViewController.h"
#import "IosAudioController.h"

@interface AudioRecorderViewController ()

@end

@implementation AudioRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNavigationBar];
    [self setUIElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigation setup
-(void)setUpNavigationBar{
    self.navigationItem.title = @"Speak";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark  - set UI Elements
-(void)setUIElements{
    UIButton *btnSpeak = (UIButton *)[self.view viewWithTag:1];
    [btnSpeak.layer setCornerRadius:3.0f];
    [btnSpeak.layer setBorderColor:[UIColor colorWithWhite:0.9f alpha:0.8f].CGColor];
    [btnSpeak.layer setBorderWidth:1.0f];

    UIButton *btnStopSpeak = (UIButton *)[self.view viewWithTag:2];
    [btnStopSpeak.layer setCornerRadius:3.0f];
    [btnStopSpeak.layer setBorderColor:[UIColor colorWithWhite:0.9f alpha:0.8f].CGColor];
    [btnStopSpeak.layer setBorderWidth:1.0f];
}

#pragma mark - IBAction methods
- (IBAction)btnSpeakHereAction:(id)sender {
    [iosAudio start];
}

- (IBAction)btnStopSpeakingAction:(id)sender {
    [iosAudio stop];
}

@end
