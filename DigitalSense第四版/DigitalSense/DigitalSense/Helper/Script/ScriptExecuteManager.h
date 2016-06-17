//
//  ScriptExecuteManager.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PlayScriptNotification @"PlayScriptNotification"
#define PlayOverAllScriptsNotification @"PlayOverAllScriptsNotification"
#define SendScriptCommandNotification @"SendScriptCommandNotification"
#define PlayProgressSecondNotification @"PlayProgressSecondNotification"
@class Script;
@interface ScriptExecuteManager : NSObject
{
    NSMutableArray *scriptQueue; //相对时间脚本队列
    NSMutableArray *scriptCommandQueue;  //指令队列
    
    Script *currentPlayingScript; //当前播放的脚本
    NSTimer *timer; //计时器
}
+(id)defaultManager;
/**
 *  @author RenRenFenQi, 16-06-16 16:06:34
 *
 *  执行相对时间脚本
 *
 *  @param script 脚本
 */
-(void)executeRelativeTimeScript:(Script *)script;
/**
 *  @author RenRenFenQi, 16-06-16 16:06:52
 *
 *  执行绝对时间脚本
 *
 *  @param scriptArr 绝对时间脚本数组
 */
-(void)executeAbsoluteTimeScript:(NSArray *)scriptArr;

-(rac)
@end
