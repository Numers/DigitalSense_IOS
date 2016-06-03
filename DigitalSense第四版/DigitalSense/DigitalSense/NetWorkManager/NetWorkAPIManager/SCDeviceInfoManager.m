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

-(void)requestFruitInfoWithRFID:(NSInteger)rfId Success:(ApiSuccessCallback)success Error:(ApiErrorCallback)error Failed:(ApiFailedCallback)failed
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:rfId],@"rfId",nil];
    [[SCNetWorkManager defaultManager] get:SC_FruitInfo_API parameters:parameters success:success error:error failed:failed isNotify:NO];
}
@end
