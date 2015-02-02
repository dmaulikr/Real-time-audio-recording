//
//  main.m
//  AudioRecorder
//
//  Created by Pardeep on 02/02/15.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "IosAudioController.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        iosAudio = [[IosAudioController alloc] init];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
