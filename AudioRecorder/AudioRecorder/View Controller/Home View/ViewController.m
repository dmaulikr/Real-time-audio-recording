//
//  ViewController.m
//  AudioRecorder
//
//  Created by Pardeep on 02/02/15.
//
//

#import "ViewController.h"
#import "IosAudioController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View's life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)btnStartAction:(id)sender {
    [iosAudio start];
}

- (IBAction)btnStopAction:(id)sender {
	[iosAudio stop];
}

@end