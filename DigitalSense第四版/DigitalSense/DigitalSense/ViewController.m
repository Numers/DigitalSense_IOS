//
//  ViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/27.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ViewController.h"
#import "LewReorderableLayout.h"
#import "UIImageView+Webcache.h"
#import "Fruit.h"

#import "AppUtils.h"
#import "BluetoothMacManager.h"
#import "IflyRecognizerManager.h"
#import "IFlySpeechSynthesizerManager.h"

#import "ViewModel.h"

#define SpeakDelay 0.5f
#define SmellEmitDuration 15
#define CellMargin 0.0f
#define CellItemCount 3
#define CloseTag 0

#define LocalSmellRFIDOrderFile @"LocalSmellRFIDOrder.plist" //本地气味的rfid展示顺序
#define cellIdentifier @"LewCollectionViewCell"

@interface ViewController ()<LewReorderableLayoutDelegate, LewReorderableLayoutDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSNumber *selectTag;
    NSTimer *smellEmitTimer;
    NSInteger countTime;
    
    NSArray *rfIdOrderList;
    NSMutableArray *bottleInfoList;
    BOOL hasNewFruit;
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
    // Do any additional setup after loading the view, typically from a nib
    UIImage * backgroundImg = [UIImage imageNamed:@"TabBarBackgroundImage"];
    _tabBarView.layer.contents = (id)backgroundImg.CGImage;
    [_btnVoice setImage:[UIImage imageNamed:@"VoiceBtn_Normal"] forState:UIControlStateNormal];
    [_btnVoice setImage:[UIImage imageNamed:@"VoiceBtn_Hightlight"] forState:UIControlStateHighlighted];
    
    LewReorderableLayout *layout = (LewReorderableLayout *)[_collectionView collectionViewLayout];
    layout.delegate = self;
    layout.dataSource = self;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@",[documentPaths objectAtIndex:0],LocalSmellRFIDOrderFile];
    rfIdOrderList = [NSArray arrayWithContentsOfFile:path];
    
    bottleInfoList = [NSMutableArray array];
    
    hasNewFruit = NO;
    _fruitsList = [NSMutableArray array];
    
    /*********************添加假数据**********************/
    Fruit *fruit1 = [[Fruit alloc] init];
    fruit1.fruitName = @"苹果";
    fruit1.fruitImage = @"AppleImage_Normal";
    fruit1.fruitRFID = 0xFFFFFFFF;
    [self addFruitByOrder:fruit1];
    
    Fruit *fruit2 = [[Fruit alloc] init];
    fruit2.fruitName = @"椰子";
    fruit2.fruitImage = @"CoconutImage_Normal";
    fruit2.fruitRFID = 0x8765e394;
    [self addFruitByOrder:fruit2];
    
    Fruit *fruit3 = [[Fruit alloc] init];
    fruit3.fruitName = @"猕猴桃";
    fruit3.fruitImage = @"KiwifruitImage_Normal";
    fruit3.fruitRFID = 0x8765e393;
    [self addFruitByOrder:fruit3];
    
    Fruit *fruit4 = [[Fruit alloc] init];
    fruit4.fruitName = @"芒果";
    fruit4.fruitImage = @"MangoImage_Normal";
    fruit4.fruitRFID = 0x8765e392;
    [self addFruitByOrder:fruit4];
    
    Fruit *fruit5 = [[Fruit alloc] init];
    fruit5.fruitName = @"橙子";
    fruit5.fruitImage = @"OrangeImage_Normal";
    fruit5.fruitRFID = 0x8765e391;
    [self addFruitByOrder:fruit5];
    /****************************************************/
    
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
                    [bottleInfoList addObject:dic];
