//
//  Fruit.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/30.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "Fruit.h"

@implementation Fruit
-(void)setFruitImageWithDic:(NSDictionary *)dic
{
    if (dic == nil) {
        return;
    }
    iPhoneModel model = [UIDevice iPhonesModel];
    switch (model) {
        case iPhone4: {
            {
                NSString *imageUrl_2X = [dic objectForKey:@"2x"];
                if (![AppUtils isNullStr:imageUrl_2X]) {
                    self.fruitImage = imageUrl_2X;
                }else{
                    NSString *imageUrl_3X = [dic objectForKey:@"3x"];
                    if (![AppUtils isNullStr:imageUrl_3X]) {
                        self.fruitImage = imageUrl_3X;
                    }
                }
            }
            break;
        }
        case iPhone5: {
            {
                NSString *imageUrl_2X = [dic objectForKey:@"2x"];
                if (![AppUtils isNullStr:imageUrl_2X]) {
                    self.fruitImage = imageUrl_2X;
                }else{
                    NSString *imageUrl_3X = [dic objectForKey:@"3x"];
                    if (![AppUtils isNullStr:imageUrl_3X]) {
                        self.fruitImage = imageUrl_3X;
                    }
                }
            }
            break;
        }
        case iPhone6: {
            {
                NSString *imageUrl_2X = [dic objectForKey:@"2x"];
                if (![AppUtils isNullStr:imageUrl_2X]) {
                    self.fruitImage = imageUrl_2X;
                }else{
                    NSString *imageUrl_3X = [dic objectForKey:@"3x"];
                    if (![AppUtils isNullStr:imageUrl_3X]) {
                        self.fruitImage = imageUrl_3X;
                    }
                }
            }
            break;
        }
        case iPhone6Plus: {
            {
                NSString *imageUrl_3X = [dic objectForKey:@"3x"];
                if (![AppUtils isNullStr:imageUrl_3X]) {
                    self.fruitImage = imageUrl_3X;
                }else{
                    NSString *imageUrl_2X = [dic objectForKey:@"2x"];
                    if (![AppUtils isNullStr:imageUrl_2X]) {
                        self.fruitImage = imageUrl_2X;
                    }
                }
            }
            break;
        }
        case UnKnown: {
            {
                NSString *imageUrl_2X = [dic objectForKey:@"2x"];
                if (![AppUtils isNullStr:imageUrl_2X]) {
                    self.fruitImage = imageUrl_2X;
                }else{
                    NSString *imageUrl_3X = [dic objectForKey:@"3x"];
                    if (![AppUtils isNullStr:imageUrl_3X]) {
                        self.fruitImage = imageUrl_3X;
                    }
                }
            }
            break;
        }
    }
}
@end
