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
#import "IFlySpeechSynthesizerManager.h"
#define SpeakDelay 0.5f
#define SelectTagKey @"SelectTagKey"
#define CloseButtonTag 0
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *cellIdentifyArr;
    NSNumber *selectTag;
    
    //按钮
    UIButton *_btnApple;
    UIButton *_btnMango;
    UIButton *_btnKiwifruit;
    UIButton *_btnOrange;
    UIButton *_btnCoconut;
    UIButton *_btnPeach;
    UIButton *_btnPineapple;
    UIButton *_btnStrawberry;
    UIButton *_btnMore;
}
@property(nonatomic, strong) IBOutlet UILabel *lblTitle;
@property(nonatomic, strong) IBOutlet UIView *tabBarView;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UIButton *btnVoice;
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
    UIImage * backgroundImg = [UIImage imageNamed:@"TabBarBackgroundImage"];
    _tabBarView.layer.contents = (id)backgroundImg.CGImage;
    [_btnVoice setImage:[UIImage imageNamed:@"voiceBtn_Normal"] forState:UIControlStateNormal];
    [_btnVoice setImage:[UIImage imageNamed:@"voiceBtn_Hightlight"] forState:UIControlStateHighlighted];
    
    id cacheSelectTag = [[NSUserDefaults standardUserDefaults] objectForKey:SelectTagKey];
    if (cacheSelectTag) {
        selectTag = cacheSelectTag;
    }else{
        selectTag = [NSNumber numberWithInteger:CloseButtonTag];
    }
    cellIdentifyArr = @[@"FirstIndexCellIdentify",@"SecondIndexCellIdentify",@"ThirdIndexCellIdentify"];
    
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

//如果isFromVoice为YES,可能来自状态同步或语音控制，直接进行状态改变。
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
        [AppUtils showInfo:@"请先打开蓝牙或者刷新重连"];
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
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellMango];
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
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellCoconut];
                break;
            case 6:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPeach];
                break;
            case 7:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPineapple];
                break;
            case 8:
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellStrawberry];
                break;
            case 9:
                return;
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
        [AppUtils showInfo:@"请先打开蓝牙或者刷新重连"];
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
                    
                    if ([highMatch isEqualToString:@"芒果"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellMango];
                                    [self setSelectTag:1 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"苹果"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellApple];
                                    [self setSelectTag:2 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"猕猴桃"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellKiwifruit];
                                    [self setSelectTag:3 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"橘子"] || [highMatch isEqualToString:@"橙子"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellOrange];
                                    [self setSelectTag:4 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"椰子"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellCoconut];
                                    [self setSelectTag:5 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"水蜜桃"] || [highMatch isEqualToString:@"桃子"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPeach];
                                    [self setSelectTag:6 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"菠萝"] || [highMatch isEqualToString:@"凤梨"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPineapple];
                                    [self setSelectTag:7 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"草莓"]) {
                        [AppUtils showInfo:@"草莓味正在研究中，敬请期待"];
                        return ;
                    }
                    
                    if ([highMatch isEqualToString:@"关闭"] || [highMatch isEqualToString:@"关"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellClose];
                                    [self setSelectTag:CloseButtonTag voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch hasPrefix:@"nomatch"]) {
                        //指令未识别
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:NO Callback:^(BOOL completely) {
                            
                        }];
                    }
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
    CGFloat height = ([UIScreen mainScreen].bounds.size.width / 3.f) * 80.f / 69.f;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[cellIdentifyArr objectAtIndex:indexPath.row]];
    switch (indexPath.row) {
        case 0:
        {
            _btnMango = [cell viewWithTag:1];
            [self setButtonState:_btnMango Name:@"Mango"];
            _btnApple = [cell viewWithTag:2];
            [self setButtonState:_btnApple Name:@"Apple"];
            _btnKiwifruit = [cell viewWithTag:3];
            [self setButtonState:_btnKiwifruit Name:@"Kiwifruit"];
        }
            break;
        case 1:
        {
            _btnOrange = [cell viewWithTag:4];
            [self setButtonState:_btnOrange Name:@"Orange"];
            _btnCoconut = [cell viewWithTag:5];
            [self setButtonState:_btnCoconut Name:@"Coconut"];
            _btnPeach = [cell viewWithTag:6];
            [self setButtonState:_btnPeach Name:@"Peach"];
        }
            break;
        case 2:
        {
            _btnPineapple = [cell viewWithTag:7];
            [self setButtonState:_btnPineapple Name:@"Pineapple"];
            _btnStrawberry = [cell viewWithTag:8];
            [self setButtonState:_btnStrawberry Name:@"Strawberry"];
            _btnMore = [cell viewWithTag:9];
            [self setButtonState:_btnMore Name:@"More"];
        }
            break;
        default:
            break;
    }
    return cell;
}
@end
