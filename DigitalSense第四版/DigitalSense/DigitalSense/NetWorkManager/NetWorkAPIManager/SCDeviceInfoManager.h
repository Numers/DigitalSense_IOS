//
//  SCDeviceInfoManager.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/3.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNetWorkManager.h"
@interface SCDeviceInfoManager : NSObject
+(id)defaultManager;

/**
 *  @author RenRenFenQi, 16-06-03 15:06:35
 *
 *  根据RFID获取气味对象
 *
 *  @param rfId    气味对应的瓶子RFID
 *  @param success 成功返回
 *  @param error   错误返回
 *  @param failed  失败返回
 */
-(void)requestFruitInfoWithRFID:(NSInteger)rfId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed;
@end
