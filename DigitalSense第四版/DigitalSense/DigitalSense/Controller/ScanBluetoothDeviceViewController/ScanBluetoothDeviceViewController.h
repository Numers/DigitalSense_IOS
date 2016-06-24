//
//  ScanBluetoothDeviceViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/24.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ScanBluetoothDeviceViewProtocol <NSObject>
-(void)connectToBluetoothWithPeripheral:(id)peripheral WithName:(NSString *)name;
@end
@interface ScanBluetoothDeviceViewController : UIViewController
@property(nonatomic, assign) id<ScanBluetoothDeviceViewProtocol> delegate;
@end
