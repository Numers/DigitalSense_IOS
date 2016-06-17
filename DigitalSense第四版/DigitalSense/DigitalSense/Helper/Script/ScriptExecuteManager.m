//
//  ScriptExecuteManager.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptExecuteManager.h"
#import "Script.h"
#import "ScriptCommand.h"
static ScriptExecuteManager *scriptExecuteManager;
static NSInteger currentSecond = -1;
@implementation ScriptExecuteManager
+(id)defaultManager
{
    if (scriptExecuteManager == nil) {
        scriptExecuteManager = [[ScriptExecuteManager alloc] init];
    }
    return scriptExecuteManager;
}

/**
 *  @author RenRenFenQi, 16-06-16 16:06:34
 *
 *  执行相对时间脚本
 *
 *  @param script 脚本
 */
-(void)executeRelativeTimeScript:(Script *)script
{
    if (script) {
        script.state = ScriptIsWaiting;
        if (scriptQueue) {
            [scriptQueue addObject:script];
        }else{
            scriptQueue = [NSMutableArray arrayWithObject:script];
        }
    }
    [self playRelativeTimeScript];
}

/**
 *  @author RenRenFenQi, 16-06-16 16:06:00
 *
 *  解析一个相对时间脚本
 *
 *  @param script 相对时间脚本
 */
-(void)dowithRelativeTimeScript:(Script *)script
{
    if (script == nil) {
        return;
    }
    
    if (scriptCommandQueue) {
        [scriptCommandQueue removeAllObjects];
    }else{
        scriptCommandQueue = [NSMutableArray array];
    }
    
    //开始解析脚本
}

/**
 *  @author RenRenFenQi, 16-06-16 16:06:52
 *
 *  开始执行一个脚本
 */
-(void)playRelativeTimeScript
{
    if (currentPlayingScript != nil) {
        return;
    }
    
    if (scriptQueue && scriptQueue.count > 0) {
        currentSecond = -1;
        if (timer) {
            if ([timer isValid]) {
                [timer invalidate];
                timer = nil;
            }
        }
        Script *script = [scriptQueue objectAtIndex:0];
        currentPlayingScript = script;
        [self dowithRelativeTimeScript:script];
        [scriptQueue removeObjectAtIndex:0];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countTime) userInfo:nil repeats:YES];
        [timer fire];
        currentPlayingScript.state = ScriptIsPlaying;
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayScriptNotification object:currentPlayingScript];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayOverAllScriptsNotification object:nil];
    }
}

-(void)countTime
{
    currentSecond++;
    if (currentSecond > currentPlayingScript.scriptTime) {
        [self playOverRelativeTimeScript];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayProgressSecondNotification object:[NSNumber numberWithInteger:currentSecond]];
        [self searchTimeToExecuteCommand];
    }
}

/**
 *  @author RenRenFenQi, 16-06-16 17:06:37
 *
 *  查找时间点，如有记录则执行对应指令
 */
-(void)searchTimeToExecuteCommand
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.startRelativeTime == %ld",currentSecond];
    NSArray *filterArr = [scriptCommandQueue filteredArrayUsingPredicate:predicate];
    if (filterArr && filterArr.count > 0) {
        ScriptCommand *command = [filterArr objectAtIndex:0];
        //往蓝牙发送command
        
        //往UI通知当前执行的命令
        [[NSNotificationCenter defaultCenter] postNotificationName:SendScriptCommandNotification object:command];
    }
}
/**
 *  @author RenRenFenQi, 16-06-16 16:06:25
 *
 *  结束执行一个脚本
 */
-(void)playOverRelativeTimeScript
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
    currentPlayingScript.state = ScriptIsNormal;
    currentPlayingScript = nil;
    [self playRelativeTimeScript];
}
/**
 *  @author RenRenFenQi, 16-06-16 16:06:52
 *
 *  执行绝对时间脚本
 *
 *  @param scriptArr 绝对时间脚本数组
 */
-(void)executeAbsoluteTimeScript:(NSArray *)scriptArr
{
    
}
@end
