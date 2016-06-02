//
//  ViewModel.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/1.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ViewModel.h"
#import "Fruit.h"

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
            }
        }];
    }
    return self;
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
            if (i != 6) {
                [result appendString:@":"];
            }
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
            [result appendFormat:@"%d",value];
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
            [result appendFormat:@"%d",value];
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
        NSString *temp1 = [NSString stringWithFormat:@"0x%02X%02X%02X%02X",byte[1],byte[2],byte[3],byte[4]];
        NSScanner *scanner1 = [NSScanner scannerWithString:temp1];
        unsigned long long cardNo;
        [scanner1 scanHexLongLong:&cardNo];
        
        NSString *temp2 = [NSString stringWithFormat:@"0x%02X%02X",byte[5],byte[6]];
        NSScanner *scanner2 = [NSScanner scannerWithString:temp2];
        unsigned long long useTime;
        [scanner2 scanHexLongLong:&useTime];

        Fruit *fruit = [[Fruit alloc] init];
        fruit.fruitRFID = [[NSNumber numberWithLongLong:cardNo] integerValue];
        
        NSDictionary *dic = @{BottleKey:fruit,BottleUseTimeKey:@(useTime)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取每个瓶子时间信号销毁");
        }];
    }];
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
        NSString *temp1 = [NSString stringWithFormat:@"0x%02X%02X%02X%02X",byte[1],byte[2],byte[3],byte[4]];
        NSScanner *scanner1 = [NSScanner scannerWithString:temp1];
        unsigned long long cardNo;
        [scanner1 scanHexLongLong:&cardNo];
        
        NSInteger duration = byte[5];
    
        NSDictionary *dic = @{EmitSmellNoKey:@(cardNo),EmitSmellDuration:@(duration)};
        [subscriber sendNext:dic];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"开启味道信号销毁");
        }];
    }];
}
@end
