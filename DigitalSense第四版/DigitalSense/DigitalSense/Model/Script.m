//
//  Script.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "Script.h"

@implementation Script
-(void)setState:(ScriptState)state
{
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:ScriptStateComfirmed object:nil];
}
@end
