//
//  DataAnalizer.m
//  IntelligentMask
//
//  Created by baolicheng on 16/1/19.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "DataAnalizer.h"
#import "BluetoothMacManager.h"
@implementation DataAnalizer
-(id)init
{
    self = [super init];
    if (self) {
        cacheData = [[NSMutableData alloc] init];
//        [self performSelectorInBackground:@selector(listenData) withObject:nil];
    }
    return self;
}

//校验返回数据是否正确
-(void)inputData:(NSData *)data
{
    NSLog(@"收到数据:%@",data);
    if (!data || data.length == 0) {
        return;
    }
    
//    if ([self.delegate respondsToSelector:@selector(outputData:)]) {
//        [self.delegate outputData:data];
//    }

    [cacheData appendData:data];
    [self performSelectorInBackground:@selector(doWithData) withObject:nil];
}

//-(void)listenData
//{
//    NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doWithData) userInfo:nil repeats:YES];
//    [currentLoop addTimer:timer forMode:NSDefaultRunLoopMode];
//    [currentLoop run];
//}

-(void)doWithData
{
    NSLog(@"准备执行一次循环");
    @synchronized (self) {
        NSLog(@"开始执行一次循环");
        while (cacheData.length > 0) {
            Byte *byte = (Byte *)[cacheData bytes];
            CommandType command = byte[0];
            switch (command) {
                case MacAddress:
                {
                    if (cacheData.length >= 8) {
                        Byte check = byte[7];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 8)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case OpenDeviceTime:
                {
                    if (cacheData.length >= 8) {
                        Byte check = byte[7];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 8)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case CloseDeviceTime:
                {
                    if (cacheData.length >= 8) {
                        Byte check = byte[7];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 8)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case WakeUpDevice:
                {
                    if (cacheData.length >= 10) {
                        Byte check = byte[9];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 10)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 10) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case SleepDevice:
                {
                    if (cacheData.length >= 3) {
                        Byte check = byte[2];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 3)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 3) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case BottleInfo:
                {
                    if (cacheData.length >= 8) {
                        Byte check = byte[7];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 8)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case EmitSmell:
                {
                    if (cacheData.length >= 9) {
                        Byte check = byte[8];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 9)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 9) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                case BottleInfoCompletely:
                {
                    if (cacheData.length >= 3) {
                        Byte check = byte[2];
                        if (check == 0x55) {
                            NSData *sendData = [cacheData subdataWithRange:NSMakeRange(0, 3)];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData replaceBytesInRange:NSMakeRange(0, 3) withBytes:NULL length:0];
                        }else{
                            //如果长度够长一个当前指令，但对应校验位不是0x55，那么认为是数据错乱或丢失，直接结束并清空缓存区
                            NSData *sendData = [self hexToBytes:[NSString stringWithFormat:@"%02X0055",BottleInfoCompletely]];
                            if ([self.delegate respondsToSelector:@selector(outputData:)]) {
                                [self.delegate outputData:sendData];
                            }
                            [cacheData  replaceBytesInRange:NSMakeRange(0, cacheData.length) withBytes:NULL length:0];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            
        }
    }
}

-(NSData*) hexToBytes:(NSString *)str {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
