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

#import "UIDevice+IphoneModel.h"

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
@property(nonatomic, strong) IBOutlet UIView *playViewSubLayerBackgroundView;
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
    
    [_playView.layer setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.2].CGColor];
    [_playView.layer setShadowOffset:CGSizeMake(0, 5)];
    [_playView.layer setShadowOpacity:1.0f];
    //适配TitleLabel的字体大小
    [UIDevice adaptUILabelTextFont:self.lblTitle WithIphone5FontSize:17.0f IsBold:YES];
    
    UIImage *backImage = [UIImage imageNamed:@"OperationBackgroundViewImage"];
    self.view.layer.contents = (id)backImage.CGImage;
    
    UIImage *playViewBackgroundImage = [UIImage imageNamed:@"Player_BackgroundViewImage"];
    _playViewSubLayerBackgroundView.layer.contents = (id)playViewBackgroundImage.CGImage;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    scriptSelectVC = [[ScriptSelectViewController alloc] initWithFrame:CGRectMake(45, 97, self.view.frame.size.width - 90, (screenSize.height - _playView.frame.size.height - 162) * 2 / 3.0f)];
    scriptSelectVC = [[ScriptSelectViewController alloc] initWithFrame:CGRectMake(45, 97, self.view.frame.size.width - 90, 230.667)];
    scriptSelectVC.delegate = self;
    [self.view addSubview:scriptSelectVC.view];
    
//    scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(17, self.view.frame.size.height - 30 - (screenSize.height - _playView.frame.size.height - 162) * 1 / 3.0f, self.view.frame.size.width - 34, (screenSize.height - _playView.frame.size.height - 162) * 1 / 3.0f)];
    switch ([UIDevice iPhonesModel]) {
        case iPhone4: {
            CGFloat seriaViewOriginY = scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + _playView.frame.size.height + 35.0f;
            scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(17, seriaViewOriginY, self.view.frame.size.width - 34, screenSize.height - seriaViewOriginY)];
            break;
        }
        case iPhone5: {
            CGFloat seriaViewOriginY = scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + _playView.frame.size.height + 35.0f;
            scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(17, seriaViewOriginY, self.view.frame.size.width - 34, screenSize.height - seriaViewOriginY - 5.0f)];
            break;
        }
        case iPhone6: {
            CGFloat seriaViewOriginY = scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + _playView.frame.size.height + 35.0f;
            scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(17, seriaViewOriginY, self.view.frame.size.width - 34, screenSize.height - seriaViewOriginY - 10.0f)];
            break;
        }
        case iPhone6Plus: {
            CGFloat seriaViewOriginY = scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + _playView.frame.size.height + 35.0f;
            scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(17, seriaViewOriginY + 20, self.view.frame.size.width - 34, screenSize.height - seriaViewOriginY - 70.0f)];
            break;
        }
        case UnKnown: {
            break;
        }
    }
    
    if (scriptSerialVC) {
        scriptSerialVC.delegate = self;
        if (fruitList && fruitList.count > 0) {
            [scriptSerialVC setFruitList:fruitList];
        }
        [self.view addSubview:scriptSerialVC.view];
    }
    
    [self.view bringSubviewToFront:_playView];
    
    [self setIsLoop:NO];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    switch ([UIDevice iPhonesModel]) {
        case iPhone4: {
            [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + 10, _playView.frame.size.width, _playView.frame.size.height)];
            break;
        }
        case iPhone5: {
            [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + 10, _playView.frame.size.width, _playView.frame.size.height)];
            break;
        }
        case iPhone6: {
            [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + 20, _playView.frame.size.width, _playView.frame.size.height)];
            break;
        }
        case iPhone6Plus: {
            [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + 30, _playView.frame.size.width, _playView.frame.size.height)];
            break;
        }
        case UnKnown: {
            [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height + 10, _playView.frame.size.width, _playView.frame.size.height)];
            break;
        }
    }
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
    NSInteger minite = (seconds - second) / 60;
    NSString *result;
    if (minite < 10) {
       result = [NSString stringWithFormat:@"%02ld:%02ld",minite,second];
    }else{
        result = [NSString stringWithFormat:@"%ld:%02ld",minite,second];
    }
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
        if (command.rfId) {
            command.command = @"";
        }else{
            command.command = nil;
        }
        previousCommand = command;
        allTime = allTime + command.duration;
    }
    return allTime;
}

-(void)setIsLoop:(BOOL)loop
{
    isLoop = loop;
    if (loop) {
        [_btnLoop setBackgroundImage:[UIImage imageNamed:@"Player_Repeat"] forState:UIControlStateNormal];
    }else{
        [_btnLoop setBackgroundImage:[UIImage imageNamed:@"Player_Once"] forState:UIControlStateNormal];
    }
}

-(void)setFruitList:(NSArray *)list
{
    if (list && list.count > 0) {
        fruitList = [list copy];
        if (scriptSerialVC) {
            [scriptSerialVC setFruitList:fruitList];
        }
        
        if (scriptSelectVC) {
            [scriptSelectVC clearAllData];
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
    NSMutableArray *scriptCommandList = [scriptSelectVC returnAllScriptCommand];
    if (scriptCommandList.count == 0) {
        [AppUtils showInfo:@"请先自定义一个脚本"];
        return;
    }
    FullScreenPlayerViewController *fullScreenPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FullScreenPlayerViewIdentify"];
    RelativeTimeScript *script = [[RelativeTimeScript alloc] init];
    script.scriptId = @"10000";
    script.scriptName = @"自定义脚本";
    script.sceneName = @"气味王国";
    script.state =  ScriptIsNormal;
    script.type =  ScriptIsRelativeTime;
    script.isLoop = NO;
    
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
    
    __weak typeof(self) weakSelf = self;
    [popoverView setSelectRowAtIndex:^(NSInteger index) {
        switch (index) {
            case 0:
            {
                if ([[BluetoothMacManager defaultManager] isConnected]) {
                    if ([weakSelf.delegate respondsToSelector:@selector(refreshBluetoothData)]) {
                        [weakSelf.delegate refreshBluetoothData];
                    }
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
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        id connectedPeripheral = [[BluetoothMacManager defaultManager] returnConnectedPeripheral];
        if ([connectedPeripheral isEqual:peripheral]) {
            return;
        }
    }
    [[BluetoothProcessManager defatultManager] connectToBluetooth:name WithPeripheral:peripheral];
}
@end
