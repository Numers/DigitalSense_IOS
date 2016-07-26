//
//  BluetoothProcessManager.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/18.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "BluetoothProcessManager.h"
#import "BluetoothMacManager.h"

#define LastConnectDeviceNameKey @"LastConnectDeviceNameKey"

@implementation BluetoothProcessManager
+(instancetype)defatultManager
{
    static BluetoothProcessManager *bluetoothProcessManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothProcessManager = [[BluetoothProcessManager alloc] init];
    });
    return bluetoothProcessManager;
}

-(void)registerNotify
{
    [[BluetoothMacManager defaultManager] startBluetoothDevice];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothPowerOn:) name:kBluetoothPowerOnNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothPowerOff:) name:kBluetoothPowerOffNotify object:nil];
}

-(void)startScanBluetooth
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OnStartScanBluetooth object:nil];
    [[BluetoothMacManager defaultManager] startScanBluetoothDevice:ConnectForScan callBack:^(BOOL completely, CallbackType backType, id obj, ConnectType connectType) {
        if (completely) {
            
        }else{
            if(backType == CallbackBluetoothPowerOff)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothPowerOff object:nil];
            }else if(backType == CallbackTimeout){
                [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackScanBluetoothTimeout object:nil];
                NSString *lastConnectDeviceName = [[NSUserDefaults standardUserDefaults] objectForKey:LastConnectDeviceNameKey];
                if (lastConnectDeviceName) {
                    [self connectToBluetooth:lastConnectDeviceName WithPeripheral:nil];
                }

            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothDisconnected object:nil];
            }
        }
    }];
}

-(void)reconnectBluetooth
{
    CBPeripheral *peripheral = [[BluetoothMacManager defaultManager] returnConnectedPeripheral];
    if (peripheral) {
        [self connectToBluetooth:nil WithPeripheral:peripheral];
    }else{
        NSString *lastConnectDeviceName = [[NSUserDefaults standardUserDefaults] objectForKey:LastConnectDeviceNameKey];
        if (lastConnectDeviceName) {
            [self connectToBluetooth:lastConnectDeviceName  WithPeripheral:nil];
        }
    }
}

-(void)connectToBluetooth:(NSString *)deviceName WithPeripheral:(id)peripheral
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OnStartConnectToBluetooth object:nil];
    if (peripheral) {
        [[BluetoothMacManager defaultManager] connectToPeripheral:peripheral callBack:^(BOOL completely, CallbackType backType, id obj, ConnectType connectType) {
            if (completely) {
                [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackConnectToBluetoothSuccessfully object:nil];
                [self executeBluetoothCommand:deviceName];
            }else{
                if(backType == CallbackBluetoothPowerOff)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothPowerOff object:nil];
                }else if(backType == CallbackTimeout){
                    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackConnectToBluetoothTimeout object:nil];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothDisconnected object:nil];
                }
            }
            
        }];
    }else{
        [[BluetoothMacManager defaultManager] connectToPeripheralWithName:deviceName callBack:^(BOOL completely, CallbackType backType, id obj, ConnectType connectType) {
            if (completely) {
                [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackConnectToBluetoothSuccessfully object:nil];
                [self executeBluetoothCommand:deviceName];
            }else{
                if(backType == CallbackBluetoothPowerOff)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothPowerOff object:nil];
                }else if(backType == CallbackTimeout){
                    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackConnectToBluetoothTimeout object:nil];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothDisconnected object:nil];
                }
            }
        }];
    }
}

-(void)executeBluetoothCommand:(NSString *)deviceName
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceName forKey:LastConnectDeviceNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandMacAddress];
    
    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandOpenDeviceTime];
    
    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandCloseDeviceTime];
    
    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandWakeUpDevice];
    
    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandBottleInfo];
}

//关闭蓝牙连接
-(void)disConnectBluetooth
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OnCallbackBluetoothPowerOff object:nil];
    [[BluetoothMacManager defaultManager] stopBluetoothDevice];
}

#pragma -mark Notification
-(void)bluetoothPowerOn:(NSNotification *)notify
{
    [self performSelectorOnMainThread:@selector(startScanBluetooth) withObject:nil waitUntilDone:NO];
}

-(void)bluetoothPowerOff:(NSNotification *)notify
{
    [self performSelectorOnMainThread:@selector(disConnectBluetooth) withObject:nil waitUntilDone:NO];
}
@end
