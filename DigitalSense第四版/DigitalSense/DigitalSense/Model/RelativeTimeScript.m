//
//  RelativeTimeScript.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "RelativeTimeScript.h"
#import "Fruit.h"

@implementation RelativeTimeScript
-(id)initWithDictionary:(NSDictionary *)dic WithModeList:(NSArray *)modeList
{
    self = [super initWithDictionary:dic WithModeList:modeList];
    if (self) {
        self.scriptTime = [[dic objectForKey:@"long"] integerValue];
        self.scriptCommandList = [NSMutableArray array];
        NSArray *commandArr = [dic objectForKey:@"schedule"];
        if (commandArr) {
            for (NSDictionary *tempDic in commandArr) {
                NSString *sn = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"sn"]];
                Fruit *fruit = [self searchRFIDWithFruitSn:sn WithModeList:modeList];
                ScriptCommand *command = [[ScriptCommand alloc] init];
                command.startRelativeTime = [[tempDic objectForKey:@"many"] integerValue];
                command.duration = [[tempDic objectForKey:@"keep"] integerValue];
                if (fruit == nil) {
                    command.rfId = nil;
                    command.smellName = nil;
                    command.command = nil;
                }else{
                    command.rfId = fruit.fruitRFID;
                    command.smellName = fruit.fruitName;
                    command.command = [NSString stringWithFormat:@"F501%@%04lX55",command.rfId,(long)command.duration];
                }
                command.desc = [tempDic objectForKey:@"input"];
                [self.scriptCommandList addObject:command];
            }
        }
    }
    return self;
}

-(NSString *)commandString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"脚本任务:%@\n",self.scriptName];
    if (self.isLoop) {
        [result appendFormat:@"播放方式:循环播放\n"];
        if (self.scriptCommandList && self.scriptCommandList.count > 0){
            NSInteger i = 0, j = 1;
            while (i >= 0) {
                ScriptCommand *lastCommand = [self.scriptCommandList lastObject];
                NSInteger baseTime = i * (lastCommand.startRelativeTime + lastCommand.duration);
                for (ScriptCommand *command in self.scriptCommandList) {
                    NSInteger startTime = baseTime + command.startRelativeTime;
                    NSInteger duration = command.duration;
                    if ((startTime + duration) >= self.scriptTime) {
                        duration = self.scriptTime - startTime;
                        i = -2;
                    }
                    
                    if (duration > 0) {
                        NSString *str = [NSString stringWithFormat:@"播放气味%ld: 【%@,%@】播放，持续%ld秒\n",(long)j,[self switchSecondsToTime:startTime],command.smellName,(long)duration];
                        [result appendString:str];
                        
                        j++;
                    }
                    
                    if (i == -2) {
                        break;
                    }
                }
                i++;
            }
        }
    }else{
        [result appendFormat:@"播放方式:单次播放\n"];
        if (self.scriptCommandList && self.scriptCommandList.count > 0) {
            NSInteger i = 1;
            for (ScriptCommand *command in self.scriptCommandList) {
                NSInteger duration = command.duration;
                if ((command.startRelativeTime + command.duration) >= self.scriptTime) {
                    duration = self.scriptTime - command.startRelativeTime;
                }
                
                if (duration > 0) {
                    NSString *str = [NSString stringWithFormat:@"播放气味%ld: 【%@,%@】播放，持续%ld秒\n",(long)i,[self switchSecondsToTime:command.startRelativeTime],command.smellName,(long)command.duration];
                    [result appendString:str];
                    i++;
                }
            }
        }

    }
    return result;
}
@end
