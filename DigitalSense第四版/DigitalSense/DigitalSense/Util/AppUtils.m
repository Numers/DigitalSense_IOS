//
//  AppUtils.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "AppUtils.h"
#import "MBProgressHUD.h"
#define MBTAG  1001
@implementation AppUtils
+(void)showInfo:(NSString *)text
{
    UIWindow *appRootView = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = (MBProgressHUD *)[appRootView viewWithTag:MBTAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:appRootView];
        HUD.tag = MBTAG;
        [appRootView addSubview:HUD];
        [HUD show:YES];
    }
    
    HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
    
    if ([self isNullStr:text]) {
        //        HUD.animationType = MBProgressHUDAnimationZoom;
        [HUD hide:YES];
    }else{
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = text;
        HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [HUD hide:YES afterDelay:1];
    }
}

+ (BOOL)isNullStr:(NSString *)str
{
    if (str == nil || [str isEqual:[NSNull null]] || str.length == 0) {
        return  YES;
    }
    
    return NO;
}
@end
