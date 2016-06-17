//
//  ScriptViewModel.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptViewModel.h"
#import "SCScriptManager.h"

@implementation ScriptViewModel
/**
 *  @author RenRenFenQi, 16-06-17 18:06:35
 *
 *  根据macAddress
 *
 *  @param macAddress mac地址
 *
 *  @return 获取脚本信号
 */
-(RACSignal *)requestScriptInfoWithMacAddress:(NSString *)macAddress
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SCScriptManager defaultManager] requestScriptInfoWithMacAddress:macAddress Success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } Error:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendCompleted];
        } Failed:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"获取脚本信号销毁");
        }];
    }];
}
@end
