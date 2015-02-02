//
//  IosAudioController.m
//  AudioRecorder
//
//  Created by Pardeep on 02/02/15.
//
//

#import "IosAudioController.h"
#import <AudioToolbox/AudioToolbox.h>

#define kOutputBus 0
#define kInputBus 1

IosAudioController* iosAudio;

void checkStatus(int status){
	if (status) {
		printf("Status not 0! %d\n", status);
	}
}

/**
 This callback is called when new audio data from the microphone is available.
 */
static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {
	AudioBuffer buffer;
	
	buffer.mNumberChannels = 1;
	buffer.mDataByteSize = inNumberFrames * 2;
	buffer.mData = malloc( inNumberFrames * 2 );
	
	// Put buffer in a AudioBufferList
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
	
    OSStatus status;
	
    status = AudioUnitRender([iosAudio audioUnit], 
                             ioActionFlags, 
                             inTimeStamp, 
                             inBusNumber, 
                             inNumberFrames, 
                             &bufferList);
	checkStatus(status);
	[iosAudio processAudio:&bufferList];
	
	// release the malloc'ed data in the buffer we created earlier
	free(bufferList.mBuffers[0].mData);
	
    return noErr;
}

/**
 This callback is called when the audioUnit needs new data to play through the speakers.
 */
static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {    
	for (int i=0; i < ioData->mNumberBuffers; i++) {
		AudioBuffer buffer = ioData->mBuffers[i];
		UInt32 size = min(buffer.mDataByteSize, [iosAudio tempBuffer].mDataByteSize);
		memcpy(buffer.mData, [iosAudio tempBuffer].mData, size);
		buffer.mDataByteSize = size;
	}
	
    return noErr;
}

@implementation IosAudioController

@synthesize audioUnit, tempBuffer;


- (id) init {
	self = [super init];
	
	OSStatus status;
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	checkStatus(status);
	
	// Enable IO for recording
	UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Input, 
								  kInputBus,
								  &flag, 
								  sizeof(flag));
	checkStatus(status);
	
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Output, 
								  kOutputBus,
								  &flag, 
								  sizeof(flag));
	checkStatus(status);
	
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate			= 44100.00;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
	
	status = AudioUnitSetProperty(audioUnit,
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  kInputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	checkStatus(status);
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	checkStatus(status);
	
	
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = recordingCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
	status = AudioUnitSetProperty(audioUnit,
								  kAudioOutputUnitProperty_SetInputCallback, 
								  kAudioUnitScope_Global, 
								  kInputBus, 
								  &callbackStruct, 
								  sizeof(callbackStruct));
	checkStatus(status);
	
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	checkStatus(status);
	
	flag = 0;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output, 
								  kInputBus,
								  &flag, 
								  sizeof(flag));
	
	tempBuffer.mNumberChannels = 1;
	tempBuffer.mDataByteSize = 512 * 2;
	tempBuffer.mData = malloc( 512 * 2 );
	
	status = AudioUnitInitialize(audioUnit);
	checkStatus(status);
	
	return self;
}

/**
 Start the audioUnit. This means data will be provided from the microphone, and requested for feeding to the speakers, by use of the provided callbacks.
 */
- (void) start {
	OSStatus status = AudioOutputUnitStart(audioUnit);
	checkStatus(status);
}

/**
 Stop the audioUnit
 */
- (void) stop {
	OSStatus status = AudioOutputUnitStop(audioUnit);
	checkStatus(status);
}

/**
 Change this funtion to decide what is done with incoming audio data from the microphone.
 Right now we copy it to our own temporary buffer.
 */
- (void) processAudio: (AudioBufferList*) bufferList{
	AudioBuffer sourceBuffer = bufferList->mBuffers[0];
	
	if (tempBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
		free(tempBuffer.mData);
		tempBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
		tempBuffer.mData = malloc(sourceBuffer.mDataByteSize);
	}
	
	memcpy(tempBuffer.mData, bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize);
}

/**
 Clean up.
 */
- (void) dealloc {
	AudioUnitUninitialize(audioUnit);
	free(tempBuffer.mData);
}

@end