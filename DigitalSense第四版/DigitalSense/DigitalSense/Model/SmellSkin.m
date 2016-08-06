//
//  SmellSkin.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/7.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SmellSkin.h"
#import "UIDevice+IphoneModel.h"
#define SmellSkinPacketIDKey @"SmellSkinPacketID"
#define SmellSkinNameKey  @"SmellSkinName"
#define BackgroudSkinImageKey @"BackgroundSkinImage"
#define TabBarSkinImageKey @"TabBarSkinImage"
#define VoiceButtonSkinImageKey @"VoiceButtonSkinImage"
@implementation SmellSkin
+(SmellSkin *)getLocalSkin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    SmellSkin *skin = [[SmellSkin alloc] init];
    skin.skinId = [userDefaults objectForKey:SmellSkinPacketIDKey];
    if (skin.skinId == nil) {
        skin.skinId = @"1";
    }
    skin.name = [userDefaults objectForKey:SmellSkinNameKey];
    skin.backgroundImage = [userDefaults objectForKey:BackgroudSkinImageKey];
    skin.tabBarImage = [userDefaults objectForKey:TabBarSkinImageKey];
    skin.voiceButtonImage = [userDefaults objectForKey:VoiceButtonSkinImageKey];
    return skin;
}

-(void)saveSkinToLocal
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.skinId) {
        [userDefaults setObject:self.skinId forKey:SmellSkinPacketIDKey];
    }
    
    if (self.backgroundImage) {
        [userDefaults setObject:self.backgroundImage forKey:BackgroudSkinImageKey];
    }
    
    if (self.name) {
        [userDefaults setObject:self.name forKey:SmellSkinNameKey];
    }
    
    if (self.tabBarImage) {
        [userDefaults setObject:self.tabBarImage forKey:TabBarSkinImageKey];
    }
    
    if (self.voiceButtonImage) {
        [userDefaults setObject:self.voiceButtonImage forKey:VoiceButtonSkinImageKey];
    }
    [userDefaults synchronize];
}

-(NSString *)matchImageURLWithDic:(NSDictionary *)dic WithBaseURL:(NSString *)baseURL;
{
    NSString *result = nil;
    if (dic) {
        switch ([UIDevice iPhonesModel]) {
            case iPhone4: {
                result = [dic objectForKey:@"2x"];
                if (result == nil) {
                    result = [dic objectForKey:@"3x"];
                }
                break;
            }
            case iPhone5: {
                result = [dic objectForKey:@"2x"];
                if (result == nil) {
                    result = [dic objectForKey:@"3x"];
                }
                break;
            }
            case iPhone6: {
                result = [dic objectForKey:@"2x"];
                if (result == nil) {
                    result = [dic objectForKey:@"3x"];
                }
                break;
            }
            case iPhone6Plus: {
                result = [dic objectForKey:@"3x"];
                if (result == nil) {
                    result = [dic objectForKey:@"2x"];
                }
                break;
            }
            case UnKnown: {
                result = [dic objectForKey:@"3x"];
                if (result == nil) {
                    result = [dic objectForKey:@"2x"];
                }
                break;
            }
        }
    }
    
    if (!([AppUtils isNullStr:baseURL] || [AppUtils isNullStr:result])) {
        result = [NSString stringWithFormat:@"%@%@",baseURL,result];
    }else{
        result = nil;
    }
    return result;
}
@end
