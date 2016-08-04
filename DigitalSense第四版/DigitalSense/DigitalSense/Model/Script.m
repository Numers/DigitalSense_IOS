//
//  Script.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "Script.h"
#import "Fruit.h"

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

-(id)initWithDictionary:(NSDictionary *)dic WithModeList:(NSArray *)modeList
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

-(Fruit *)searchRFIDWithFruitSn:(NSString *)fruitSn WithModeList:(NSArray *)modeList
{
    Fruit *fruit = nil;
    if (fruitSn) {
        if (modeList) {
            for (Fruit *f in modeList) {
                if ([fruitSn isEqualToString:f.fruitSn]) {
                    fruit = f;
                    break;
                }
            }
        }
    }
    return fruit;
}

-(NSString *)commandString
{
    return nil;
}

-(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger minite = (seconds - second) / 60;
    NSString *result;
    if (minite < 10) {
        result = [NSString stringWithFormat:@"%02ld:%02ld",(long)minite,(long)second];
    }else{
        result = [NSString stringWithFormat:@"%ld:%02ld",(long)minite,(long)second];
    }
    return result;
}
@end
