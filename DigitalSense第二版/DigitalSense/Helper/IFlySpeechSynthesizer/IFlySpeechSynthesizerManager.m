//
//  IFlySpeechSynthesizerManager.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "IFlySpeechSynthesizerManager.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioSession.h>
#import <iflyMSC/IFlySpeechConstant.h>
#import <AVFoundation/AVFoundation.h>
#import "PcmPlayer.h"

#define SuccessSpeakText @"好的"
#define FailedSpeakText @"不好意思，请再说一遍！"
static IFlySpeechSynthesizerManager *iFlySpeechSynthesizerManager;

static NSString *_urisuccessPath;
static NSString *_uriFailedPath;
@implementation IFlySpeechSynthesizerManager
+(id)defaultManager
{
    if (iFlySpeechSynthesizerManager == nil) {
        iFlySpeechSynthesizerManager = [[IFlySpeechSynthesizerManager alloc] init];
        NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        //uri合成路径设置
        _urisuccessPath = [NSString stringWithFormat:@"%@/%@",prePath,@"urisuccess.pcm"];
        _uriFailedPath = [NSString stringWithFormat:@"%@/%@",prePath,@"urifailed.pcm"];
    }
    return iFlySpeechSynthesizerManager;
}

-(void)initSynthesizer
{
    //合成服务单例
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    
    _iFlySpeechSynthesizer.delegate = self;
    
    _audioPlayer = [[PcmPlayer alloc] init];
}

-(void)startSpeeking:(BOOL)isSuccess Callback:(SynthesizerCallback)callBack
{
    synthesizerCallback = callBack;
    recognizeSuccess = isSuccess;
    [self initSynthesizer];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (isSuccess) {
        if ([fm fileExistsAtPath:_urisuccessPath]) {
            [self playUriAudio:_urisuccessPath];//播放合成的音频
            return;
        }
    }else{
        if ([fm fileExistsAtPath:_uriFailedPath]) {
            [self playUriAudio:_uriFailedPath];//播放合成的音频
            return;
        }
    }
    
    if (isSuccess) {
        [_iFlySpeechSynthesizer synthesize:SuccessSpeakText toUri:_urisuccessPath];
    }else{
        [_iFlySpeechSynthesizer synthesize:FailedSpeakText toUri:_uriFailedPath];
    }
}

#pragma mark - 播放uri合成音频

- (void)playUriAudio:(NSString *)uriPath
{
    NSError *error = [[NSError alloc] init];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [_audioPlayer setAudioData:uriPath];
    [_audioPlayer play];
    
    if (synthesizerCallback) {
        synthesizerCallback(YES);
    }
}

#pragma mark - 合成回调 IFlySpeechSynthesizerDelegate

/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakBegin
{
    NSLog(@"开始播放");
}



/**
 缓冲进度回调
 
 progress 缓冲进度
 msg 附加信息
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}




/**
 播放进度回调
 
 progress 缓冲进度
 
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakProgress:(int) progress
{
    NSLog(@"speak progress %2d%%.", progress);
}


/**
 合成暂停回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakPaused
{
    NSLog(@"speak paused");
}



/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakResumed
{
    NSLog(@"speak Resumed");
}

/**
 合成结束（完成）回调
 
 对uri合成添加播放的功能
 ****/
- (void)onCompleted:(IFlySpeechError *) error
{
    
    if (error.errorCode != 0) {
        NSLog(@"错误码:%d",error.errorCode);
        if (synthesizerCallback) {
            synthesizerCallback(NO);
        }
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (recognizeSuccess) {
        if ([fm fileExistsAtPath:_urisuccessPath]) {
            [self playUriAudio:_urisuccessPath];//播放合成的音频
        }
    }else{
        if ([fm fileExistsAtPath:_uriFailedPath]) {
            [self playUriAudio:_uriFailedPath];//播放合成的音频
        }
    }
}




/**
 取消合成回调
 ****/
- (void)onSpeakCancel
{
    NSLog(@"取消合成");
    
}

@end
