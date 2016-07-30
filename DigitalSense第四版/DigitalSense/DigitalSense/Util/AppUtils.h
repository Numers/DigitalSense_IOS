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
+ (BOOL)isNetworkURL:(NSString *)url;

/**
 *  @author RenRenFenQi, 16-07-30 14:07:14
 *
 *  对float型数字四舍五入
 *
 *  @param value float型数字
 *
 *  @return 四舍五入后的整型
 */
+(NSInteger)floatToInt:(CGFloat)value;

/**
 *  @author RenRenFenQi, 16-07-30 15:07:34
 *
 *  根据业务需求，将float型数字转为整型
 *
 *  @param value    float型数字 介于0~maxValue之间
 *  @param maxValue 最大值
 *
 *  @return 整型数字
 */
+(NSInteger)floatToInt:(CGFloat)value WithMaxValue:(NSInteger)maxValue;

/**
 *  显示在指定VIEW中心
 */
+ (void)showProgressBarForView:(UIView *)view;
+ (void)hideProgressBarForView:(UIView *)view;
@end
