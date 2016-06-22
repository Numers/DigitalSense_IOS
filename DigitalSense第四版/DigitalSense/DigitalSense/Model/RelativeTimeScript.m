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
                command.rfId = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"sn"]];
                command.duration = [[tempDic objectForKey:@"keep"] integerValue];
                command.desc = [tempDic objectForKey:@"input"];
                command.command = [NSString stringWithFormat:@"F501%@%04lX55",command.rfId,command.duration];
                [self.scriptCommandList addObject:command];
            }
        }
    }
    return self;
}
@end
