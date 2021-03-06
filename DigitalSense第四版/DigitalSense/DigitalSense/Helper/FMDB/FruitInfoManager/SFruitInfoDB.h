//
//  SFruitInfoDB.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/2.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDBManager.h"
#import "Fruit.h"
@interface SFruitInfoDB : NSObject
{
    FMDatabase *_db;
}

+(instancetype)shareInstance;

/**
 *  @author RenRenFenQi, 16-06-02 17:06:03
 *
 *  创建数据库表
 */
- (void) createDataBase;

/**
 *  @author RenRenFenQi, 16-06-02 18:06:24
 *
 *  根据RFID查找一条Fruit记录
 *
 *  @param rfId 气味瓶子的RFID
 *
 *  @return Fruit对象
 */
-(Fruit *)selectFruitWithRFID:(NSString *)rfId;

/**
 *  @author RenRenFenQi, 16-06-02 18:06:54
 *
 *  修改Fruit记录
 *
 *  @param fruit 水果味对象
 *
 *  @return 返回修改结果 YES/成功  NO/失败
 */
-(BOOL)mergeFruit:(Fruit *)fruit;

/**
 *  @author RenRenFenQi, 16-06-02 19:06:07
 *
 *  删除Fruit记录
 *
 *  @param rfid 水果味对象编号
 *
 *  @return 返回删除结果 YES/成功  NO/失败
 */
-(BOOL)deleteFruit:(NSString *)rfid;

/**
 *  @author RenRenFenQi, 16-06-03 10:06:11
 *
 *  保存Fruit记录
 *
 *  @param fruit 水果味对象
 *
 *  @return 返回保存结果 YES/成功  NO/失败
 */
-(BOOL)saveFruit:(Fruit *)fruit;

/**
 *  @author RenRenFenQi, 16-08-04 10:08:32
 *
 *  是否存在水果
 *
 *  @param rfId 水果编号
 *
 *  @return YES/存在  NO/不存在
 */
-(BOOL)isExistFruitWithRFID:(NSString *)rfId;
@end
