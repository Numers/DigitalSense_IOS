//
//  ScriptTaskTime.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/20.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptTaskTime : NSObject
@property(nonatomic) NSTimeInterval startDay;
@property(nonatomic) NSTimeInterval endDay;
@property(nonatomic, copy) NSString *week;
@property(nonatomic) NSTimeInterval startTime;
@property(nonatomic) NSTimeInterval endTime;
@end
