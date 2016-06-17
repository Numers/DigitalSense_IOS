//
//  ScriptCommand.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptCommand : NSObject
@property(nonatomic) NSInteger startRelativeTime;
@property(nonatomic, copy) NSString *rfId;
@property(nonatomic) NSInteger duration;
@property(nonatomic, copy) NSString *command;
@property(nonatomic, copy) NSString *desc;
@end
