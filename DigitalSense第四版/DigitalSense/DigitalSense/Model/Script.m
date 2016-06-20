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
@end