//                    Fruit *fruit = [dic objectForKey:BottleKey];
//                    [self addFruitByOrder:fruit];
                }];
            }
                break;
            case EmitSmell:
            {
                [[self.viewModel emitSmellReturn:byte] subscribeNext:^(id x) {
                    NSDictionary *dic = (NSDictionary *)x;
                    NSNumber *rfId = [dic objectForKey:EmitSmellNoKey];
                    NSNumber *duration = [dic objectForKey:EmitSmellDurationKey];
                    if ([duration integerValue] == 0) {
                        [self setSelectTag:CloseTag];
                        if (smellEmitTimer) {
                            if ([smellEmitTimer isValid]) {
                                [smellEmitTimer invalidate];
                                smellEmitTimer = nil;
                            }
                        }
                    }else{
                        [self setSelectTag:[rfId integerValue]];
                        [self startTimerWithDuration:[duration intValue]];
                    }
                }];
            }
                break;
            case BottleInfoCompletely:
            {
                [[self.viewModel getBottleInfoCompletelyReturn:byte WithBottleInfoList:bottleInfoList] subscribeNext:^(id x) {
                    //处理http返回responseObject
                    NSDictionary *result = (NSDictionary *)x;
                    if (result) {
                        NSArray *dataArr = [result objectForKey:@"data"];
                        if (dataArr) {
                            for (NSDictionary *dic in dataArr) {
                                Fruit *fruit = [[Fruit alloc] init];
                                fruit.fruitName = [dic objectForKey:@"cn_name"];
                                fruit.fruitEnName = [dic objectForKey:@"en_name"];
                                fruit.fruitImage = [dic objectForKey:@"icon"];
                                NSString *tempRFID = [dic objectForKey:@"rfid"];
                                if (tempRFID.length % 2 == 0) {
                                    NSScanner *scanner = [NSScanner scannerWithString:tempRFID];
                                    unsigned long long cardNo;
                                    [scanner scanHexLongLong:&cardNo];
                                    fruit.fruitRFID = cardNo;
                                    [self addFruitByOrder:fruit];
                                }
                            }
                            [_collectionView reloadData];
                        }
                    }
                }];
            }
                break;
            default:
                break;
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
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandMacAddress];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandOpenDeviceTime];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandCloseDeviceTime];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandBottleInfo];
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandWakeUpDevice];
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

/**
 *  @author RenRenFenQi, 16-06-03 13:06:34
 *
 *  设置当前发散气味的标识
 *
 *  @param tag 气味标识
 */
-(void)setSelectTag:(NSInteger)tag
{
    selectTag = [NSNumber numberWithInteger:tag];
    [_collectionView reloadData];
}

/**
 *  @author RenRenFenQi, 16-06-03 13:06:58
 *
 *  查找气味对象
 *
 *  @param rfId 气味对应的瓶子RFID
 *
 *  @return 气味对象
 */
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

/**
 *  @author RenRenFenQi, 16-06-03 13:06:24
 *
 *  开启气味发散计时
 *
 *  @param duration 气味发散时间间隔
 */
-(void)startTimerWithDuration:(int)duration
{
    if (smellEmitTimer) {
        if ([smellEmitTimer isValid]) {
            [smellEmitTimer invalidate];
            smellEmitTimer = nil;
        }
    }
    
    countTime = -1;
    smellEmitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
}

-(void)countdown
{
    countTime ++;
    if (countTime <= SmellEmitDuration) {
        //计时气味发散时间
        
    }else{
        if (smellEmitTimer) {
            if ([smellEmitTimer isValid]) {
                [smellEmitTimer invalidate];
                smellEmitTimer = nil;
            }
        }
        [self setSelectTag:CloseTag];
    }
}

/**
 *  @author RenRenFenQi, 16-06-03 13:06:19
 *
 *  往蓝牙写入开启气味命令
 *
 *  @param rfId     气味对应的瓶子RFID
 *  @param interval 发散气味的时间间隔 0表示关闭
 */
-(void)writeDataWithRFID:(NSInteger)rfId WithTimeInterval:(int)interval
{
    [[BluetoothMacManager defaultManager] writeCharacteristicWithRFID:rfId WithTimeInterval:interval];
}

/**
 *  @author RenRenFenQi, 16-06-03 13:06:38
 *
 *  添加一个气味，从气味顺序列表中搜索
 *
 *  @param fruit 气味对象
 */
