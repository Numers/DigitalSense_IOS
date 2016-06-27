//
//  BluetoothMacManager.m
//  IntelligentMask
//
//  Created by baolicheng on 16/3/24.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "BluetoothMacManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DataAnalizer.h"

#define ConnectTimeOut 15
#define kServiceUUID @"FFF0" //服务的UUID
#define kMacServiceUUID @"180A"//获取Mac地址的UUID
#define kCharacteristicNotifyUUID @"FFF1" //通知特征的UUID
#define kCharacteristicWriteUUID @"FFF2" //写入数据特征的UUID
#define kCharacteristicMacReadUUID @"2A23" //读取Mac地址的特征UUID

static NSInteger connectTime = 0;
static BluetoothMacManager *bluetoothMacManager;
@interface BluetoothMacManager()<CBCentralManagerDelegate,CBPeripheralDelegate,DataAnalizerProtocol>
{
    DataAnalizer *dataAnalizer;
    BluetoothCallBak deviceCallBack;
    BluetoothCallBak connectCallBack;
    ConnectType connectType;
    NSTimer *timer;
    BOOL isConnected;
}
@property (assign,nonatomic) id<BluetoothManagerProtocol> delegate;
@property (strong,nonatomic) CBCentralManager *centralManager;//中心设备管理器
@property (strong,nonatomic) NSMutableArray *peripherals;//搜索到的外围设备

@property(strong,nonatomic) NSMutableArray *peripheralMacArray;

@property (strong,nonatomic) CBPeripheral *peripheral;//当前连接的外围设备
@end
@implementation BluetoothMacManager
+(id)defaultManager
{
    if (bluetoothMacManager == nil) {
        bluetoothMacManager = [[BluetoothMacManager alloc] init];
    }
    return bluetoothMacManager;
}

-(void)setBluetoothManagerDelegate:(id<BluetoothManagerProtocol>)viewController
{
    self.delegate = viewController;
}

-(void)callBackDevice:(BOOL)connectCompelete WithCallbackType:(CallbackType)type
{
    isConnected = connectCompelete;
    BluetoothCallBak tempConnectCallBack = connectCallBack;
    BluetoothCallBak tempDeviceCallBack = deviceCallBack;
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
    if (!connectCompelete) {
        [self stopBluetoothDevice];
    }
    if (connectType == ConnectForSearch) {
        if (tempConnectCallBack) {
            tempConnectCallBack(connectCompelete,type,self.peripheralMacArray, connectType);
        }
        
        if (tempDeviceCallBack) {
            tempDeviceCallBack(connectCompelete,type,self.peripheralMacArray, connectType);
        }
    }else{
        if (tempConnectCallBack) {
            tempConnectCallBack(connectCompelete,type,self.peripherals, connectType);
        }
        
        if (tempDeviceCallBack) {
            tempDeviceCallBack(connectCompelete,type,self.peripherals, connectType);
        }
    }
}

-(BOOL)isConnected
{
    return isConnected;
}

-(void)startBluetoothDevice
{
    if (self.centralManager) {
        self.centralManager = nil;
    }
    //创建中心设备管理器并设置当前控制器视图为代理
    self.centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

-(void)startScanBluetoothDevice:(ConnectType)type callBack:(BluetoothCallBak)callBack
{
    [self inilizedDataBeforeBluetoothScan];
    deviceCallBack = callBack;
    connectCallBack = nil;
    connectType = type;
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

-(void)inilizedDataBeforeBluetoothScan
{
    isConnected = NO;
    connectTime = 0;
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
    if(self.peripherals){
        [self.peripherals removeAllObjects];
    }else{
        self.peripherals = [NSMutableArray array];
    }
    
    if (self.peripheralMacArray) {
        [self.peripheralMacArray removeAllObjects];
    }else{
        self.peripheralMacArray = [NSMutableArray array];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countConnectTime) userInfo:nil repeats:YES];
}

-(void)countConnectTime
{
    connectTime ++;
    if (connectTime > ConnectTimeOut) {
        [self callBackDevice:NO WithCallbackType:CallbackTimeout];
    }
}

-(void)stopBluetoothDevice
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
    
    if (self.centralManager) {
        [self.centralManager stopScan];
        if (self.peripheral) {
            [self.centralManager cancelPeripheralConnection:self.peripheral];
            self.peripheral = nil;
            isConnected = NO;
        }
    }
    
    if(deviceCallBack){
        deviceCallBack = nil;
    }
    
    if (connectCallBack) {
        connectCallBack = nil;
    }
}

-(void)cancelPeripheral:(CBPeripheral *)peripheral
{
    if (self.centralManager) {
        [self.centralManager cancelPeripheralConnection:peripheral];
        isConnected = NO;
    }
}

