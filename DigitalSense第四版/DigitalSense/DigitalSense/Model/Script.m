//
//  Script.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "Script.h"

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
        }
    }
    return self;
}

-(NSString *)commandString
{
    return nil;
}

-(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger tempMinite = (seconds - second) / 60;
    NSInteger minite = tempMinite % 60;
    NSInteger hour = tempMinite / 60;
    NSString *result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minite,second];
    return result;
}
@end
