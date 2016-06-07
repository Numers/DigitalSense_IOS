//
//  SCDeviceInfoManager.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/3.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SCDeviceInfoManager.h"
static SCDeviceInfoManager *scDeviceInfoManager;
@implementation SCDeviceInfoManager
+(id)defaultManager
{
    if (scDeviceInfoManager == nil) {
        scDeviceInfoManager = [[SCDeviceInfoManager alloc] init];
    }
    return scDeviceInfoManager;
}

/**
 *  @author RenRenFenQi, 16-06-06 16:06:03
 *
 *  获取瓶子气味信息
 *
 *  @param hid             设备MacAddress
 *  @param rfIdSequece     瓶子RFID序列
 *  @param useTimeSequence 瓶子RFID序列对应的使用时长
 *  @param isNew           0/不更新 1/更新
 *  @param success         返回成功
 *  @param error           返回错误
 *  @param failed          返回失败
 */
-(void)requestFruitInfo:(NSString *)hid WithRFIDSequence:(NSString *)rfIdSequece WithUseTimeSequence:(NSString *)useTimeSequence IsNew:(NSString *)isNew Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:hid,@"hid",rfIdSequece,@"rfid",useTimeSequence,@"used",isNew,@"new",nil];
    [[SCNetWorkManager defaultManager] put:SC_FruitInfo_API parameters:parameters success:success error:error failed:failed isNotify:NO];
}

/**
 *  @author RenRenFenQi, 16-06-06 16:06:02
 *
 *  获取皮肤列表
 *
 *  @param page    页码 默认传1
 *  @param pageNum 每页显示数量
 *  @param success 返回成功
 *  @param error   返回错误
 *  @param failed  返回失败
 */
-(void)requestSmellSkinList:(NSInteger)page WithPageNumber:(NSInteger)pageNum Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:page],@"p",[NSNumber numberWithInteger:pageNum],@"n",nil];
    [[SCNetWorkManager defaultManager] get:SC_SmellSkin_API parameters:parameters success:success error:error failed:failed isNotify:YES];
}

/**
 *  @author RenRenFenQi, 16-06-06 16:06:00
 *
 *  获取皮肤包
 *
 *  @param packetId 皮肤包ID
 *  @param success  返回成功
 *  @param error    返回错误
 *  @param failed   返回失败
 */
-(void)requestSmellSkinPacket:(NSInteger)packetId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *uri = [SC_SmellSkinPacket_API stringByReplacingOccurrencesOfString:@":id" withString:[NSString stringWithFormat:@"%ld",packetId]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"ios",@"type",nil];
    [[SCNetWorkManager defaultManager] get:uri parameters:parameters success:success error:error failed:failed isNotify:YES];
}

/**
 *  @author RenRenFenQi, 16-06-06 17:06:08
 *
 *  上传设备开关机时间
 *
 *  @param hid       设备macAddress
 *  @param openTime  开机时间
 *  @param closeTime 关机时间
 *  @param success   返回成功
 *  @param error     返回错误
 *  @param failed    返回失败
 */
-(void)uploadDevice:(NSString *)hid OpenTime:(NSTimeInterval)openTime CloseTime:(NSTimeInterval)closeTime Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:hid,@"hid",[NSNumber numberWithDouble:openTime],@"on",[NSNumber numberWithDouble:closeTime],@"off",nil];
    [[SCNetWorkManager defaultManager] put:SC_UploadOpenAndCloseDeviceTime_API parameters:parameters success:success error:error failed:failed isNotify:NO];
}
@end
