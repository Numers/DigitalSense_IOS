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
                NSInteger index = 0;
                for (NSDictionary *dateDic in dateArr) {
                    ScriptTaskTime *taskTime = [[ScriptTaskTime alloc] init];
                    taskTime.startDay = [[dateDic objectForKey:@"start_year"] doubleValue];
                    taskTime.endDay = [[dateDic objectForKey:@"end_year"] doubleValue];
                    taskTime.week = [dateDic objectForKey:@"week"];
                    taskTime.startTime = [[dateDic objectForKey:@"start_time"] doubleValue];
                    taskTime.endTime = [[dateDic objectForKey:@"end_time"] doubleValue];
                    [_TaskTimeList addObject:taskTime];
                    
                    
                    if (taskTime.startTime < taskTime.endTime) {
                        if ([AppUtils isNullStr:taskTime.week]) {
                            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                            if (now < taskTime.startDay && taskTime.startDay <= taskTime.endDay) {
                                NSTimeInterval startTime = taskTime.startDay + taskTime.startTime;
                                NSTimeInterval endTime = taskTime.endDay + taskTime.endTime;
                                if (self.isLoop) {
                                    NSTimeInterval tempStartTime = startTime;
                                    
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
                                                    command.duration = endTime - tempStartTime - command.startRelativeTime;
                                                }
                                                command.desc = [tempDic objectForKey:@"input"];
                                                
                                                NSTimeInterval scheduleStartTime = tempStartTime + [[NSNumber numberWithInteger:command.startRelativeTime] doubleValue];
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
                            }
                        }else{
                            NSArray *weeks = [taskTime.week componentsSeparatedByString:@","];
                            NSString *binaryWeek = [self binaryWeekStringFromWeekList:weeks];
                            if (binaryWeek) {
                                NSString *hexWeek = [self binaryStringToHexString:binaryWeek];
                                if (hexWeek) {
                                    NSTimeInterval startTime = taskTime.startTime;
                                    NSTimeInterval endTime = taskTime.endTime;
                                    if (self.isLoop) {
                                        NSTimeInterval tempStartTime = startTime;
                                        
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
                                                        command.duration = endTime - tempStartTime - command.startRelativeTime;
                                                    }
                                                    command.desc = [tempDic objectForKey:@"input"];
                                                    
                                                    NSTimeInterval scheduleStartTime = tempStartTime + [[NSNumber numberWithInteger:command.startRelativeTime] doubleValue];
                                                    command.command = [NSString stringWithFormat:@"F301%@%@%@%04lX%02lX55",command.rfId,hexWeek,[self HHmmssFromTimeInterval:scheduleStartTime],command.duration,index];
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
                                                command.command = [NSString stringWithFormat:@"F301%@%@%@%04lX%02lX55",command.rfId,hexWeek,[self HHmmssFromTimeInterval:scheduleStartTime],command.duration,index];
                                                [self.scriptCommandList addObject:command];
                                                index++;
                                            }
                                        }
                                    }

                                }
                            }
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

-(NSString *)HHmmssFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger time = [[NSNumber numberWithDouble:interval] integerValue];
    NSInteger seconds = time % 60;
    NSInteger tempMinites = (time - seconds) / 60;
    NSInteger minites = tempMinites % 60;
    NSInteger hours = tempMinites / 60;
    NSString *result = [NSString stringWithFormat:@"%02ld%02ld%02ld",hours,minites,seconds];
    return result;
}

-(NSString *)binaryWeekStringFromWeekList:(NSArray *)list
{
    if (list == nil || list.count == 0) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"0"];
    for(NSInteger i = 7; i > 0; i--)
    {
        NSString *tempWeek = [NSString stringWithFormat:@"%ld",i];
        if ([list containsObject:tempWeek]) {
            [result appendString:@"1"];
        }else{
            [result appendString:@"0"];
        }
    }
    return result;
}

-(NSString *)binaryStringToHexString:(NSString *)binaryString
{
    if ((binaryString.length % 4) != 0) {
        return nil;
    }
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    [hexDic setObject:@"0" forKey:@"0000"];
    
    [hexDic setObject:@"1" forKey:@"0001"];
    
    [hexDic setObject:@"2" forKey:@"0010"];
    
    [hexDic setObject:@"3" forKey:@"0011"];
    
    [hexDic setObject:@"4" forKey:@"0100"];
    
    [hexDic setObject:@"5" forKey:@"0101"];
    
    [hexDic setObject:@"6" forKey:@"0110"];
    
    [hexDic setObject:@"7" forKey:@"0111"];
    
    [hexDic setObject:@"8" forKey:@"1000"];
    
    [hexDic setObject:@"9" forKey:@"1001"];
    
    [hexDic setObject:@"A" forKey:@"1010"];
    
    [hexDic setObject:@"B" forKey:@"1011"];
    
    [hexDic setObject:@"C" forKey:@"1100"];
    
    [hexDic setObject:@"D" forKey:@"1101"];
    
    [hexDic setObject:@"E" forKey:@"1110"];
    
    [hexDic setObject:@"F" forKey:@"1111"];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < (binaryString.length / 4); i++) {
        NSString *subString = [binaryString substringWithRange:NSMakeRange(i * 4, 4)];
        NSString *hexString = [hexDic objectForKey:subString];
        if (hexString) {
            [result appendString:hexString];
        }
    }
    
    return result;
}
@end
