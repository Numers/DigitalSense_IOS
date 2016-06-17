//
//  ScriptViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptViewController.h"
#import "ScriptTableViewCell.h"
#import "RelativeTimeScript.h"
#import "AbsoluteTimeScript.h"
#import "ScriptViewModel.h"

#import "ScriptExecuteManager.h"
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
}
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ScriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scriptList = [NSMutableArray array];
    
    /**************************假数据***************************/
    Script *script = [[Script alloc] init];
    script.scriptId = @"1";
    script.scriptName = @"魔兽1";
    script.scriptTime = 10;
    script.state = ScriptIsNormal;
    script.type = ScriptIsRelativeTime;
    [scriptList addObject:script];
    
    Script *script1 = [[Script alloc] init];
    script1.scriptId = @"1";
    script1.scriptName = @"魔兽2";
    script1.scriptTime = 75;
    
    script1.state = ScriptIsNormal;
    script1.type = ScriptIsRelativeTime;
    [scriptList addObject:script1];
    Script *script2 = [[Script alloc] init];
    script2.scriptId = @"1";
    script2.scriptName = @"魔兽3";
    script2.scriptTime = 50;
    script2.state = ScriptIsNormal;
    script2.type = ScriptIsRelativeTime;
    [scriptList addObject:script2];
    
    Script *script3 = [[Script alloc] init];
    script3.scriptId = @"1";
    script3.scriptName = @"魔兽4";
    script3.scriptTime = 13;
    script3.state = ScriptIsNormal;
    script3.type = ScriptIsRelativeTime;
    [scriptList addObject:script3];
    
    Script *script4 = [[Script alloc] init];
    script4.scriptId = @"1";
    script4.scriptName = @"魔兽5";
    script4.scriptTime = 14;
    script4.state = ScriptIsNormal;
    script4.type = ScriptIsRelativeTime;
    [scriptList addObject:script4];
    /************************************************************/
    
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
        [[scriptViewModel requestScriptInfoWithMacAddress:macAddress] subscribeNext:^(id x) {
            NSDictionary *resultDic = (NSDictionary *)x;
            if (resultDic) {
                NSArray *dataArr = [resultDic objectForKey:@"data"];
                if (dataArr && dataArr.count > 0) {
                    [scriptList removeAllObjects];
                    for (NSDictionary *dic in dataArr) {
                        ScriptType type = (ScriptType)[[dic objectForKey:@"trigger"] integerValue];
                        if (type == ScriptIsRelativeTime) {
                            Script *relativeTimeScript = [[RelativeTimeScript alloc] initWithDictionary:dic];
                            [scriptList addObject:relativeTimeScript];
                        }
                        
                        if (type == ScriptIsAbsoluteTime) {
                            Script *absoluteTimeScript = [[AbsoluteTimeScript alloc] initWithDictionary:dic];
                            [scriptList addObject:absoluteTimeScript];
                        }
                    }
                    [self.tableView reloadData];
                }
            }
        }];
    }
}

#pragma -mark Notificaiton
-(void)scriptStateComfirmed:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    }];
    
    playProgressSecondDisposable = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayProgressSecondNotification object:nil] subscribeNext:^(id x) {
        if (currentPlayScript == nil) {
            return;
        }
        if (![scriptList containsObject:currentPlayScript]) {
            return;
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
        [self requestScriptInfoWithMacAddress:x];
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
}


#pragma -mark ButtonEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
