//
//  ScriptOperationViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/6.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BottleInfoCompeletelyNotify @"BottleInfoCompeletelyNotify"
@protocol ScriptOperationViewProtocol <NSObject>
-(void)refreshBluetoothData;
@end
@interface ScriptOperationViewController : UIViewController
@property(nonatomic, assign) id<ScriptOperationViewProtocol> delegate;
-(void)setFruitList:(NSArray *)list;
@end
