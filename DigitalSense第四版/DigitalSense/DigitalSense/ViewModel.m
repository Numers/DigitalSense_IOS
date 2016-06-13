//
//  ViewModel.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/1.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ViewModel.h"
#import "Fruit.h"
#import "SFruitInfoDB.h"

#import "SCDeviceInfoManager.h"

@implementation ViewModel
-(instancetype)init
{
    self =  [super init];
    if (self) {
        RACSignal *uploadSignal = [RACSignal combineLatest:@[RACObserve(self,macAddress),RACObserve(self,openDeviceTime),RACObserve(self, closeDeviceTime)] reduce:^id{
            return @(self.macAddress != nil && self.openDeviceTime != nil && self.closeDeviceTime != nil);
        }];
        
        [uploadSignal subscribeNext:^(id x) {
            if ([x boolValue]) {
                //上传设备的开关机时间
                NSLog(@"macAddress:%@  OpenDeviceTime:%@  CloseDeviceTime:%@",self.macAddress,self.openDeviceTime,self.closeDeviceTime);
                [[SCDeviceInfoManager defaultManager] uploadDevice:self.macAddress OpenTime:[self timeIntervalFromTimeString:self.openDeviceTime] CloseTime:[self timeIntervalFromTimeString:self.closeDeviceTime] Success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"上传设备开关机时间成功");
                } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"上传设备开关机时间失败");
                } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"上传设备开关机时间网络失败");
                }];
            }
        }];
    }
    return self;
}

/**
 *  @author RenRenFenQi, 16-06-06 17:06:36
 *
 *  根据特定格式的时间字符串转为时间戳
 *
 *  @param timeStr 时间字符串 yy-MM-dd-HH-mm-ss
 *
 *  @return 时间戳
 */
-(NSTimeInterval)timeIntervalFromTimeString:(NSString *)timeStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd-HH-mm-ss"];
    NSDate *tempDate = [formatter dateFromString:timeStr];
    NSTimeInterval interval = [tempDate timeIntervalSince1970];
    return interval;
}
/**
 *  @author RenRenFenQi, 16-06-01 11:06:44
 *
 *  获取设备mac地址
 *
 *  @param byte 蓝牙回送:FF+MAC地址(4个字节)+55
 */
-(RACSignal *)getMacAddressReturn:(Byte*)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableString *result = [[NSMutableString alloc] init];
        for (int i = 1; i <= 6; i ++) {
            int value = byte[i];
            [result appendFormat:@"%02X",value];
        }
        self.macAddress = [NSString stringWithString:result];
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取设备mac地址信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-01 11:06:28
 *
 *  获取开机时间
 *
 *  @param byte 蓝牙回送:FE2016053010312255
 */
-(RACSignal *)getOpenDeviceTimeReturn:(Byte *)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableString *result = [[NSMutableString alloc] init];
        for (int i = 1; i <= 6; i ++) {
            int value = byte[i];
            [result appendFormat:@"%02d",value];
            if (i != 6) {
                [result appendString:@"-"];
            }
        }
        self.openDeviceTime = [NSString stringWithString:result];
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取开机时间信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-01 11:06:57
 *
 *  获取关机时间
 *
 *  @param byte 蓝牙回送:FD2016053010312255
 */
-(RACSignal *)getCloseDeviceTimeReturn:(Byte *)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableString *result = [[NSMutableString alloc] init];
        for (int i = 1; i <= 6; i ++) {
            int value = byte[i];
            [result appendFormat:@"%02d",value];
            if (i != 6) {
                [result appendString:@"-"];
            }
        }
        self.closeDeviceTime = [NSString stringWithString:result];
        [subscriber sendNext:result];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取关机时间信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-01 15:06:57
 *
 *  唤醒设备蓝牙返回
 *
 *  @param byte 蓝牙回送:FC6355
 *
 *  @return 唤醒信号
 */
-(RACSignal *)wakeUpDeviceReturn:(Byte *)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        int value = byte[1];
        if (value == 0x63) {
            [subscriber sendNext:@(YES)];
        }else{
            [subscriber sendNext:@(NO)];
        }
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"唤醒设备返回信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-01 15:06:07
 *
 *  休眠设备蓝牙返回
 *
 *  @param byte 蓝牙回送:FB6455
 *
 *  @return 休眠信号
 */
-(RACSignal *)sleepDeviceReturn:(Byte *)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        int value = byte[1];
        if (value == 0x64) {
            [subscriber sendNext:@(YES)];
        }else{
            [subscriber sendNext:@(NO)];
        }
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"休眠设备返回信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-01 15:06:37
 *
 *  获取每个瓶子信息(包括卡号和每个瓶子使用时间)
 *
 *  @param byte 蓝牙回送:FA+卡号(4个字节)+总时间(秒为单位,共两个字节)+55
 *
 *  @return 获取每个瓶子时间信号
 */
