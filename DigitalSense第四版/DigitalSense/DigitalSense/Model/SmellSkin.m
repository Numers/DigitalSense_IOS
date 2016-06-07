//
//  SmellSkin.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/7.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SmellSkin.h"
#define BackgroudSkinImageKey @"BackgroundSkinImage"
#define TabBarSkinImageKey @"TabBarSkinImage"
#define VoiceButtonSkinImageKey @"VoiceButtonSkinImage"
@implementation SmellSkin
+(SmellSkin *)getLocalSkin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    SmellSkin *skin = [[SmellSkin alloc] init];
    skin.backgroundImage = [userDefaults objectForKey:BackgroudSkinImageKey];
    skin.tabBarImage = [userDefaults objectForKey:TabBarSkinImageKey];
    skin.voiceButtonImage = [userDefaults objectForKey:VoiceButtonSkinImageKey];
    return skin;
}

-(void)saveSkinToLocal
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.backgroundImage) {
        [userDefaults setObject:self.backgroundImage forKey:BackgroudSkinImageKey];
    }
    
    if (self.tabBarImage) {
        [userDefaults setObject:self.tabBarImage forKey:TabBarSkinImageKey];
    }
    
    if (self.voiceButtonImage) {
        [userDefaults setObject:self.voiceButtonImage forKey:VoiceButtonSkinImageKey];
    }
    [userDefaults synchronize];
}
@end
