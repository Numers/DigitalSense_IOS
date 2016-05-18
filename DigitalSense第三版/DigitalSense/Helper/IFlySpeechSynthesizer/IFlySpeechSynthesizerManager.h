//
//  IFlySpeechSynthesizerManager.h
//  DigitalSense
//
//  Created by baolicheng on 16/5/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iflyMSC/IFlySpeechSynthesizer.h>
typedef void (^SynthesizerCallback) (BOOL completely);

@class PcmPlayer;
@interface IFlySpeechSynthesizerManager : NSObject<IFlySpeechSynthesizerDelegate>
{
    SynthesizerCallback synthesizerCallback;
    BOOL recognizeSuccess;
}
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
+(id)defaultManager;

-(void)startSpeeking:(BOOL)isSuccess Callback:(SynthesizerCallback)callBack;
@end
