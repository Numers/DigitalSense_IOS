//
//  SFruitInfoDB.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/2.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SFruitInfoDB.h"
#define kFruitInfoTableName @"SFruitInfo"
@implementation SFruitInfoDB
-(id)init
{
    self = [super init];
    if (self) {
        _db = [[SDBManager defaultDBManager] dataBase];
    }
    return self;
}

/**
 *  @author RenRenFenQi, 16-06-02 17:06:03
 *
 *  创建数据库表
 */
- (void) createDataBase
{
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kFruitInfoTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        NSLog(@"%@数据库已经存在",kFruitInfoTableName);
    } else {
        // TODO: 插入新的数据库
        NSString * sql = [NSString stringWithFormat:@"CREATE TABLE %@ (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, fruitname VARCHAR(50),fruitenname VARCHAR(50),fruitimage VARCHAR(100),rfid VARCHAR(50))",kFruitInfoTableName];
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@数据库创建失败",kFruitInfoTableName);
        } else {
            NSLog(@"%@数据库创建成功",kFruitInfoTableName);
        }
    }
    
}

/**
 *  @author RenRenFenQi, 16-06-02 18:06:24
 *
 *  根据RFID查找一条Fruit记录
 *
 *  @param rfId 气味瓶子的RFID
 *
 *  @return Fruit对象
 */
-(Fruit *)selectFruitWithRFID:(NSString *)rfId
{
    Fruit *fruit = nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE rfid = '%@' limit 1",kFruitInfoTableName,rfId];
    FMResultSet * rs = [_db executeQuery:query];
    if ([rs next]) {
        fruit = [[Fruit alloc] init];
        fruit.fruitName = [rs stringForColumn:@"fruitname"];
        fruit.fruitImage = [rs stringForColumn:@"fruitimage"];
        fruit.fruitEnName = [rs stringForColumn:@"fruitenname"];
        fruit.fruitRFID = [rs stringForColumn:@"rfid"];
    }
    [rs close];
    return fruit;
}

/**
 *  @author RenRenFenQi, 16-06-02 18:06:54
 *
 *  修改Fruit记录
 *
 *  @param fruit 水果味对象
 *
 *  @return 返回修改结果 YES/成功  NO/失败
 */
-(BOOL)mergeFruit:(Fruit *)fruit
{
    NSString * query = [NSString stringWithFormat:@"UPDATE %@ SET",kFruitInfoTableName];
    NSMutableString * temp = [NSMutableString string];
    // xxx = xxx;
    if (fruit.fruitName) {
        [temp appendFormat:@" fruitname = '%@',",fruit.fruitName];
    }
    
    if (fruit.fruitEnName) {
        [temp appendFormat:@" fruitenname = '%@',",fruit.fruitEnName];
    }
    
    if (fruit.fruitImage) {
        [temp appendFormat:@" fruitimage = '%@',",fruit.fruitImage];
    }
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE rfid = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],fruit.fruitRFID];
    
    BOOL flag = [_db executeUpdate:query];
    if(flag){
        NSLog(@"修改%@成功",fruit.fruitName);
    }else{
        NSLog(@"修改%@失败",fruit.fruitName);
    }
    return flag;
}

/**
 *  @author RenRenFenQi, 16-06-02 19:06:07
 *
 *  删除Fruit记录
 *
 *  @param fruit 水果味对象
 *
 *  @return 返回删除结果 YES/成功  NO/失败
 */
-(BOOL)deleteFruit:(Fruit *)fruit
{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE rfid = '%@'",kFruitInfoTableName,fruit.fruitRFID];
    BOOL flag = [_db executeUpdate:query];
    if (flag) {
        NSLog(@"删除 一条数据 成功");
    }else{
        NSLog(@"删除 一条数据  失败");
    }
    return flag;
}

/**
 *  @author RenRenFenQi, 16-06-03 10:06:11
 *
 *  保存Fruit记录
 *
 *  @param fruit 水果味对象
 *
 *  @return 返回保存结果 YES/成功  NO/失败
 */
-(BOOL)saveFruit:(Fruit *)fruit
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@",kFruitInfoTableName];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray array];
    
    //群特有属性
    if (fruit.fruitName) {
        [keys appendString:@"fruitname,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%@",fruit.fruitName]];
    }
    if (fruit.fruitImage) {
        [keys appendString:@"fruitimage,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%@",fruit.fruitImage]];
    }
    
    if (fruit.fruitEnName) {
        [keys appendString:@"fruitenname,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSString stringWithFormat:@"%@",fruit.fruitEnName]];
    }

    
    
    [keys appendString:@"rfid,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%@",fruit.fruitRFID]];
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    
    BOOL flag = [_db executeUpdate:query withArgumentsInArray:arguments];
    if (flag) {
        NSLog(@"%@ 插入一条数据 成功",kFruitInfoTableName);
    }else{
        NSLog(@"%@ 插入一条数据 失败",kFruitInfoTableName);
    }
    return flag;
}
@end
