//
//  RelativeTimeScript.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "RelativeTimeScript.h"

@implementation RelativeTimeScript
-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithDictionary:dic];
    if (self) {
        self.scriptTime = [[dic objectForKey:@"long"] integerValue] * 60;
        self.scriptCommandList = [NSMutableArray array];
        NSArray *commandArr = [dic objectForKey:@"schedule"];
        if (commandArr) {
            for (NSDictionary *tempDic in commandArr) {
                ScriptCommand *command = [[ScriptCommand alloc] init];
                command.startRelativeTime = [[tempDic objectForKey:@"many"] integerValue];
                command.rfId = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"bottle_sn"]];
                command.duration = [[tempDic objectForKey:@"keep"] integerValue];
                command.smellName = [tempDic objectForKey:@"input"];
                command.desc = [tempDic objectForKey:@"input"];
                command.command = [NSString stringWithFormat:@"F501%@%04lX55",command.rfId,(long)command.duration];
                [self.scriptCommandList addObject:command];
            }
        }
    }
    return self;
}

-(NSString *)commandString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if (self.isLoop) {
        if (self.scriptCommandList && self.scriptCommandList.count > 0){
            NSInteger i = 0, j = 1;
            while (i >= 0) {
                ScriptCommand *lastCommand = [self.scriptCommandList lastObject];
                NSInteger baseTime = i * (lastCommand.startRelativeTime + lastCommand.duration);
                for (ScriptCommand *command in self.scriptCommandList) {
                    NSInteger startTime = baseTime + command.startRelativeTime;
                    NSInteger duration = command.duration;
                    if ((startTime + duration) > self.scriptTime) {
                        duration = self.scriptTime - startTime;
                        i = -2;
                    }
                    NSString *str = [NSString stringWithFormat:@"播放气味%ld: 【%@,%@】播放，持续%ld秒\n",(long)j,[self switchSecondsToTime:startTime],command.smellName,duration];
                    [result appendString:str];
                    j++;
                    
                    if (i == -2) {
                        break;
                    }
                    i++;
                }
            }
        }
    }else{
        if (self.scriptCommandList && self.scriptCommandList.count > 0) {
            NSInteger i = 1;
            for (ScriptCommand *command in self.scriptCommandList) {
                NSString *str = [NSString stringWithFormat:@"播放气味%ld: 【%@,%@】播放，持续%ld秒\n",(long)i,[self switchSecondsToTime:command.startRelativeTime],command.smellName,(long)command.duration];
                [result appendString:str];
                i++;
            }
        }

    }
    return result;
}
@end
