//
//  ScanBluetoothDeviceViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/24.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScanBluetoothDeviceViewController.h"
#import "BluetoothMacManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#define DeviceNameCellIdentify @"DeviceNameCellIdentify"
@interface ScanBluetoothDeviceViewController ()<UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSArray *deviceList;
    CBPeripheral *selectPeripheral;
}
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ScanBluetoothDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    self.tableView.tableFooterView = [UIView new];

    
    NSArray *peripherals = [[BluetoothMacManager defaultManager] returnAllScanPeripherals];
    if (peripherals && peripherals.count > 0) {
        deviceList = [NSArray arrayWithArray:peripherals];
    }else{
        deviceList = [NSArray array];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark ButtonClickEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark UITableViewDelegate And UITableViewDataSource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceNameCellIdentify forIndexPath:indexPath];
    if (cell) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                CBPeripheral *peripheral = [deviceList objectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UILabel *lblDeviceName = (UILabel *)[cell viewWithTag:1];
                    [lblDeviceName setText:peripheral.name];
                });
            }
        });
    }else{
        return [UITableViewCell new];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectPeripheral = [deviceList objectAtIndex:indexPath.row];
    NSString *message = [NSString stringWithFormat:@"确定要连接%@吗?",selectPeripheral.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma -mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([self.delegate respondsToSelector:@selector(connectToBluetoothWithPeripheral:WithName:)]) {
            [self.delegate connectToBluetoothWithPeripheral:selectPeripheral WithName:selectPeripheral.name];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
