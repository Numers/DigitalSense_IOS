//
//  SDBManager.h
//  PocketHealth
//
//  Created by YangFan on 15/1/6.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"

#define kDefaultDBName @"SmellInfo.sqlite"

@class FMDatabase;

@interface SDBManager : NSObject
{
//    NSString * _name;
}
/// 数据库操作对象，当数据库被建立时，会存
@property (nonatomic, readonly) FMDatabase * dataBase;  // 数据库操作对象
+(SDBManager *)defaultDBManager;
@property (nonatomic , strong) NSString * name;
// 关闭数据库
- (void) close;

@end
