//
//  AbsoluteTimeScript.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "AbsoluteTimeScript.h"

@implementation AbsoluteTimeScript
-(id)initWithDictionary:(NSDictionary *)dic
{
    self = [super initWithDictionary:dic];
    if (self) {
        if (dic) {
            _startDay = [dic objectForKey:@"start_year"];
            _endDay = [dic objectForKey:@"end_year"];
            _week = [dic objectForKey:@"week"];
            _startTime = [dic objectForKey:@"start_time"];
            _endTime = [dic objectForKey:@"end_time"];
        }
    }
    return self;
}
@end
