//
//  ScriptOperationViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/6.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptOperationViewController.h"
#import "ScriptSelectViewController.h"
#import "ScriptSerialViewController.h"

#import "BluetoothProcessManager.h"
#import "BluetoothMacManager.h"

#import "UINavigationController+WXSTransition.h"
#import "FullScreenPlayerViewController.h"
#import "ScriptCommand.h"
#import "RelativeTimeScript.h"

#import "PopoverView.h"
#import "ComboxView.h"

@interface ScriptOperationViewController ()<ScriptSerialViewProtocol,ScriptSelectViewProtocol,ComboxViewProtocol>
{
    ScriptSelectViewController *scriptSelectVC;
    ScriptSerialViewController *scriptSerialVC;
    
    BOOL isLoop;
    
    RelativeTimeScript *currentScript;
    
    NSArray *fruitList;
    
    PopoverView *popoverView;
    NSArray *popoverTitle;
    
    ComboxView *comboxView;
}
@property(nonatomic, strong) IBOutlet UIView *playView;
@property(nonatomic, strong) IBOutlet UILabel *lblAllTime;
@property(nonatomic, strong) IBOutlet UIButton *btnLoop;

@property(nonatomic, strong) IBOutlet UILabel *lblTitle;
@property(nonatomic, strong) IBOutlet UIButton *btnSelectDevice;
@end

@implementation ScriptOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //popoverView显示的title
    popoverTitle = @[@"刷新蓝牙"];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    scriptSelectVC = [[ScriptSelectViewController alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, (screenSize.height - _playView.frame.size.height - 64) * 2 / 3.0f)];
    scriptSelectVC.delegate = self;
    [self.view addSubview:scriptSelectVC.view];
    
    scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (screenSize.height - _playView.frame.size.height - 64) / 3.0f, self.view.frame.size.width, (screenSize.height - _playView.frame.size.height - 64) / 3.0f)];
    scriptSerialVC.delegate = self;
    if (fruitList && fruitList.count > 0) {
        [scriptSerialVC setFruitList:fruitList];
    }
    [self.view addSubview:scriptSerialVC.view];
    
    [self.view bringSubviewToFront:_playView];
    
    [self setIsLoop:YES];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height, _playView.frame.size.width, _playView.frame.size.height)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [self registerNotify];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

#pragma -mark Notification
-(void)onBottleInfoCompeletely:(NSNotification *)notify
{
    id obj = [notify object];
    if ([obj isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *bottleInfoList = (NSMutableArray *)obj;
        [self setFruitList:bottleInfoList];
    }
}

-(void)onStartScanBluetooth:(NSNotification *)notify
{
    [self.lblTitle setText:@"正在搜索智能设备..."];
    [self.btnSelectDevice setHidden:YES];
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    [self.lblTitle setText:@"设备未开启蓝牙"];
}

-(void)onCallbackScanBluetoothTimeout:(NSNotification *)notify
{
    [self.lblTitle setText:@"请选择您需要连接的设备"];
    [self.btnSelectDevice setHidden:NO];
}

-(void)onCallbackBluetoothDisconnected:(NSNotification *)notify
{
    [self.lblTitle setText:@"设备已断开"];
    [self.btnSelectDevice setHidden:NO];
}

-(void)onStartConnectToBluetooth:(NSNotification *)notify
{
    [self.lblTitle setText:@"连接中..."];
}

-(void)onCallbackConnectToBluetoothSuccessfully:(NSNotification *)notify
{
    [self.lblTitle setText:@"设备已连接"];
}

-(void)onCallbackConnectToBluetoothTimeout:(NSNotification *)notify
{
    [self.lblTitle setText:@"未发现有效设备"];
}

#pragma -mark private Functions
-(void)registerNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBottleInfoCompeletely:) name:BottleInfoCompeletelyNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartScanBluetooth:) name:OnStartScanBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothPowerOff:) name:OnCallbackBluetoothPowerOff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackScanBluetoothTimeout:) name:OnCallbackScanBluetoothTimeout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothDisconnected:) name:OnCallbackBluetoothDisconnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartConnectToBluetooth:) name:OnStartConnectToBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothSuccessfully:) name:OnCallbackConnectToBluetoothSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothTimeout:) name:OnCallbackConnectToBluetoothTimeout object:nil];
}

-(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger tempMinite = (seconds - second) / 60;
    NSInteger minite = tempMinite % 60;
    NSInteger hour = tempMinite / 60;
    NSString *result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minite,second];
    return result;
}

-(NSInteger)doWithScriptCommandList:(NSArray *)scriptCommandList
{
    if (scriptCommandList.count == 0) {
        return 0;
    }
    NSInteger allTime = 0;
    ScriptCommand *previousCommand = nil;
    for (ScriptCommand *command in scriptCommandList) {
        if (previousCommand == nil) {
            command.startRelativeTime = 0;
        }else{
            command.startRelativeTime = previousCommand.startRelativeTime + previousCommand.duration;
        }
        //组成command命令
        command.command = @"";
        previousCommand = command;
        allTime = allTime + command.duration;
    }
    return allTime;
}

