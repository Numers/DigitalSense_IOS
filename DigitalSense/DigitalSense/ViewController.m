//
//  ViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "AppUtils.h"
#import "BluetoothMacManager.h"
#import "IflyRecognizerManager.h"
#define SelectTagKey @"SelectTagKey"
#define CloseButtonTag 8
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *cellIdentifyArr;
    NSNumber *selectTag;
    
    //按钮
    UIButton *_btnApple;
    UIButton *_btnBanana;
    UIButton *_btnKiwifruit;
    UIButton *_btnOrange;
    UIButton *_btnWatermelon;
    UIButton *_btnPear;
    UIButton *_btnPineapple;
}
@property(nonatomic, strong) IBOutlet UILabel *lblTitle;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(connectToBluetooth)];
//    header.lastUpdatedTimeLabel.hidden = YES;
//    [header setTitle:@"下拉重连" forState:MJRefreshStateIdle];
//    [header setTitle:@"松开连接" forState:MJRefreshStatePulling];
//    [header setTitle:@"正在连接..." forState:MJRefreshStateRefreshing];
//    self.tableView.mj_header = header;
    
    
    id cacheSelectTag = [[NSUserDefaults standardUserDefaults] objectForKey:SelectTagKey];
    if (cacheSelectTag) {
        selectTag = cacheSelectTag;
    }else{
        selectTag = [NSNumber numberWithInteger:CloseButtonTag];
    }
    cellIdentifyArr = @[@"SeperateCellIdentify",@"FirstIndexCellIdentify",@"SecondIndexCellIdentify",@"ThirdIndexCellIdentify",@"FourthIndexCellIdentify",@"SeperateCellIdentify"];
    
    [[BluetoothMacManager defaultManager] startBluetoothDevice];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliveryData:) name:BluetoothDeliveryDataNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothPowerOn:) name:kBluetoothPowerOnNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothPowerOff:) name:kBluetoothPowerOffNotify object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[IflyRecognizerManager defaultManager] stopRecongnizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Notification
-(void)bluetoothPowerOn:(NSNotification *)notify
{
    [self connectToBluetooth];
}

-(void)bluetoothPowerOff:(NSNotification *)notify
{
    [self disConnectBluetooth:@"设备未开启蓝牙"];
}

-(void)deliveryData:(NSNotification *)notify
{
    NSData *data = [notify object];
    Byte *byte = (Byte *)[data bytes];
    if (data.length > 2) {
        int code = (int)byte[1];
        BluetoothCommand command = (BluetoothCommand)code;
        //返回data解析出来的对应响应指令
        if (command == CommandSmellClose) {
            [self setSelectTag:CloseButtonTag voice:YES];
        }else{
            [self setSelectTag:command voice:YES];
        }
    }
}

#pragma -mark private function
//连接智能设备蓝牙
-(void)connectToBluetooth
{
    [self.lblTitle setText:@"连接中..."];
    [[BluetoothMacManager defaultManager] startScanBluetoothDevice:ConnectToDevice callBack:^(BOOL completely, CallbackType backType, id obj, ConnectType connectType) {
        if (completely) {
            [self.lblTitle setText:@"设备已连接"];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSwitchStatus];
        }else{
            if(backType == CallbackBluetoothPowerOff)
            {
                [self.lblTitle setText:@"设备未开启蓝牙"];
            }else if(backType == CallbackTimeout){
                [self.lblTitle setText:@"未发现有效设备"];
            }else{
                [self.lblTitle setText:@"设备已断开"];
            }
        }
        
        if([self.tableView.mj_header isRefreshing]){
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

//关闭蓝牙连接
-(void)disConnectBluetooth:(NSString *)description
{
    [self.lblTitle setText:description];
    [[BluetoothMacManager defaultManager] stopBluetoothDevice];
}

-(void)setSelectTag:(NSInteger)tag voice:(BOOL)isFromVoice
{
    if (!isFromVoice) {
        if (tag == [selectTag integerValue]) {
            selectTag = [NSNumber numberWithInteger:CloseButtonTag];
        }else{
            selectTag = [NSNumber numberWithInteger:tag];
        }
    }else{
        selectTag = [NSNumber numberWithInteger:tag];
    }
   
    [[NSUserDefaults standardUserDefaults] setObject:selectTag forKey:SelectTagKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

-(void)setButtonState:(UIButton *)button Name:(NSString *)name
{
    NSString *picName = nil;
    if (button.tag == [selectTag integerValue]) {
        picName = [NSString stringWithFormat:@"%@OpenBtn_Normal",name];
        [button setImage:[UIImage imageNamed:picName] forState:UIControlStateNormal];
        [button setImage:nil forState:UIControlStateHighlighted];
    }else{
        picName = [NSString stringWithFormat:@"%@Btn_Normal",name];
        [button setImage:[UIImage imageNamed:picName] forState:UIControlStateNormal];
        NSString *highlightPic = [picName stringByReplacingOccurrencesOfString:@"Normal" withString:@"Hightlight"];
        [button setImage:[UIImage imageNamed:highlightPic] forState:UIControlStateHighlighted];
    }
}

#pragma -mark ButtonClickEvent
-(IBAction)clickSwitchBtn:(id)sender
{
    if (![[BluetoothMacManager defaultManager] isConnected]) {
        //提示打开蓝牙或下拉重连
        [AppUtils showInfo:@"请先打开蓝牙或者下拉重连"];
        return;
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = sender;
        if (button.tag == [selectTag integerValue]) {
            //如果点击打开状态的按钮，则执行关闭指令
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellClose];
            [self setSelectTag:button.tag voice:NO];
            return;
        }
        switch (button.tag) {
            case 1:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellBanana];
                break;
            case 2:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellApple];
                break;
            case 3:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellKiwifruit];
                break;
            case 4:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellOrange];
                break;
            case 5:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellWatermelon];
                break;
            case 6:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPear];
                break;
            case 7:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPineapple];
                break;
            case CloseButtonTag:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellClose];
                break;
            default:
                break;
        }
        [self setSelectTag:button.tag voice:NO];
    }
}

