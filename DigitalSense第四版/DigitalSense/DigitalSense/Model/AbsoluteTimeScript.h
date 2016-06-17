//
//  AbsoluteTimeScript.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "Script.h"

@interface AbsoluteTimeScript : Script
@property(nonatomic, copy) NSString *startDay;
@property(nonatomic, copy) NSString *endDay;
@property(nonatomic, copy) NSString *week;
@property(nonatomic, copy) NSString *startTime;
@property(nonatomic, copy) NSString *endTime;

-(id)initWithDictionary:(NSDictionary *)dic;
@end
