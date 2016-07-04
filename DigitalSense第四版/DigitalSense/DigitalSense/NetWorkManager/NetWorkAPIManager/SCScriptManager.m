//
//  SCScriptManager.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SCScriptManager.h"
static SCScriptManager *scScriptManager;
@implementation SCScriptManager
+(id)defaultManager
{
    if (scScriptManager == nil) {
        scScriptManager = [[SCScriptManager alloc] init];
    }
    return scScriptManager;
}

/**
 *  @author RenRenFenQi, 16-06-17 18:06:33
 *
 *  获取符合设备的脚本
 *
 *  @param macAddress 设备mac地址
 *  @param success    成功回调
 *  @param error      错误回调
 *  @param failed     失败回调
 */
-(void)requestScriptInfoWithMacAddress:(NSString *)macAddress Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSString *uri = [SC_Script_API stringByReplacingOccurrencesOfString:@":sn" withString:[NSString stringWithFormat:@"%@",macAddress]];
    [[SCNetWorkManager defaultManager] get:uri parameters:nil success:success error:error failed:failed isNotify:YES];
}
@end
