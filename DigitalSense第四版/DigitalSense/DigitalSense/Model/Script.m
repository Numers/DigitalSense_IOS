//
//  Script.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "Script.h"
#import "ScriptCommand.h"

@implementation Script
-(id)init
{
    self = [super init];
    if (self) {
        _scriptCommandList = [NSMutableArray array];
    }
    return self;
}

-(void)setState:(ScriptState)state
{
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:ScriptStateComfirmed object:nil];
}

-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        if (dic) {
            _scriptId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            _scriptName = [dic objectForKey:@"scheduleName"];
            _sceneName = [dic objectForKey:@"sceneName"];
            _isLoop = [[dic objectForKey:@"loop"] boolValue];
            _type = (ScriptType)[[dic objectForKey:@"trigger"] integerValue];
            _scriptTime = [[dic objectForKey:@"long"] integerValue];
            
            _scriptCommandList = [NSMutableArray array];
            NSArray *commandArr = [dic objectForKey:@"schedule"];
            if (commandArr) {
                for (NSDictionary *tempDic in commandArr) {
                    ScriptCommand *command = [[ScriptCommand alloc] init];
                    command.startRelativeTime = [[tempDic objectForKey:@"many"] integerValue];
                    command.rfId = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"sn"]];
                    command.duration = [[tempDic objectForKey:@"keep"] integerValue];
                    command.desc = [tempDic objectForKey:@"input"];
                    command.command = [NSString stringWithFormat:@"F501%@%04lX55",command.rfId,command.duration];
                    [_scriptCommandList addObject:command];
                }
            }
        }
    }
    return self;
}
@end