-(void)writeCharacteristicWithCommand:(BluetoothCommand)command {
    // Sends data to BLE peripheral to process HID and send EHIF command to PC
    if (!self.peripheral) {
        return;
    }
    
    if (self.peripheral.services == nil || self.peripheral.services.count == 0) {
        isConnected = NO;
        [self callBackDevice:NO WithCallbackType:CallbackDisconnect];
        return;
    }
    
    for ( CBService *service in self.peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicWriteUUID]]) {
                    /*EVERYTHING IS FOUND, WRITE characteristic !*/
                    NSData *msgData = [self writeDataWithCommand:command];
                    if (msgData) {
                        [self.peripheral writeValue:msgData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    }
                }
            }
        }
    }
}

-(void)writeCharacteristicWithRFID:(NSString *)rfId WithTimeInterval:(int)interval
{
    if (!self.peripheral) {
        return;
    }
    
    if (self.peripheral.services == nil || self.peripheral.services.count == 0) {
        isConnected = NO;
        [self callBackDevice:NO WithCallbackType:CallbackDisconnect];
        return;
    }
    
    for ( CBService *service in self.peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicWriteUUID]]) {
                    /*EVERYTHING IS FOUND, WRITE characteristic !*/
                    NSData *msgData = [self writeDataWithRFID:rfId WithTimeInterval:interval];
                    if (msgData) {
                        [self.peripheral writeValue:msgData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    }
                }
            }
        }
    }
}

/**
 *  @author RenRenFenQi, 16-06-17 13:06:43
 *
 *  给硬件设备发送指令
 *
 *  @param commandStr 指令字符串
 */
-(void)writeCharacteristicWithCommandStr:(NSString *)commandStr
{
    if (!self.peripheral) {
        return;
    }
    
    if (self.peripheral.services == nil || self.peripheral.services.count == 0) {
        isConnected = NO;
        [self callBackDevice:NO WithCallbackType:CallbackDisconnect];
        return;
    }
    
    for ( CBService *service in self.peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicWriteUUID]]) {
                    /*EVERYTHING IS FOUND, WRITE characteristic !*/
                    NSData *msgData = [self hexToBytes:commandStr];
                    if (msgData) {
                        [self.peripheral writeValue:msgData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    }
                }
            }
        }
    }
}

-(NSData *)writeDataWithCommand:(BluetoothCommand)command
{
    NSString *writeStr = nil;
    switch (command) {
        case CommandMacAddress:
        {
            writeStr = [self stringByCalculateValues:@(MacAddress),@(0x60),@(0x55),nil];
        }
            break;
        case CommandSleepDevice:
        {
            writeStr = [self stringByCalculateValues:@(SleepDevice),@(0x64),@(0x55),nil];
        }
            break;
        case CommandWakeUpDevice:
        {
            NSDate *now = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yy-MM-dd-HH-mm-ss-ee"];
            NSString *dateStr = [formatter stringFromDate:now];
            NSArray *timeArr = [dateStr componentsSeparatedByString:@"-"];
            NSInteger year = [[timeArr objectAtIndex:0] integerValue];
            NSInteger month = [[timeArr objectAtIndex:1] integerValue];
            NSInteger day = [[timeArr objectAtIndex:2] integerValue];
            NSInteger hour = [[timeArr objectAtIndex:3] integerValue];
            NSInteger minite = [[timeArr objectAtIndex:4] integerValue];
            NSInteger second = [[timeArr objectAtIndex:5] integerValue];
            NSInteger week = [[timeArr objectAtIndex:6] integerValue] - 1;
            writeStr = [self stringByCalculateValues:@(WakeUpDevice),@(0x63),[self hexIntToInteger:year],[self hexIntToInteger:month],[self hexIntToInteger:day],[self hexIntToInteger:hour],[self hexIntToInteger:minite],[self hexIntToInteger:second],@(week),@(0x55),nil];
        }
            break;
        case CommandOpenDeviceTime:
        {
            writeStr = [self stringByCalculateValues:@(OpenDeviceTime),@(0x61),@(0x55),nil];
        }
            break;
        case CommandCloseDeviceTime:
        {
            writeStr = [self stringByCalculateValues:@(CloseDeviceTime),@(0x62),@(0x55),nil];
        }
            break;
        case CommandBottleInfo:
        {
            writeStr = [self stringByCalculateValues:@(BottleInfo),@(0x65),@(0x55),nil];
        }
            break;
        default:
            break;
    }
    if (writeStr == nil) {
        return nil;
    }
    return [self hexToBytes:writeStr];
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


-(NSNumber *)hexIntToInteger:(NSInteger)value
{
    NSInteger tempValue1 = (value / 10) * 16;
    NSInteger tempValue2 = value % 10;
    return @(tempValue1 + tempValue2);
}

-(NSData *)writeDataWithRFID:(NSString *)rfId WithTimeInterval:(int)interval
{
    NSString *writeStr = [self stringByCaculateRFID:rfId WithTimeInterval:interval];
    return [self hexToBytes:writeStr];
}


-(NSString *)stringByCalculateValues:(id)value,... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableString *result = [[NSMutableString alloc] init];
    va_list args;
    va_start(args, value);
    for (id currentObject = value; currentObject != nil; currentObject = va_arg(args, id)) {
        if ([currentObject isKindOfClass:[NSNumber class]]) {
            [result appendFormat:@"%02X",[currentObject intValue]];
        }
        else{
            result = nil;
            break;
        }
    }
    va_end(args);
    return result;
}

