//
//  AppUtils.h
//  DigitalSense
//
//  Created by baolicheng on 16/5/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define API_BASE  [AppUtils returnBaseUrl]
@interface AppUtils : NSObject
+ (NSString*) appVersion;
+(void)setUrlWithState:(BOOL)state;
+(NSString *)returnBaseUrl;
+(NSString *)generateSignatureString:(NSDictionary *)parameters Method:(NSString *)method URI:(NSString *)uri Key:(NSString *)subKey;
+(NSString*) sha1:(NSString *)text;

+(void)showInfo:(NSString *)text;
+ (BOOL)isNullStr:(NSString *)str;

/**
 *  显示在指定VIEW中心
 */
+ (void)showProgressBarForView:(UIView *)view;
+ (void)hideProgressBarForView:(UIView *)view;
@end
