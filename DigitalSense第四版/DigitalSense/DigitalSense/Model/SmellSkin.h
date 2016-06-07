//
//  SmellSkin.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/7.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmellSkin : NSObject
@property(nonatomic, copy) NSString *backgroundImage;
@property(nonatomic, copy) NSString *tabBarImage;
@property(nonatomic, copy) NSString *voiceButtonImage;

+(SmellSkin *)getLocalSkin;
-(void)saveSkinToLocal;
@end
