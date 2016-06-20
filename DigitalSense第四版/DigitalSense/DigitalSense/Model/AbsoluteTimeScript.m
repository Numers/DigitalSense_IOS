//
//  AbsoluteTimeScript.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "AbsoluteTimeScript.h"
#import "ScriptTaskTime.h"

@implementation AbsoluteTimeScript
-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithDictionary:dic];
    if (self) {
        if (dic) {
            _TaskTimeList = [NSMutableArray array];
            self.scriptCommandList = [NSMutableArray array];
            NSArray *dateArr = [dic objectForKey:@"date"];
            if (dateArr) {
                for (NSDictionary *dateDic in dateArr) {
                    ScriptTaskTime *taskTime = [[ScriptTaskTime alloc] init];
                    taskTime.startDay = [[dateDic objectForKey:@"start_year"] doubleValue];
                    taskTime.endDay = [[dateDic objectForKey:@"end_year"] doubleValue];
                    taskTime.week = [dateDic objectForKey:@"week"];
                    taskTime.startTime = [[dateDic objectForKey:@"start_time"] doubleValue];
                    taskTime.endTime = [[dateDic objectForKey:@"end_time"] doubleValue];
                    [_TaskTimeList addObject:taskTime];
                    
                    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                    if (now < taskTime.startDay && taskTime.startDay <= taskTime.endDay && taskTime.startTime < taskTime.endTime) {
                        if ([AppUtils isNullStr:taskTime.week]) {
                            NSTimeInterval startTime = taskTime.startDay + taskTime.startTime;
                            NSTimeInterval endTime = taskTime.endDay + taskTime.endTime;
                            if (self.isLoop) {
                                NSTimeInterval tempStartTime = startTime;
                                NSInteger index = 0;
                                while (tempStartTime < endTime) {
                                    NSArray *commandArr = [dic objectForKey:@"schedule"];
                                    if (commandArr) {
                                        for (NSDictionary *tempDic in commandArr) {
                                            ScriptCommand *command = [[ScriptCommand alloc] init];
                                            command.startRelativeTime = [[tempDic objectForKey:@"many"] integerValue];
                                            command.rfId = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"sn"]];
                                            command.duration = [[tempDic objectForKey:@"keep"] integerValue];
                                            if ((tempStartTime + command.startRelativeTime) >= endTime) {
                                                break;
                                            }
                                            if ((tempStartTime + command.startRelativeTime + command.duration) > endTime) {
                                                command.duration = endTime - startTime - command.startRelativeTime;
                                            }
                                            command.desc = [tempDic objectForKey:@"input"];
                                            
                                            NSTimeInterval scheduleStartTime = startTime + [[NSNumber numberWithInteger:command.startRelativeTime] doubleValue];
                                            command.command = [NSString stringWithFormat:@"F600%@%@%04lX%02lX55",[self timeStrFromTimeInterval:scheduleStartTime],command.rfId,command.duration,index];
                                            [self.scriptCommandList addObject:command];
                                            index++;
                                        }
                                        
                                        if (self.scriptCommandList.count > 0) {
                                            ScriptCommand *lastCommand = [self.scriptCommandList lastObject];
                                            tempStartTime = tempStartTime + lastCommand.startRelativeTime + lastCommand.duration;
                                            continue;
                                        }else{
                                            break;
                                        }
                                    }else{
                                        break;
                                    }
                                    
                                }
                            }else{
                                NSArray *commandArr = [dic objectForKey:@"schedule"];
                                if (commandArr) {
                                    NSInteger index = 0;
                                    for (NSDictionary *tempDic in commandArr) {
                                        ScriptCommand *command = [[ScriptCommand alloc] init];
                                        command.startRelativeTime = [[tempDic objectForKey:@"many"] integerValue];
                                        command.rfId = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"sn"]];
                                        command.duration = [[tempDic objectForKey:@"keep"] integerValue];
                                        if ((startTime + command.startRelativeTime) >= endTime) {
                                            break;
                                        }
                                        if ((startTime + command.startRelativeTime + command.duration) > endTime) {
                                            command.duration = endTime - startTime - command.startRelativeTime;
                                        }
                                        command.desc = [tempDic objectForKey:@"input"];
                                        
                                        NSTimeInterval scheduleStartTime = startTime + [[NSNumber numberWithInteger:command.startRelativeTime] doubleValue];
                                        command.command = [NSString stringWithFormat:@"F600%@%@%04lX%02lX55",[self timeStrFromTimeInterval:scheduleStartTime],command.rfId,command.duration,index];
                                        [self.scriptCommandList addObject:command];
                                        index++;
                                    }
                                }
                            }
                        }else{
                            
                            
                            
                            
                        }
                    }
                }
            }
        }
    }
    return self;
}

-(NSString *)timeStrFromTimeInterval:(NSTimeInterval)interval
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyMMddHHmmss"];
    NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *dateStr = [formatter stringFromDate:dateTime];
    return dateStr;
}
@end
