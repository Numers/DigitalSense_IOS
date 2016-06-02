//
//  ViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/27.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ViewController.h"
#import "LewReorderableLayout.h"
#import "Fruit.h"

#import "AppUtils.h"
#import "BluetoothMacManager.h"
#import "IflyRecognizerManager.h"
#import "IFlySpeechSynthesizerManager.h"

#import "ViewModel.h"

#define SpeakDelay 0.5f
#define CellMargin 0.0f
#define CellItemCount 3
#define CloseTag 0

#define cellIdentifier @"LewCollectionViewCell"

@interface ViewController ()<LewReorderableLayoutDelegate, LewReorderableLayoutDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSNumber *selectTag;
}
@property (nonatomic, weak)IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UILabel *lblTitle;
@property(nonatomic, strong) IBOutlet UIView *tabBarView;
@property(nonatomic, strong) IBOutlet UIButton *btnVoice;

@property(nonatomic, strong) NSMutableArray *fruitsList;
@property(nonatomic, strong) ViewModel *viewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage * backgroundImg = [UIImage imageNamed:@"TabBarBackgroundImage"];
    _tabBarView.layer.contents = (id)backgroundImg.CGImage;
    [_btnVoice setImage:[UIImage imageNamed:@"VoiceBtn_Normal"] forState:UIControlStateNormal];
    [_btnVoice setImage:[UIImage imageNamed:@"VoiceBtn_Hightlight"] forState:UIControlStateHighlighted];
    
    LewReorderableLayout *layout = (LewReorderableLayout *)[_collectionView collectionViewLayout];
    layout.delegate = self;
    layout.dataSource = self;
    
    _fruitsList = [NSMutableArray array];
    Fruit *fruit1 = [[Fruit alloc] init];
    fruit1.fruitName = @"苹果";
    fruit1.fruitImage = @"AppleImage_Normal";
    fruit1.fruitRFID = 0xFFFFFFFF;
    [_fruitsList addObject:fruit1];
    
    Fruit *fruit2 = [[Fruit alloc] init];
    fruit2.fruitName = @"椰子";
    fruit2.fruitImage = @"CoconutImage_Normal";
    fruit2.fruitRFID = 0x8765e394;
    [_fruitsList addObject:fruit2];
    
    Fruit *fruit3 = [[Fruit alloc] init];
    fruit3.fruitName = @"猕猴桃";
    fruit3.fruitImage = @"KiwifruitImage_Normal";
    fruit3.fruitRFID = 0x8765e394;
    [_fruitsList addObject:fruit3];
    
    Fruit *fruit4 = [[Fruit alloc] init];
    fruit4.fruitName = @"芒果";
    fruit4.fruitImage = @"MangoImage_Normal";
    fruit4.fruitRFID = 0x8765e394;
    [_fruitsList addObject:fruit4];
    
    Fruit *fruit5 = [[Fruit alloc] init];
    fruit5.fruitName = @"橙子";
    fruit5.fruitImage = @"OrangeImage_Normal";
    fruit5.fruitRFID = 0x8765e394;
    [_fruitsList addObject:fruit5];
    
    selectTag = [NSNumber numberWithInteger:CloseTag];
    
    [[BluetoothMacManager defaultManager] startBluetoothDevice];
    
    self.viewModel = [[ViewModel alloc] init];
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
    if (data.length > 0) {
        int code = (int)byte[0];
        CommandType type = (CommandType)code;
        //返回data解析出来的对应响应指令
        switch (type) {
            case MacAddress:
            {
                [[self.viewModel getMacAddressReturn:byte] subscribeNext:^(id x) {
                    
                }];
            }
                break;
            case OpenDeviceTime:
            {
                [[self.viewModel getOpenDeviceTimeReturn:byte] subscribeNext:^(id x) {
                    
                }];
            }
                break;
            case CloseDeviceTime:
            {
                [[self.viewModel getCloseDeviceTimeReturn:byte] subscribeNext:^(id x) {
                    
                }];
            }
                break;
            case WakeUpDevice:
            {
                [[self.viewModel wakeUpDeviceReturn:byte] subscribeNext:^(id x) {
                    if ([x boolValue]) {
                        //唤醒后的界面操作
                    }
                }];
            }
                break;
            case SleepDevice:
            {
                [[self.viewModel sleepDeviceReturn:byte] subscribeNext:^(id x) {
                    if ([x boolValue]) {
                        //休眠后的界面操作
                    }
                }];
            }
                break;
            case BottleInfo:
            {
                [[self.viewModel getBottleInfoReturn:byte] subscribeNext:^(id x) {
                    NSDictionary *dic = (NSDictionary *)x;
                    Fruit *fruit = [dic objectForKey:BottleKey];
                    [_fruitsList addObject:fruit];
                    [_collectionView reloadData];
                }];
            }
                break;
            case EmitSmell:
            {
                [[self.viewModel emitSmellReturn:byte] subscribeNext:^(id x) {
                    NSDictionary *dic = (NSDictionary *)x;
                    NSNumber *rfId = [dic objectForKey:EmitSmellNoKey];
                    NSNumber *duration = [dic objectForKey:EmitSmellDuration];
                    if ([duration integerValue] == 0) {
                        [self setSelectTag:CloseTag];
                    }else{
                        [self setSelectTag:[rfId integerValue]];
                    }
                }];
            }
                break;
            default:
                break;
        }    }
}