-(void)setIsLoop:(BOOL)loop
{
    isLoop = loop;
    if (loop) {
        [_btnLoop setImage:[UIImage imageNamed:@"Player_Repeat"] forState:UIControlStateNormal];
    }else{
        [_btnLoop setImage:[UIImage imageNamed:@"Player_Once"] forState:UIControlStateNormal];
    }
}

-(void)setFruitList:(NSArray *)list
{
    if (list && list.count > 0) {
        fruitList = [list copy];
        if (scriptSerialVC) {
            [scriptSerialVC setFruitList:fruitList];
        }
    }
}

#pragma -mark ButtonEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickPlayBtn:(id)sender
{
    FullScreenPlayerViewController *fullScreenPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FullScreenPlayerViewIdentify"];
    RelativeTimeScript *script = [[RelativeTimeScript alloc] init];
    script.scriptId = @"10000";
    script.scriptName = @"自定义脚本";
    script.sceneName = @"气味王国";
    script.state =  ScriptIsNormal;
    script.type =  ScriptIsRelativeTime;
    script.isLoop = NO;
    NSMutableArray *scriptCommandList = [scriptSelectVC returnAllScriptCommand];
    script.scriptTime = [self doWithScriptCommandList:scriptCommandList];
    script.scriptCommandList = scriptCommandList;
    fullScreenPlayerVC.startView = _playView;
    currentScript = script;
    [fullScreenPlayerVC setScript:script IsLoop:isLoop];
    [self.navigationController wxs_pushViewController:fullScreenPlayerVC makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType = WXSTransitionAnimationTypeFragmentShowFromRight;
        transition.animationTime = 1.0f;
        transition.backGestureEnable = NO;
    }];
}

-(IBAction)clickLoopBtn:(id)sender
{
    if (isLoop) {
        [self setIsLoop:NO];
    }else{
        [self setIsLoop:YES];
    }
}

-(IBAction)clickAddBtn:(UIButton *)sender
{
    if(popoverView != nil)
    {
        [popoverView removeFromSuperview];
        popoverView = nil;
    }
    CGPoint point = CGPointMake(sender.frame.origin.x + sender.frame.size.width/2, sender.frame.origin.y + sender.frame.size.height);
    popoverView = [[PopoverView alloc] initWithPoint:point titles:popoverTitle images:nil];
    
    [popoverView setSelectRowAtIndex:^(NSInteger index) {
        switch (index) {
            case 0:
            {
                if ([[BluetoothMacManager defaultManager] isConnected]) {
                    [AppUtils showInfo:@"蓝牙已连接"];
                }else{
                    [[BluetoothProcessManager defatultManager] startScanBluetooth];
                }
            }
                break;
            default:
                break;
        }
    }];
    
    [popoverView show];
}

-(IBAction)clickSelectDeviceBtn:(id)sender
{
    if (comboxView) {
        if ([comboxView isShow]) {
            return;
        }
    }
    NSArray *peripheralArray = [[BluetoothMacManager defaultManager] returnAllScanPeripherals];
    if (peripheralArray.count == 0) {
        [AppUtils showInfo:@"未搜索到匹配设备"];
        return;
    }
    NSArray *peripheralNameArray = [[BluetoothMacManager defaultManager] returnAllScanPeripheralNames];
    NSUInteger defaultSelectedIndex = -1;
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        id connectedPeripheral = [[BluetoothMacManager defaultManager] returnConnectedPeripheral];
        if ([peripheralArray containsObject:connectedPeripheral]) {
            defaultSelectedIndex = [peripheralArray indexOfObject:connectedPeripheral];
        }
    }
    comboxView = [[ComboxView alloc] initWithStartPoint:CGPointMake(0, 64)  WithTitleArray:peripheralNameArray WithDataSourceArray:peripheralArray WithDefaultSelectedIndex:defaultSelectedIndex];
    comboxView.delegate = self;
    [comboxView showInView:self.view];
}
#pragma -mark ScriptSerialViewProtocol
-(void)selectFruit:(Fruit *)fruit
{
    if (scriptSerialVC) {
        [scriptSelectVC addFruit:fruit];
    }
}

#pragma -mark ScriptSelectViewProtocol
-(void)scriptCommandTimeDidChanged:(NSInteger)time
{
    NSString *timeStr = [self switchSecondsToTime:time];
    [_lblAllTime setText:timeStr];
}

#pragma -mark ComboxViewProtocol
-(void)selectPeripheral:(id)peripheral WithDeviceName:(NSString *)name
{
    [[BluetoothProcessManager defatultManager] connectToBluetooth:name WithPeripheral:peripheral];
}
@end
