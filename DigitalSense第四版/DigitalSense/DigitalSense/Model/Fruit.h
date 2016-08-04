//
//  Fruit.h
//  DigitalSense
//
//  Created by baolicheng on 16/5/30.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fruit : NSObject
@property(nonatomic, copy) NSString *fruitName;
@property(nonatomic, copy) NSString *fruitKeyWords;
@property(nonatomic, copy) NSString *fruitEnName;
@property(nonatomic, copy) NSString *fruitImage;
@property(nonatomic, copy) NSString *fruitRFID;
@property(nonatomic, copy) NSString *fruitSn;
@property(nonatomic, copy) NSString *fruitColor;

@property(nonatomic) NSInteger tag; //专用于排序

-(void)setFruitImageWithDic:(NSDictionary *)dic;
@end
