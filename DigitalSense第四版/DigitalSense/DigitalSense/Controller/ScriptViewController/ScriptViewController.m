//
//  ScriptViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptViewController.h"
#import "ScriptTableViewCell.h"
#import "XTLoveHeartView.h"
#import "RelativeTimeScript.h"
#import "AbsoluteTimeScript.h"
#import "ScriptViewModel.h"

#import "ScriptExecuteManager.h"
#import "BluetoothProcessManager.h"
#import "ScriptPlayDetailsViewController.h"

static NSString *cellIdentify = @"ScriptTableViewCellIdentify";
@interface ScriptViewController ()<ScriptTableViewCellProtocol,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *scriptList;
    Script *currentPlayScript;
    ScriptPlayDetailsViewController *scriptPlayDetailsVC;
    ScriptViewModel *scriptViewModel;
    
    NSString *currentMacAddress;
    
    RACDisposable *playScriptDisposable;
    RACDisposable *playOverAllScriptDisposable;
    RACDisposable *playProgressSecondDisposable;
    RACDisposable *macAddressDisposable;
    RACDisposable *sendScriptCommandDisposable;
    
    NSTimer *heartTimer;
}
@property(nonatomic, strong) IBOutlet UIView *bottomView;
@property(nonatomic, strong) IBOutlet UILabel *lblSmellName;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UILabel *lblTitle;
@end

@implementation ScriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //适配TitleLabel的字体大小
    [UIDevice adaptUILabelTextFont:self.lblTitle WithIphone5FontSize:17.0f IsBold:YES];
    
    scriptList = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ScriptTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentify];
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    [self.tableView setTableFooterView:[UIView new]];
    
    scriptViewModel = [[ScriptViewModel alloc] init];
    
    if (currentMacAddress) {
        [self requestScriptInfoWithMacAddress:currentMacAddress];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scriptStateComfirmed:) name:ScriptStateComfirmed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothPowerOff:) name:OnCallbackBluetoothPowerOff object:nil];
    [self registeNotifications];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self disposeAllSignal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma -mark private Functions
-(void)setMacAddress:(NSString *)macAddr
{
    currentMacAddress = macAddr;
}

-(void)setCurrentScript:(Script *)script
{
    currentPlayScript = script;
}

-(void)requestScriptInfoWithMacAddress:(NSString *)macAddress
{
    if (macAddress) {
        [AppUtils showHudProgress:@"加载中..." ForView:self.view];
        [[scriptViewModel requestScriptInfoWithMacAddress:macAddress] subscribeNext:^(id x) {
            NSDictionary *resultDic = (NSDictionary *)x;
            if (resultDic) {
                NSArray *dataArr = [resultDic objectForKey:@"data"];
                if (dataArr && dataArr.count > 0) {
                    [scriptList removeAllObjects];
                    NSMutableArray *absoluteScriptList = [NSMutableArray array];
                    for (NSDictionary *dic in dataArr) {
                        ScriptType type = (ScriptType)[[dic objectForKey:@"trigger"] integerValue];
                        if (type == ScriptIsRelativeTime) {
                            Script *relativeTimeScript = [[RelativeTimeScript alloc] initWithDictionary:dic];
                            [scriptList addObject:relativeTimeScript];
                        }
                        
                        if (type == ScriptIsAbsoluteTime) {
                            Script *absoluteTimeScript = [[AbsoluteTimeScript alloc] initWithDictionary:dic];
                            [scriptList addObject:absoluteTimeScript];
                            [absoluteScriptList addObject:absoluteTimeScript];
                        }
                    }
                    [[ScriptExecuteManager defaultManager] executeAbsoluteTimeScript:absoluteScriptList];
                    [self.tableView reloadData];
                }else{
                    [AppUtils showInfo:@"无脚本记录"];
                }
            }
        } error:^(NSError *error) {
            
        } completed:^{
            [AppUtils hidenHudProgressForView:self.view];
        }];
    }
}

-(Script *)searchPlayingScriptInList:(NSArray *)list
{
    if (list == nil) {
        return nil;
    }
    
    Script *script = nil;
    for (Script *sc in list) {
        if (sc.state == ScriptIsPlaying) {
            script = sc;
            break;
        }
    }
    return script;
}

-(void)generateHeartView
{
    XTLoveHeartView *heart = [[XTLoveHeartView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.view addSubview:heart];
    [self.view bringSubviewToFront:heart];
    CGPoint fountainSource = CGPointMake(self.view.frame.size.width / 2, self.view.bounds.size.height - self.bottomView.frame.size.height);
    heart.center = fountainSource;
    [heart animateInView:self.view];
}
#pragma -mark Notificaiton
-(void)scriptStateComfirmed:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    [AppUtils showInfo:@"蓝牙未开启"];
    [[ScriptExecuteManager defaultManager] cancelAllScripts];
}

