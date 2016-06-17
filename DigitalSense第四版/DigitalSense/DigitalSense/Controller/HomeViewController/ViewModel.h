//
//  ViewModel.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/1.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BottleKey @"Bottle"
#define BottleUseTimeKey @"BottleUseTime"
#define EmitSmellNoKey @"EmitSmellNo"
#define EmitSmellDurationKey @"EmitSmellDuration"

@class Fruit;
@interface ViewModel : NSObject
@property(nonatomic, copy) NSString *macAddress;
@property(nonatomic, copy) NSString *openDeviceTime;
@property(nonatomic, copy) NSString *closeDeviceTime;
/**
 *  @author RenRenFenQi, 16-06-01 11:06:44
 *
 *  获取设备mac地址
 *
 *  @param byte 蓝牙回送:FF+MAC地址(4个字节)+55
 */
-(RACSignal *)getMacAddressReturn:(Byte*)byte;

/**
 *  @author RenRenFenQi, 16-06-01 11:06:28
 *
 *  获取开机时间
 *
 *  @param byte 蓝牙回送:FE2016053010312255
 */
-(RACSignal *)getOpenDeviceTimeReturn:(Byte *)byte;

/**
 *  @author RenRenFenQi, 16-06-01 11:06:57
 *
 *  获取关机时间
 *
 *  @param byte 蓝牙回送:FD2016053010312255
 */
-(RACSignal *)getCloseDeviceTimeReturn:(Byte *)byte;

/**
 *  @author RenRenFenQi, 16-06-01 15:06:57
 *
 *  唤醒设备蓝牙返回
 *
 *  @param byte 蓝牙回送:FC6355
 *
 *  @return 唤醒信号
 */
-(RACSignal *)wakeUpDeviceReturn:(Byte *)byte;

/**
 *  @author RenRenFenQi, 16-06-01 15:06:07
 *
 *  休眠设备蓝牙返回
 *
 *  @param byte 蓝牙回送:FB6455
 *
 *  @return 休眠信号
 */
-(RACSignal *)sleepDeviceReturn:(Byte *)byte;

/**
 *  @author RenRenFenQi, 16-06-01 15:06:37
 *
 *  获取每个瓶子信息(包括卡号和每个瓶子使用时间)
 *
 *  @param byte 蓝牙回送:FA+卡号(4个字节)+总时间(秒为单位,共两个字节)+55
 *
 *  @return 获取每个瓶子时间信号
 */
-(RACSignal *)getBottleInfoReturn:(Byte *)byte;

/**
 *  @author RenRenFenQi, 16-06-03 17:06:47
 *
 *  瓶子信息发送完成后，获取瓶子内气味信息
 *
 *  @param byte 蓝牙回送:FB6455
 *  @param list 瓶子信息列表
 *
 *  @return 获取瓶内气味信息信号
 */
-(RACSignal *)getBottleInfoCompletelyReturn:(Byte *)byte WithBottleInfoList:(NSArray *)list;

/**
 *  @author RenRenFenQi, 16-06-01 15:06:17
 *
 *  开启某一种味道
 *
 *  @param byte 蓝牙回送:F9+位置N(N=1,2....)+时间(1个字节)+55
 *
 *  @return 开启味道信号
 */
-(RACSignal *)emitSmellReturn:(Byte *)byte;

/**
 *  @author RenRenFenQi, 16-06-07 16:06:29
 *
 *  获取皮肤包
 *
 *  @param packetId 皮肤包ID
 *
 *  @return 皮肤包信号
 */
-(RACSignal *)getSkinPacket:(NSString *)packetId;

/**
 *  @author RenRenFenQi, 16-06-02 14:06:34
 *
 *  根据名字匹配对象
 *
 *  @param fruitName 语音识别名称
 *  @param list      对象列表
 *
 *  @return 返回匹配对象
 */
-(Fruit *)matchFruitName:(NSString *)fruitName InList:(NSArray *)list;
@end