-(IBAction)TouchDownVoiceBtn:(id)sender
{
    NSLog(@"按钮按下了...");
    
}

-(IBAction)TouchUpinsideVoiceBtn:(id)sender
{
    NSLog(@"按钮松开了...");
    if (![[BluetoothMacManager defaultManager] isConnected]) {
        //提示打开蓝牙或下拉重连
        [AppUtils showInfo:@"请先打开蓝牙或者下拉重连"];
        return;
    }
    [[IflyRecognizerManager defaultManager] startRecognizer:^(NSString *result) {
        NSLog(@"%@",result);
        NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
        if (!err) {
            NSArray *wsArr = [dic objectForKey:@"ws"];
            if (wsArr && wsArr.count > 0) {
                NSDictionary *tempDic = [wsArr objectAtIndex:0];
                NSArray *cwArr = [tempDic objectForKey:@"cw"];
                if (cwArr && cwArr.count > 0) {
                    NSDictionary *infoDic = [cwArr objectAtIndex:0];
                    NSString *highMatch = [infoDic objectForKey:@"w"];
                    
                    NSInteger tag = [selectTag integerValue];
                    if ([highMatch isEqualToString:@"香蕉"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellBanana];
                        tag = 1;
                    }
                    
                    if ([highMatch isEqualToString:@"苹果"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellApple];
                        tag = 2;
                    }
                    
                    if ([highMatch isEqualToString:@"猕猴桃"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellKiwifruit];
                        tag = 3;
                    }
                    
                    if ([highMatch isEqualToString:@"橘子"] || [highMatch isEqualToString:@"橙子"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellOrange];
                        tag = 4;
                    }
                    
                    if ([highMatch isEqualToString:@"西瓜"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellWatermelon];
                        tag = 5;
                    }
                    
                    if ([highMatch isEqualToString:@"梨子"] || [highMatch isEqualToString:@"梨"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPear];
                        tag = 6;
                    }
                    
                    if ([highMatch isEqualToString:@"菠萝"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPineapple];
                        tag = 7;
                    }
                    
                    if ([highMatch isEqualToString:@"关闭"] || [highMatch isEqualToString:@"关"]) {
                        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellClose];
                        tag = CloseButtonTag;
                    }
                    
                    if ([highMatch hasPrefix:@"nomatch"]) {
                        //指令未识别
                        [AppUtils showInfo:@"指令未识别，请重试"];
                    }
                    
                    [self setSelectTag:tag voice:YES];
                }
            }
        }
    }];
}

-(IBAction)clickRefreshBtn:(id)sender
{
    [self connectToBluetooth];
}

#pragma -mark UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 5) {
        return 22.0f;
    }
    return 122.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellIdentifyArr objectAtIndex:indexPath.row]];
    switch (indexPath.row) {
        case 0:
            
            break;
        case 1:
        {
            _btnBanana = [cell viewWithTag:1];
            [self setButtonState:_btnBanana Name:@"Banana"];
            _btnApple = [cell viewWithTag:2];
            [self setButtonState:_btnApple Name:@"Apple"];
        }
            break;
        case 2:
        {
            _btnKiwifruit = [cell viewWithTag:3];
            [self setButtonState:_btnKiwifruit Name:@"Kiwifruit"];
            _btnOrange = [cell viewWithTag:4];
            [self setButtonState:_btnOrange Name:@"Orange"];
        }
            break;
        case 3:
        {
            _btnWatermelon = [cell viewWithTag:5];
            [self setButtonState:_btnWatermelon Name:@"Watermelon"];
            _btnPear = [cell viewWithTag:6];
            [self setButtonState:_btnPear Name:@"Pear"];
        }
            break;
        case 4:
        {
            _btnPineapple = [cell viewWithTag:7];
            [self setButtonState:_btnPineapple Name:@"Pineapple"];
        }
            break;
        case 5:
        
            break;
        default:
            break;
    }
    return cell;
}
@end
