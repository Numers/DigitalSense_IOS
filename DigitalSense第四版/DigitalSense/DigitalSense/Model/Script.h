//
//  Script.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ScriptStateComfirmed @"ScriptStateComfirmed"
typedef enum{
    ScriptIsNormal, //未播放状态
    ScriptIsWaiting, //排队中
    ScriptIsPlaying //播放中
} ScriptState;

typedef enum{
    ScriptIsAbsoluteTime, //绝对时间脚本
    ScriptIsRelativeTime //相对时间脚本
} ScriptType;
@interface Script : NSObject
@property(nonatomic, copy) NSString *scriptId;
@property(nonatomic, copy) NSString *scriptName;
@property(nonatomic, copy) NSString *scriptContent;
@property(nonatomic) NSInteger scriptTime;

@property(nonatomic) ScriptState state;
@property(nonatomic) ScriptType type;
@end