-(NSString *)stringByCaculateRFID:(NSString *)rfId WithTimeInterval:(int)interval
{
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"%02X66",EmitSmell];
    [result appendFormat:@"%@",rfId];
    [result appendFormat:@"%04X",interval];
    [result appendFormat:@"55"];
    return result;
}

-(void)registerNotificationWithValue:(BOOL)isNotify
{
    if (!self.peripheral) {
        return;
    }
    for ( CBService *service in self.peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicNotifyUUID]]) {
                    /* EVERYTHING IS FOUND, WRITE characteristic ! */
                    if (!characteristic.isNotifying) {
                        [self.peripheral setNotifyValue:isNotify forCharacteristic:characteristic];
                    }
                }
            }
        }
    }
}

-(void)connectToPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral && self.centralManager) {
        if (connectType == ConnectToDevice) {
            //停止扫描
            [self.centralManager stopScan];
        }
        self.peripheral = peripheral;
        NSLog(@"开始连接外围设备...");
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

-(void)connectToPeripheral:(CBPeripheral *)peripheral callBack:(BluetoothCallBak)callBack
{
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
        isConnected = NO;
    }

    connectCallBack = callBack;
    deviceCallBack = nil;
    connectType = ConnectToDevice;
    if (peripheral && self.centralManager) {
        if (connectType == ConnectToDevice) {
            //停止扫描
            [self.centralManager stopScan];
        }
        self.peripheral = peripheral;
        NSLog(@"开始连接外围设备...");
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

/**
 *  @author RenRenFenQi, 16-06-24 15:06:17
 *
 *  根据设备名连接设备
 *
 *  @param peripheralName 设备名
 *  @param callBack       回调函数
 */
-(void)connectToPeripheralWithName:(NSString *)peripheralName callBack:(BluetoothCallBak)callBack
{
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
        isConnected = NO;
    }

    connectCallBack = callBack;
    deviceCallBack = nil;
    connectType = ConnectToDevice;
    CBPeripheral *peripheral = [self searchPeripheralWithName:peripheralName];
    if (peripheral == nil) {
        [self callBackDevice:NO WithCallbackType:CallbackDidFailToConnectPeriphera];
        return;
    }
    
    if (peripheral && self.centralManager) {
        if (connectType == ConnectToDevice) {
            //停止扫描
            [self.centralManager stopScan];
        }
        self.peripheral = peripheral;
        NSLog(@"开始连接外围设备...");
        [self.centralManager connectPeripheral:peripheral options:nil];
    }

}

-(CBPeripheral *)searchPeripheralWithName:(NSString *)name
{
    CBPeripheral *peripheral = nil;
    if (name) {
        for (CBPeripheral *p in self.peripherals) {
            if ([p.name isEqualToString:name]) {
                peripheral = p;
                break;
            }
        }
    }
    return peripheral;
}

-(NSArray *)returnAllSearchedPeripheralsDictionary
{
    return [NSArray arrayWithArray:self.peripheralMacArray];
}

/**
 *  @author RenRenFenQi, 16-06-24 15:06:46
 *
 *  获取搜索到的所有智能设备
 *
 *  @return 智能设备列表
 */
-(NSArray *)returnAllScanPeripherals
{
    return self.peripherals;
}

/**
 *  @author RenRenFenQi, 16-06-24 18:06:11
 *
 *  判断名字与当前连接蓝牙是否匹配
 *
 *  @param name 设备
 *
 *  @return YES/匹配  NO/不匹配
 */
-(BOOL)isMatchConnectedPeripheral:(CBPeripheral *)peripheral;
{
    if (isConnected) {
        if (self.peripheral) {
            if ([self.peripheral isEqual:peripheral]) {
                return YES;
            }
        }
    }
    return NO;
}
#pragma mark - CBCentralManager代理方法
//中心服务器状态更新后
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            //扫描外围设备
            //            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothPowerOnNotify object:nil];
            break;
            
        default:
            [self stopBluetoothDevice];
            [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothPowerOffNotify object:nil];
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            break;
    }
}
/**
 *  发现外围设备
 *
 *  @param central           中心设备
 *  @param peripheral        外围设备
 *  @param advertisementData 特征数据
 *  @param RSSI              信号质量（信号强度）
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现外围设备...");
    //连接外围设备
    if (peripheral) {
        //找到口罩设备的蓝牙信号
        if(![peripheral.name hasPrefix:@"HJ-580"]){
            return;
        }
        
        //添加保存外围设备，注意如果这里不保存外围设备（或者说peripheral没有一个强引用，无法到达连接成功（或失败）的代理方法，因为在此方法调用完就会被销毁
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
        }else{
            return;
        }
        
        if (connectType != ConnectForScan) {
            [self connectToPeripheral:peripheral];
        }
    }
    
}
//连接到外围设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外围设备成功!");
    //设置外围设备的代理为当前视图控制器
    peripheral.delegate=self;
    //外围设备开始寻找服务
    if (connectType == ConnectForSearch) {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:kMacServiceUUID]]];
    }else{
        [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
    }
}
//连接外围设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败!");
    if(connectType != ConnectForSearch){
        [self callBackDevice:NO WithCallbackType:CallbackDidFailToConnectPeriphera];
    }
}

#pragma mark - CBPeripheral 代理方法
//外围设备寻找到服务后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"已发现可用服务...");
    if(error){
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
        if (connectType != ConnectForSearch) {
            [self callBackDevice:NO WithCallbackType:CallbackDidDiscoverServicesError];
        }
        return;
    }
    
    if (connectType == ConnectForSearch) {
        CBUUID *characteristicReadUUID=[CBUUID UUIDWithString:kCharacteristicMacReadUUID];
        for (CBService *service in peripheral.services)
        {
            [peripheral discoverCharacteristics:@[characteristicReadUUID]  forService:service];
        }
    }else{
        //遍历服务搜索特征
        CBUUID *characteristicNotifyUUID=[CBUUID UUIDWithString:kCharacteristicNotifyUUID];
        CBUUID *characteristicWriteUUID=[CBUUID UUIDWithString:kCharacteristicWriteUUID];
        for (CBService *service in peripheral.services)
        {
            [peripheral discoverCharacteristics:@[characteristicNotifyUUID,characteristicWriteUUID]  forService:service];
        }
    }
}

//外围设备寻找到特征后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"已发现可用特征...");
    if (error) {
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
        if (connectType != ConnectForSearch) {
            [self callBackDevice:NO WithCallbackType:CallbackDidDiscoverCharacteristicsError];
        }
        return;
    }
    if (connectType == ConnectForSearch) {
        if (service.characteristics.count > 0) {
            [peripheral readValueForCharacteristic:[service.characteristics objectAtIndex:0]];
        }
    }else{
        [self registerNotificationWithValue:YES];
    }
}

//特征值被更新后
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"收到特征更新通知...");
    if (error) {
        NSLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
        if (connectType != ConnectForSearch) {
            [self callBackDevice:NO WithCallbackType:CallbackDidUpdateNotificationStateError];
        }
        return;
    }
    [self callBackDevice:YES WithCallbackType:CallbackSuccess];
}

//更新特征值后（调用readValueForCharacteristic:方法或者外围设备在订阅后更新特征值都会调用此代理方法）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"更新特征值时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    
    if (connectType == ConnectForSearch) {
        NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
        NSMutableString *macString = [[NSMutableString alloc] init];
        [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
        
        NSDictionary *dic = @{@"peripheral":peripheral,@"mac":macString};
        [self.peripheralMacArray addObject:dic];
        NSLog(@"macString:%@",macString);
        [self cancelPeripheral:peripheral];
    }else{
        if (characteristic.value) {
            if (dataAnalizer == nil) {
                dataAnalizer = [[DataAnalizer alloc] init];
                dataAnalizer.delegate = self;
            }
            [dataAnalizer inputData:characteristic.value];
        }else{
            NSLog(@"未发现特征值.");
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        isConnected = YES;
        NSLog(@"发送成功");
    }else{
        isConnected = NO;
        [self callBackDevice:NO WithCallbackType:CallbackDidWriteValueError];
    }
}

#pragma -mark DataAnalizerProtocol
-(void)outputData:(NSData *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothDeliveryDataNotify object:data];
    if ([self.delegate respondsToSelector:@selector(deliveryData:)]) {
        [self.delegate deliveryData:data];
    }
}

@end