-(void)addFruitByOrder:(Fruit *)fruit
{
    if (rfIdOrderList) {
        NSInteger index = [rfIdOrderList indexOfObject:[NSNumber numberWithInteger:fruit.fruitRFID]];
        if (index >= 0 && index < rfIdOrderList.count) {
            fruit.tag = index;
        }else{
            hasNewFruit = YES;
            fruit.tag = rfIdOrderList.count;
        }
        [_fruitsList addObject:fruit];
    }else{
        hasNewFruit = YES;
        fruit.tag = rfIdOrderList.count;
        [_fruitsList addObject:fruit];
    }
    
    [_fruitsList sortUsingComparator:^NSComparisonResult(Fruit*  _Nonnull obj1, Fruit*  _Nonnull obj2) {
        return obj1.tag > obj2.tag ? NSOrderedDescending:NSOrderedAscending;
    }];
//    [_collectionView reloadData];
}

/**
 *  @author RenRenFenQi, 16-06-03 13:06:08
 *
 *  保存当前气味列表的RFID顺序
 */
-(void)saveOrderFile
{
    NSMutableArray *orderList = [NSMutableArray array];
    for (Fruit *fruit in _fruitsList) {
        NSNumber *RFID = [NSNumber numberWithInteger:fruit.fruitRFID];
        [orderList addObject:RFID];
    }
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@",[documentPaths objectAtIndex:0],LocalSmellRFIDOrderFile];
    [orderList writeToFile:path atomically:YES];
}

/**
 *  @author RenRenFenQi, 16-06-03 13:06:24
 *
 *  组织上传语音语法
 *
 *  @return 语音语法
 */
-(NSString *)generateGrammarContent
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:@"#ABNF 1.0 UTF-8;\nlanguage zh-CN; \nmode voice;\n\nroot $main;\n$main = $place1;\n$place1 = "];
    for (Fruit *fruit in _fruitsList) {
        [content appendString:fruit.fruitName];
        [content appendString:@"|"];
    }
    [content appendString:@"关|关闭;"];
    return content;
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
    
    NSString *grammarContent = nil;
    if (hasNewFruit) {
        hasNewFruit = NO;
        grammarContent = [self generateGrammarContent];
    }
    
    [[IflyRecognizerManager defaultManager] startRecognizer:grammarContent Callback:^(NSString *result) {
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
                    
                    if ([highMatch hasPrefix:@"nomatch"]) {
                        //指令未识别
                        [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:NO Callback:^(BOOL completely) {
                            
                        }];
                    }else if([highMatch isEqualToString:@"关闭"] || [highMatch isEqualToString:@"关"]){
                        if ([selectTag integerValue] != CloseTag) {
                            [self writeDataWithRFID:[selectTag integerValue] WithTimeInterval:0];
                        }
                    }else{
                        Fruit *matchFruit = [self.viewModel matchFruitName:highMatch InList:_fruitsList];
                        if (matchFruit) {
                            [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                                if (completely) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        //延迟后需要做的操作
                                        [self writeDataWithRFID:matchFruit.fruitRFID WithTimeInterval:SmellEmitDuration];
                                    });
                                }
                            }];
                        }else{
                            //指令未识别
                            [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:NO Callback:^(BOOL completely) {
                                
                            }];
                        }
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
//    [backImageView sd_setImageWithURL:[NSURL URLWithString:fruit.fruitImage] placeholderImage:[UIImage imageNamed:@"FuitPlaceHolderImage_Normal"]];
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
//        CGFloat perPieceWidth = floor(screenWidth / (CellItemCount * 1.0f) - ((CellMargin / (CellItemCount * 1.0f)) * (CellItemCount - 1)));
        CGFloat perPieceWidth = screenWidth / (CellItemCount * 1.0f) - ((CellMargin / (CellItemCount * 1.0f)) * (CellItemCount - 1));
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
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
    Fruit *fruit = [_fruitsList objectAtIndex:fromIndexPath.item];
    [_fruitsList removeObjectAtIndex:fromIndexPath.item];
    [_fruitsList insertObject:fruit atIndex:toIndexPath.item];
    
    [self saveOrderFile];
}

#pragma -mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Fruit *selectFruit = [_fruitsList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",indexPath.item,selectFruit.fruitName);
    if (selectFruit.fruitRFID == [selectTag integerValue]) {
        [self writeDataWithRFID:selectFruit.fruitRFID WithTimeInterval:0];
    }else{
        [self writeDataWithRFID:selectFruit.fruitRFID WithTimeInterval:SmellEmitDuration];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",indexPath.item);
}
@end