-(void)registeNotifications
{
    playScriptDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayScriptNotification object:nil] subscribeNext:^(id x) {
        id obj = [x object];
        if ([obj isKindOfClass:[Script class]]) {
            Script *script = (Script *)obj;
            [self setCurrentScript:script];
        }
    }];
    
    playOverAllScriptDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayOverAllScriptsNotification object:nil] subscribeNext:^(id x) {
        [self setCurrentScript:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    }];
    
    playProgressSecondDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayProgressSecondNotification object:nil] subscribeNext:^(id x) {
        if (currentPlayScript == nil) {
            return;
        }
        if (![scriptList containsObject:currentPlayScript]) {
            return;
        }
        
        if (currentPlayScript.state != ScriptIsPlaying) {
            currentPlayScript = [self searchPlayingScriptInList:scriptList];
            if (currentPlayScript == nil) {
                return;
            }
        }
        
        ScriptTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[scriptList indexOfObject:currentPlayScript] inSection:0]];
        if (cell == nil) {
            return;
        }
        id obj = [x object];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *seconds = (NSNumber *)obj;
            [cell setProgressSecond:[seconds integerValue]];
        }
    }];
    
    macAddressDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:BluetoothMacAddressNotify object:nil] subscribeNext:^(id x) {
        id obj = [x object];
        if (obj) {
            [self requestScriptInfoWithMacAddress:obj];
        }
    }];
    
    sendScriptCommandDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SendScriptCommandNotification object:nil] subscribeNext:^(id x) {
        id obj = [x object];
        if([obj isKindOfClass:[ScriptCommand class]]){
            ScriptCommand *command = (ScriptCommand *)obj;
            [_lblSmellName setText:command.smellName];
            
            heartTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(generateHeartView) userInfo:nil repeats:YES];
            [heartTimer fire];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(command.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (heartTimer) {
                    if ([heartTimer isValid]) {
                        [heartTimer invalidate];
                    }
                }
            });
        }
    }];
}

-(void)disposeAllSignal
{
    if (playScriptDisposable) {
        if (![playScriptDisposable isDisposed]) {
            [playScriptDisposable dispose];
            playScriptDisposable = nil;
        }
    }
    
    if (playOverAllScriptDisposable) {
        if (![playOverAllScriptDisposable isDisposed]) {
            [playOverAllScriptDisposable dispose];
            playOverAllScriptDisposable = nil;
        }
    }
    
    if (playProgressSecondDisposable) {
        if (![playProgressSecondDisposable isDisposed]) {
            [playProgressSecondDisposable dispose];
            playProgressSecondDisposable = nil;
        }
    }
    
    if (macAddressDisposable) {
        if (![macAddressDisposable isDisposed]) {
            [macAddressDisposable dispose];
            macAddressDisposable = nil;
        }
    }
    
    if (sendScriptCommandDisposable) {
        if (![sendScriptCommandDisposable isDisposed]) {
            [sendScriptCommandDisposable dispose];
            sendScriptCommandDisposable = nil;
        }
    }
}


#pragma -mark ButtonEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickRefreshBtn:(id)sender
{
    if (currentPlayScript && currentPlayScript.state == ScriptIsPlaying) {
        [AppUtils showInfo:@"当前有脚本正在播放中"];
        return;
    }
    [self requestScriptInfoWithMacAddress:currentMacAddress];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    return scriptList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    cell.delagate = self;
    if (cell) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                Script *script = [scriptList objectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setupCellWithScript:script];
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
    Script *script = [scriptList objectAtIndex:indexPath.row];
    if (script.type == ScriptIsRelativeTime) {
        if (script.state == ScriptIsPlaying) {
            if (scriptPlayDetailsVC == nil) {
                scriptPlayDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScriptPlayDetailsViewIdentify"];
            }
            [scriptPlayDetailsVC setCurrentScript:script];
            [self.navigationController pushViewController:scriptPlayDetailsVC animated:YES];
        }
    }
}
#pragma -mark ScriptTableViewCellProtocol
-(void)playScript:(Script *)script
{
    if (script) {
        if (script.type == ScriptIsRelativeTime) {
            [[ScriptExecuteManager defaultManager] executeRelativeTimeScript:script];
        }
    }
}

-(void)cancelInline:(Script *)script
{
    if (script) {
        if (script.type == ScriptIsRelativeTime) {
            [[ScriptExecuteManager defaultManager] cancelExecuteRelativeTimeScript:script];
        }

    }
}
@end