#pragma -mark private function
//连接智能设备蓝牙
-(void)connectToBluetooth
{
    [self.lblTitle setText:@"连接中..."];
    [[BluetoothMacManager defaultManager] startScanBluetoothDevice:ConnectToDevice callBack:^(BOOL completely, CallbackType backType, id obj, ConnectType connectType) {
        if (completely) {
            [self.lblTitle setText:@"设备已连接"];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandMacAddress];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandOpenDeviceTime];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandCloseDeviceTime];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandBottleInfo];
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
    }];
}

//关闭蓝牙连接
-(void)disConnectBluetooth:(NSString *)description
{
    [self.lblTitle setText:description];
    [[BluetoothMacManager defaultManager] stopBluetoothDevice];
}

-(void)setSelectTag:(NSInteger)tag
{
    selectTag = [NSNumber numberWithInteger:tag];
    [_collectionView reloadData];
}

-(Fruit *)searchFruitByRFID:(NSInteger)rfId
{
    Fruit *fruit = nil;
    for (Fruit *f in _fruitsList) {
        if (f.fruitRFID == rfId) {
            fruit = f;
            break;
        }
    }
    return fruit;
}

#pragma -mark ButtonClickEvent
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
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellMango];
//                                    [self setSelectTag:1 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"苹果"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellApple];
//                                    [self setSelectTag:2 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"猕猴桃"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellKiwifruit];
//                                    [self setSelectTag:3 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"橘子"] || [highMatch isEqualToString:@"橙子"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellOrange];
//                                    [self setSelectTag:4 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"椰子"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellCoconut];
//                                    [self setSelectTag:5 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"水蜜桃"] || [highMatch isEqualToString:@"桃子"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPeach];
//                                    [self setSelectTag:6 voice:YES];
                                });
                            }
                        }];
                    }
                    
                    if ([highMatch isEqualToString:@"菠萝"] || [highMatch isEqualToString:@"凤梨"]) {
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                            if (completely) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    //延迟后需要做的操作
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellPineapple];
//                                    [self setSelectTag:7 voice:YES];
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
//                                    [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandSmellClose];
//                                    [self setSelectTag:CloseTag voice:YES];
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

#pragma mark - LewReorderableLayoutDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView *backImageView = [cell viewWithTag:1];
    UIView *frontView = [cell viewWithTag:3];
    
    Fruit *fruit = [_fruitsList objectAtIndex:indexPath.item];
    [backImageView setImage:[UIImage imageNamed:fruit.fruitImage]];
    if ([selectTag integerValue] == fruit.fruitRFID) {
        [frontView setHidden:NO];
    }else{
        [frontView setHidden:YES];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _fruitsList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (CellItemCount >= 1) {
//        CGFloat perPieceWidth = floor(screenWidth / CellItemCount - ((CellMargin / CellItemCount) * (CellItemCount - 1)));
        CGFloat perPieceWidth = screenWidth / CellItemCount - ((CellMargin / CellItemCount) * (CellItemCount - 1));
        return CGSizeMake(perPieceWidth, perPieceWidth * 480.0f / 414.0f);
    }
    return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return CellMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return CellMargin;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, CellMargin, 0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{

//    if (indexPath.section == 1 && indexPath.row == _imagesForSection_1.count-1) {
//        return NO;
//    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
//    if (fromIndexPath.section != toIndexPath.section && toIndexPath.row == _imagesForSection_1.count) {
//        return NO;
//    }else if (fromIndexPath.section == toIndexPath.section && toIndexPath.row == _imagesForSection_1.count-1){
//        return NO;
//    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
//    UIImage *image = nil;
//    if (fromIndexPath.section == 0) {
//        image = _imagesForSection_0[fromIndexPath.item];
//        [_imagesForSection_0 removeObjectAtIndex:fromIndexPath.item];
//    }else{
//        image = _imagesForSection_1[fromIndexPath.item];
//        [_imagesForSection_1 removeObjectAtIndex:fromIndexPath.item];
//    }
//    
//    if (toIndexPath.section == 0) {
//        [_imagesForSection_0 insertObject:image atIndex:toIndexPath.item];
//    }else{
//        [_imagesForSection_1 insertObject:image atIndex:toIndexPath.item];
//    }
    
    Fruit *fruit = [_fruitsList objectAtIndex:fromIndexPath.item];
    [_fruitsList removeObjectAtIndex:fromIndexPath.item];
    [_fruitsList insertObject:fruit atIndex:toIndexPath.item];
}

#pragma -mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Fruit *selectFruit = [_fruitsList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",indexPath.item,selectFruit.fruitName);
    
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    UIView *frontView = [cell viewWithTag:3];
//    [frontView setHidden:NO];
    if (selectFruit.fruitRFID == [selectTag integerValue]) {
        [[BluetoothMacManager defaultManager] writeCharacteristicWithRFID:selectFruit.fruitRFID WithTimeInterval:0];
    }else{
        [[BluetoothMacManager defaultManager] writeCharacteristicWithRFID:selectFruit.fruitRFID WithTimeInterval:15];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",indexPath.item);
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    UIView *frontView = [cell viewWithTag:3];
//    [frontView setHidden:YES];
}
@end