-(RACSignal *)getBottleInfoReturn:(Byte *)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *cardNo = [NSString stringWithFormat:@"%02X%02X%02X%02X",byte[1],byte[2],byte[3],byte[4]];
        
        NSString *temp2 = [NSString stringWithFormat:@"0x%02X%02X",byte[5],byte[6]];
        NSScanner *scanner2 = [NSScanner scannerWithString:temp2];
        unsigned long long useTime;
        [scanner2 scanHexLongLong:&useTime];
        
        NSDictionary *dic = @{BottleKey:cardNo,BottleUseTimeKey:@(useTime)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
//        SFruitInfoDB *fruitInfodb = [[SFruitInfoDB alloc] init];
//        Fruit *fruit = nil;
//        fruit = [fruitInfodb selectFruitWithRFID:cardNo];
//        if (fruit) {
//            NSDictionary *dic = @{BottleKey:fruit,BottleUseTimeKey:@(useTime)};
//            [subscriber sendNext:dic];
//            [subscriber sendCompleted];
//        }else{
//            [[SCDeviceInfoManager defaultManager] requestFruitInfoWithRFID:cardNo Success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                Fruit *fruit = [[Fruit alloc] init];
//                fruit.fruitRFID = [[NSNumber numberWithLongLong:cardNo] integerValue];
//                [fruitInfodb saveFruit:fruit];
//                
//                NSDictionary *dic = @{BottleKey:fruit,BottleUseTimeKey:@(useTime)};
//                [subscriber sendNext:dic];
//                [subscriber sendCompleted];
//            } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//            } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
//                
//            }];
//        }
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取每个瓶子时间信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-03 17:06:47
 *
 *  瓶子信息发送完成后，获取瓶子内气味信息
 *
 *  @param byte 蓝牙回送:FB6455
 *  @param list 瓶子信息列表
 *
 *  @return 获取瓶内气味信息信号
 */
-(RACSignal *)getBottleInfoCompletelyReturn:(Byte *)byte WithBottleInfoList:(NSArray *)list
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        int value = byte[1];
        if (value == list.count)
        {
            if(self.macAddress == nil)
            {
                [subscriber sendCompleted];
            }else{
                NSDictionary *bottleInfoDic = [self dowithBottleInfoList:list];
                [[SCDeviceInfoManager defaultManager] requestFruitInfo:self.macAddress WithRFIDSequence:[bottleInfoDic objectForKey:@"RFID"] WithUseTimeSequence:[bottleInfoDic objectForKey:@"useTime"] IsNew:@"1" Success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [subscriber sendNext:responseObject];
                    [subscriber sendCompleted];
                } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [subscriber sendCompleted];
                } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [subscriber sendCompleted];
                }];
            }
        }else{
            [subscriber sendCompleted];
        }
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取瓶内气味信息信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-03 17:06:00
 *
 *  处理瓶子信息成json字符串
 *
 *  @param list 瓶子信息列表
 *
 *  @return 瓶子RFID和useTime序列
 */
-(NSDictionary *)dowithBottleInfoList:(NSArray *)list
{
    if (list == nil) {
        return nil;
    }
    NSMutableString *rfIdSequence = [[NSMutableString alloc] init];
    NSMutableString *useTimeSequence = [[NSMutableString alloc] init];
    for (NSDictionary *dic in list) {
        [rfIdSequence appendFormat:@"%@",[dic objectForKey:BottleKey]];
        [useTimeSequence appendFormat:@"%@",[dic objectForKey:BottleUseTimeKey]];
        
        if (![dic isEqual:[list lastObject]]) {
            [rfIdSequence appendString:@":"];
            [useTimeSequence appendString:@":"];
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:rfIdSequence,@"RFID",useTimeSequence,@"useTime", nil];
}

/**
 *  @author RenRenFenQi, 16-06-01 15:06:17
 *
 *  开启某一种味道
 *
 *  @param byte 蓝牙回送:F9+位置N(N=1,2....)+时间(1个字节)+55
 *
 *  @return 开启味道信号
 */
-(RACSignal *)emitSmellReturn:(Byte *)byte
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        int value = byte[1];
        if (value == 0x66) {
            NSString *cardNo = [NSString stringWithFormat:@"%02X%02X%02X%02X",byte[2],byte[3],byte[4],byte[5]];
            
            NSInteger duration = byte[6];
            
            NSDictionary *dic = @{EmitSmellNoKey:cardNo,EmitSmellDurationKey:@(duration)};
            [subscriber sendNext:dic];
            [subscriber sendCompleted];
        }
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"开启味道信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-07 16:06:29
 *
 *  获取皮肤包
 *
 *  @param packetId 皮肤包ID
 *
 *  @return 皮肤包信号
 */
-(RACSignal *)getSkinPacket:(NSString *)packetId
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SCDeviceInfoManager defaultManager] requestSmellSkinPacket:packetId Success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendCompleted];
        } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"皮肤包信号销毁");
        }];
    }];
}

/**
 *  @author RenRenFenQi, 16-06-02 14:06:34
 *
 *  根据名字匹配对象
 *
 *  @param fruitName 语音识别名称
 *  @param list      对象列表
 *
 *  @return 返回匹配对象
 */
-(Fruit *)matchFruitName:(NSString *)fruitName InList:(NSArray *)list
{
    if (list == nil) {
        return nil;
    }
    
    if (fruitName == nil) {
        return nil;
    }
    
    Fruit *fruit = nil;
    for (Fruit *f in list) {
        NSArray *nameList = [f.fruitName componentsSeparatedByString:@"|"];
        for (NSString *name in nameList) {
            if ([name isEqualToString:fruitName]) {
                fruit = f;
                break;
            }
        }
        if (fruit) {
            break;
        }
    }
    return fruit;
}
@end
