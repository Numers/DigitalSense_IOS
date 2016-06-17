//
//  ScriptViewModel.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptViewModel : NSObject
/**
 *  @author RenRenFenQi, 16-06-17 18:06:35
 *
 *  根据macAddress
 *
 *  @param macAddress mac地址
 *
 *  @return 获取脚本信号
 */
-(RACSignal *)requestScriptInfoWithMacAddress:(NSString *)macAddress;
@end
