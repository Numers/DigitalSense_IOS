//
//  AppUtils.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "AppUtils.h"
#import "MBProgressHUD.h"
#import "LZProgressView.h"
#import "URLManager.h"
#import <CommonCrypto/CommonDigest.h>
#define MBTAG  1001
#define AMTAG  1111
@implementation AppUtils
+(void)setUrlWithState:(BOOL)state
{
    [[URLManager defaultManager] setUrlWithState:state];
}

+(NSString *)returnBaseUrl
{
    return [[URLManager defaultManager] returnBaseUrl];
}

+ (NSString*) appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(NSString *)generateSignatureString:(NSDictionary *)parameters Method:(NSString *)method URI:(NSString *)uri Key:(NSString *)subKey
{
    NSMutableString *signatureString = nil;
    if (parameters) {
        NSArray *allKeys = [parameters allKeys];
        NSArray *sortKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        signatureString = [[NSMutableString alloc] initWithFormat:@"%@:%@:",method,uri];
        for (NSString *key in sortKeys) {
            NSString *paraString = nil;
            if ([key isEqualToString:[sortKeys lastObject]]) {
                paraString = [NSString stringWithFormat:@"%@=%@:",key,[parameters objectForKey:key]];
            }else{
                paraString = [NSString stringWithFormat:@"%@=%@&",key,[parameters objectForKey:key]];
            }
            [signatureString appendString:paraString];
        }
        
        [signatureString appendString:subKey];
    }
    return signatureString;
}

+(NSString*) sha1:(NSString *)text
{
    const char *cstr = [text cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:text.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+(void)showInfo:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

+ (BOOL)isNullStr:(NSString *)str
{
    if (str == nil || [str isEqual:[NSNull null]] || str.length == 0) {
        return  YES;
    }
    
    return NO;
}

+ (BOOL)isNetworkURL:(NSString *)url
{
    BOOL result = NO;
    if (url) {
        if ([url hasPrefix:@"http://"]) {
            result = YES;
        }
    }
    return result;
}

+ (void)showProgressBarForView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LZProgressView *HUD = (LZProgressView *)[view viewWithTag:AMTAG];
        if (HUD == nil) {
            CGRect frame = CGRectMake(0, 0, 26, 26);
            HUD = [[LZProgressView alloc] initWithFrame:frame andLineWidth:3.0f andLineColor:@[[UIColor orangeColor],[UIColor grayColor]]];
            HUD.tag = AMTAG;
            HUD.center = CGPointMake(view.center.x, view.center.y);
            [view addSubview:HUD];
        }
        [HUD startAnimation];
    });
}

+ (void)hideProgressBarForView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LZProgressView *HUD = (LZProgressView *)[view viewWithTag:AMTAG];
        if (HUD != nil) {
            [HUD stopAnimation];
        }
    });
}
@end
