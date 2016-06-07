//
//  DataAnalizer.m
//  IntelligentMask
//
//  Created by baolicheng on 16/1/19.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "DataAnalizer.h"
@implementation DataAnalizer
-(id)init
{
    self = [super init];
    if (self) {
        dataIsCompletely = YES;
    }
    return self;
}

//校验返回数据是否正确
-(void)inputData:(NSData *)data
{
    if (!data || data.length == 0) {
        return;
    }
    
//    Byte *byte = (Byte *)[data bytes];
//    for (int i = 0; i < data.length; i++) {
//        NSLog(@"%02X",byte[i]);
//    }
    
    if ([self.delegate respondsToSelector:@selector(outputData:)]) {
        [self.delegate outputData:data];
    }
    
//    if (dataIsCompletely) {
//        dataIsCompletely = NO;
//    }
//    
//    if (data.length == 3) {
//        dataIsCompletely = YES;
//    }
//    
//    if (dataIsCompletely) {
//        
//    }
}
@end
