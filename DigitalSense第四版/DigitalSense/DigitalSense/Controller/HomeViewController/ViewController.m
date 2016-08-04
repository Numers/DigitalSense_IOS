//
//  ViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/27.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ViewController.h"
#import "ScriptViewController.h"
#import "ScanBluetoothDeviceViewController.h"
#import "ScriptOperationViewController.h"
#import "LewReorderableLayout.h"
#import "UIImageView+Webcache.h"
#import "Fruit.h"
#import "SmellSkin.h"

#import "AppUtils.h"
#import "BluetoothMacManager.h"
#import "BluetoothProcessManager.h"
#import "IflyRecognizerManager.h"
#import "IFlySpeechSynthesizerManager.h"
#import "ScriptExecuteManager.h"
#import "SFruitInfoDB.h"

#import "ViewModel.h"

#import "FloatView/FloatView.h"
#import "PopoverView.h"
#import "ComboxMenuView.h"
#import "UINavigationController+WXSTransition.h"

#define SpeakDelay 0.5f
#define SmellEmitDuration 8
#define CellMargin 0.5f
#define CellItemCount 3
#define CloseTag @"0"

#define LocalSmellRFIDOrderFile @"LocalSmellRFIDOrder.plist" //本地气味的rfid展示顺序
#define cellIdentifier @"LewCollectionViewCell"

@interface ViewController ()<LewReorderableLayoutDelegate, LewReorderableLayoutDataSource,UICollectionViewDelegate,UICollectionViewDataSource,ScanBluetoothDeviceViewProtocol,FloatViewProtocol,ComboxMenuViewProtocol,ScriptOperationViewProtocol>
{
    NSString *selectTag;
    NSTimer *smellEmitTimer;
    NSInteger countTime;
    
    NSArray *rfIdOrderList;
    NSMutableArray *bottleInfoList;
    BOOL hasNewFruit;
    
    ScriptViewController *scriptVC;
    
    FloatView *floatView;
    PopoverView *popoverView;
    NSArray *popoverTitle;
    
    ComboxMenuView *comboxView;
    BOOL isScanning;
    
    NSTimer *testTimer;
}
@property (nonatomic, weak)IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UIView *tabBarView;
@property(nonatomic, strong) IBOutlet UIButton *btnVoice;
@property(nonatomic, strong) IBOutlet UIButton *btnSelectDevice;

@property(nonatomic, strong) NSMutableArray *fruitsList;
@property(nonatomic, strong) ViewModel *viewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nil
    [self.navigationController setNavigationBarHidden:YES];
    //适配SelectDeviceButton的字体大小
    [UIDevice adaptUIButtonTitleFont:_btnSelectDevice WithIphone5FontSize:17.0f IsBold:YES];
    
    //popoverView显示的title
    popoverTitle = @[@"脚本列表"];
    //添加浮动的按钮
    floatView = [[FloatView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    floatView.delegate = self;
    [floatView.layer setCornerRadius:floatView.frame.size.width / 2.0f];
    [floatView setCenter:CGPointMake(self.view.frame.size.width - floatView.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)];
    [self.view addSubview:floatView];
    [self.view bringSubviewToFront:floatView];
    
    UIImageView *floatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, floatView.frame.size.width, floatView.frame.size.height)];
    [floatImageView setImage:[UIImage imageNamed:@"FloatImage"]];
    [floatView addSubview:floatImageView];
    
    
    //获取本地缓存的皮肤
    SmellSkin *skin = [SmellSkin getLocalSkin];
    [self renderingSkinWithSmellSkin:skin];
    
    
    LewReorderableLayout *layout = (LewReorderableLayout *)[_collectionView collectionViewLayout];
    layout.delegate = self;
    layout.dataSource = self;
    
    self.viewModel = [[ViewModel alloc] init];
    [self requestSmellSkinWithSkinId:skin.skinId];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliveryData:) name:BluetoothDeliveryDataNotify object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartScanBluetooth:) name:OnStartScanBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothPowerOff:) name:OnCallbackBluetoothPowerOff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackScanBluetoothTimeout:) name:OnCallbackScanBluetoothTimeout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothDisconnected:) name:OnCallbackBluetoothDisconnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartConnectToBluetooth:) name:OnStartConnectToBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothSuccessfully:) name:OnCallbackConnectToBluetoothSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothTimeout:) name:OnCallbackConnectToBluetoothTimeout object:nil];
    
    [[BluetoothProcessManager defatultManager] registerNotify];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[IflyRecognizerManager defaultManager] stopRecongnizer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Notification
-(void)onStartScanBluetooth:(NSNotification *)notify
{
    [self setIsScanning:YES];
    [self performSelectorInBackground:@selector(syncComboxMenuData) withObject:nil];
    if (testTimer) {
        if ([testTimer isValid]) {
            [testTimer invalidate];
            testTimer = nil;
        }
    }
    [self setSelectDeviceBtnTitle:@"正在搜索智能设备" IsEnable:YES];
    [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    [self setIsScanning:NO];
    [self reloadComboxMenu];
    if (testTimer) {
        if ([testTimer isValid]) {
            [testTimer invalidate];
            testTimer = nil;
        }
    }
    [self setSelectDeviceBtnTitle:@"蓝牙未打开" IsEnable:YES];
}

-(void)onCallbackScanBluetoothTimeout:(NSNotification *)notify
{
    [self setIsScanning:NO];
    [self setSelectDeviceBtnTitle:@"请选择嗅觉设备" IsEnable:YES];
}

-(void)onCallbackBluetoothDisconnected:(NSNotification *)notify
{
    [self setIsScanning:NO];
    [self reloadComboxMenu];
    [self setSelectDeviceBtnTitle:@"设备未连接" IsEnable:YES];
}

-(void)onStartConnectToBluetooth:(NSNotification *)notify
{
    [self setIsScanning:NO];
    [self setSelectDeviceBtnTitle:@"连接中..." IsEnable:YES];
    if (testTimer) {
        if ([testTimer isValid]) {
            [testTimer invalidate];
            testTimer = nil;
        }
    }
}

-(void)onCallbackConnectToBluetoothSuccessfully:(NSNotification *)notify
{
    [self setIsScanning:NO];
    [self reloadComboxMenu];
    [self setSelectDeviceBtnTitle:@"设备已连接" IsEnable:YES];
    [self.viewModel clearData];
    [self initlizedData];
    
    //心跳包
    testTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(test) userInfo:nil repeats:YES];
    [testTimer fire];
}

-(void)onCallbackConnectToBluetoothTimeout:(NSNotification *)notify
{
    [self setIsScanning:NO];
    [self setSelectDeviceBtnTitle:@"设备未连接" IsEnable:YES];
    
    if (testTimer) {
        if (![testTimer isValid]) {
            //心跳包
            testTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(test) userInfo:nil repeats:YES];
            [testTimer fire];
        }
    }
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
                }];
            }
                break;
            case EmitSmell:
            {
                [[self.viewModel emitSmellReturn:byte] subscribeNext:^(id x) {
                    NSDictionary *dic = (NSDictionary *)x;
                    NSString *rfId = [dic objectForKey:EmitSmellNoKey];
                    NSNumber *duration = [dic objectForKey:EmitSmellDurationKey];
                    if ([duration integerValue] == 0) {
                        [self setSelectTag:CloseTag];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (smellEmitTimer) {
                                if ([smellEmitTimer isValid]) {
                                    [smellEmitTimer invalidate];
                                    smellEmitTimer = nil;
                                }
                            }
                        });
                    }else{
                        [self setSelectTag:rfId];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self startTimerWithDuration:[duration intValue]];
                        });
                    }
                }];
            }
                break;
            case BottleInfoCompletely:
            {
                [AppUtils showHudProgress:@"气味正在提取中，请耐心等待..." ForView:self.view];
                [[self.viewModel getBottleInfoCompletelyReturn:byte WithBottleInfoList:bottleInfoList] subscribeNext:^(id x) {
                    //处理http返回responseObject
                    [AppUtils hidenHudProgressForView:self.view];
                    if (x == nil) {
                        [self dowithFruitList];
                        return ;
                    }
                    
                    NSDictionary *result = (NSDictionary *)x;
                    if (result) {
                        NSArray *dataArr = [result objectForKey:@"data"];
                        if (dataArr) {
                            for (NSDictionary *dic in dataArr) {
                                Fruit *fruit = [[Fruit alloc] init];
                                fruit.fruitName = [dic objectForKey:@"cn_name"];
                                fruit.fruitKeyWords = [dic objectForKey:@"keywords"];
                                fruit.fruitEnName = [dic objectForKey:@"en_name"];
                                [fruit setFruitImageWithDic:[dic objectForKey:@"icon"]];
                                fruit.fruitColor = [NSString stringWithFormat:@"#%@",[dic objectForKey:@"color"]];
                                fruit.fruitRFID = [[dic objectForKey:@"bottle_sn"] uppercaseString];
                                fruit.fruitSn = [dic objectForKey:@"smell_sn"];
                                
                                if ([[SFruitInfoDB shareInstance] isExistFruitWithRFID:fruit.fruitRFID]) {
                                    [[SFruitInfoDB shareInstance] mergeFruit:fruit];
                                }else{
                                    [[SFruitInfoDB shareInstance] saveFruit:fruit];
                                }
                            }
                            
                            [self dowithFruitList];
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
/**
 *  @author RenRenFenQi, 16-08-04 10:08:43
 *
 *  水果列表从网络请求后对FruitList处理
 */
-(void)dowithFruitList
{
    if (bottleInfoList && bottleInfoList.count > 0) {
        for (NSDictionary *dic in bottleInfoList) {
            NSString *rfId = [dic objectForKey:BottleKey];
            if (rfId) {
                Fruit *fruit = [[SFruitInfoDB shareInstance] selectFruitWithRFID:rfId];
                if (fruit == nil) {
                    fruit = [[Fruit alloc] init];
                    fruit.fruitName = rfId;
                    fruit.fruitKeyWords = @"";
                    fruit.fruitEnName = @"";
                    fruit.fruitImage = @"FruitDefaultImage";
                    fruit.fruitRFID = rfId;
                    
                    fruit.fruitColor = @"#000000";
                }
                [self addFruitByOrder:fruit];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:BottleInfoCompeletelyNotify object:_fruitsList];
        [self saveOrderFile];
        [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

//同步ComboxMenu的数据
-(void)syncComboxMenuData
{
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    while (isScanning) {
        
        [self reloadComboxMenu];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    
    //runloop结束后，为了防止延迟造成的数据不统一，最后进行一次刷新数据
    [self reloadComboxMenu];
}

//刷新ComboxMenu的蓝牙数据列表
-(void)reloadComboxMenu
{
    if (comboxView) {
        if ([comboxView isShow]) {
            NSArray *peripheralArray = [[BluetoothMacManager defaultManager] returnAllScanPeripherals];
            
            NSArray *peripheralNameArray = [[BluetoothMacManager defaultManager] returnAllScanPeripheralNames];
            NSUInteger defaultSelectedIndex = -1;
            if ([[BluetoothMacManager defaultManager] isConnected]) {
                id connectedPeripheral = [[BluetoothMacManager defaultManager] returnConnectedPeripheral];
                if ([peripheralArray containsObject:connectedPeripheral]) {
                    defaultSelectedIndex = [peripheralArray indexOfObject:connectedPeripheral];
                }
            }
            
            [comboxView setTitleArray:peripheralNameArray WithDataSourceArray:peripheralArray WithDefaultSelectedIndex:defaultSelectedIndex];
        }
    }
}

/**
 *  @author RenRenFenQi, 16-08-01 20:08:02
 *
 *  设置是否浏览状态
 *
 *  @param state 蓝牙状态
 */
-(void)setIsScanning:(BOOL)state
{
    isScanning = state;
    if (comboxView) {
        if ([comboxView isShow]) {
            [comboxView setIsScanning:state];
        }
    }
}
/**
 *  @author RenRenFenQi, 16-07-30 12:07:31
 *
 *  设置下拉设备按钮的标题和图片
 *
 *  @param title 标题
 *  @param image 图片
 */
-(void)setSelectDeviceBtn:(NSString *)title WithImage:(UIImage *)image IsEnable:(BOOL)isEnable
{
    //让按钮左标题，右图片
    if (title) {
        CGFloat fontSize = [UIDevice adaptTextFontSizeWithIphone5FontSize:17.0f IsBold:YES];
        CGRect rect = [title boundingRectWithSize:CGSizeMake(300, 21) options:0 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]} context:nil];
        [_btnSelectDevice setImageEdgeInsets:UIEdgeInsetsMake(0, rect.size.width + 5, 0, -rect.size.width - 5)];
    }else{
        [_btnSelectDevice setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if (image) {
        [_btnSelectDevice setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width)];
    }else{
        [_btnSelectDevice setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    [_btnSelectDevice setTitle:title forState:UIControlStateNormal];
    [_btnSelectDevice setImage:image forState:UIControlStateNormal];
    [_btnSelectDevice setEnabled:isEnable];
}

/**
 *  @author RenRenFenQi, 16-08-02 17:08:07
 *
 *  设置下拉设备按钮的标题图片和是否可用
 *
 *  @param title    标题
 *  @param isEnable 是否可用
 */
-(void)setSelectDeviceBtnTitle:(NSString *)title IsEnable:(BOOL)isEnable
{
    if (comboxView) {
        if ([comboxView isShow]) {
            [self setSelectDeviceBtn:title WithImage:[UIImage imageNamed:@"ComboxUpImage"] IsEnable:isEnable];
            return;
        }
    }
    [self setSelectDeviceBtn:title WithImage:[UIImage imageNamed:@"ComboxDownImage"] IsEnable:YES];
}
/**
 *  @author RenRenFenQi, 16-07-26 10:07:04
 *
 *  心跳包
 */
-(void)test
{
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommandStr:@""];
    }else{
        [[BluetoothProcessManager defatultManager] reconnectBluetooth];
    }
}
/**
 *  @author RenRenFenQi, 16-06-14 20:06:07
 *
 *  初始化数据
 */
-(void)initlizedData
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/%@",[documentPaths objectAtIndex:0],LocalSmellRFIDOrderFile];
    rfIdOrderList = [NSArray arrayWithContentsOfFile:path];
    
    if (bottleInfoList) {
        [bottleInfoList removeAllObjects];
    }else{
        bottleInfoList = [NSMutableArray array];
    }
    
    if (_fruitsList) {
        [_fruitsList removeAllObjects];
    }else{
        _fruitsList = [NSMutableArray array];
    }
    
    hasNewFruit = NO;
    selectTag = CloseTag;
    [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

/**
 *  @author RenRenFenQi, 16-06-03 13:06:34
 *
 *  设置当前发散气味的标识
 *
 *  @param tag 气味标识
 */
-(void)setSelectTag:(NSString *)tag
{
    selectTag = tag;
    [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
-(Fruit *)searchFruitByRFID:(NSString *)rfId
{
    Fruit *fruit = nil;
    for (Fruit *f in _fruitsList) {
        if ([f.fruitRFID isEqualToString:rfId]) {
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
-(void)writeDataWithRFID:(NSString *)rfId WithTimeInterval:(int)interval
{
    if (![[BluetoothMacManager defaultManager] isPoweredOn]) {
        [AppUtils showInfo:@"蓝牙未打开"];
        return;
    }
    
    if (![[BluetoothMacManager defaultManager] isConnected]) {
        //提示打开蓝牙或下拉重连
        [AppUtils showInfo:@"设备未连接"];
        return;
    }

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
        NSInteger index = [rfIdOrderList indexOfObject:fruit.fruitRFID];
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
    if (_fruitsList == nil || _fruitsList.count == 0) {
        return;
    }
    
    NSMutableArray *orderList = [NSMutableArray array];
    for (Fruit *fruit in _fruitsList) {
        [orderList addObject:fruit.fruitRFID];
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
        if (fruit.fruitKeyWords) {
            [content appendString:fruit.fruitKeyWords];
            [content appendString:@"|"];
        }
    }
    [content appendString:@"关|关闭;"];
    return content;
}

/**
 *  @author RenRenFenQi, 16-06-07 17:06:19
 *
 *  渲染皮肤
 *
 *  @param skin 皮肤属性对象
 */
-(void)renderingSkinWithSmellSkin:(SmellSkin *)skin
{
    if (skin == nil) {
        return;
    }
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:skin.backgroundImage] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"正在接收BackgroundImage");
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (finished) {
            if (image) {
                self.view.layer.contents = (id)image.CGImage;
            }else{
                UIImage *backImage = [UIImage imageNamed:@"BackGroudImage"];
                self.view.layer.contents = (id)backImage.CGImage;
            }
        }
    }];

    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:skin.tabBarImage] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"正在接收TabBarImage");
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (finished) {
            if (image) {
                self.tabBarView.layer.contents = (id)image.CGImage;
            }else{
                UIImage *tabBarImage = [UIImage imageNamed:@"TabBarBackgroundImage"];
                self.tabBarView.layer.contents = (id)tabBarImage.CGImage;
            }
        }
    }];
    

    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:skin.voiceButtonImage] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"正在接收ButtonVoiceImage");
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (finished) {
            if (image) {
                [self.btnVoice setBackgroundImage:image forState:UIControlStateNormal];
            }else{
                UIImage *voiceImage = [UIImage imageNamed:@"VoiceBtn_Normal"];
                [self.btnVoice setBackgroundImage:voiceImage forState:UIControlStateNormal];
            }
        }
    }];

}

/**
 *  @author RenRenFenQi, 16-06-08 11:06:36
 *
 *  获取皮肤包
 *
 *  @param skinId 皮肤包ID
 */
-(void)requestSmellSkinWithSkinId:(NSString *)skinId
{
    if (self.viewModel) {
        [[self.viewModel getSkinPacket:skinId] subscribeNext:^(id x) {
            NSDictionary *resultDic = (NSDictionary *)x;
            if (resultDic) {
                NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                if (dataDic) {
                    
                    SmellSkin *skin = [[SmellSkin alloc] init];
                    skin.skinId = [dataDic objectForKey:@"id"];
                    NSString *url = [dataDic objectForKey:@"url"];
                    NSString *backgroundUrl = [NSString stringWithFormat:@"%@%@",url,[dataDic objectForKey:@"background"]];
                    skin.backgroundImage = backgroundUrl;
                    NSString *tabUrl = [NSString stringWithFormat:@"%@%@",url,[dataDic objectForKey:@"tab"]];
                    skin.tabBarImage = tabUrl;
                    NSString *buttonUrl = [NSString stringWithFormat:@"%@%@",url,[dataDic objectForKey:@"button"]];
                    skin.voiceButtonImage = buttonUrl;
                    [skin saveSkinToLocal];
                    [self renderingSkinWithSmellSkin:skin];
                }
            }
        }];

    }
}

/**
 *  @author RenRenFenQi, 16-08-01 11:08:03
 *
 *  刷新蓝牙设备数据
 */
-(void)refreshBluetoothData
{
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        [self initlizedData];
        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandMacAddress];
        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommand:CommandBottleInfo];
    }else{
        [[BluetoothProcessManager defatultManager] startScanBluetooth];
    }
}
#pragma -mark ButtonClickEvent
-(IBAction)TouchDownVoiceBtn:(id)sender
{
    NSLog(@"按钮按下了...");
    
}

-(IBAction)TouchUpinsideVoiceBtn:(id)sender
{
    NSLog(@"按钮松开了...");
    if (![[BluetoothMacManager defaultManager] isPoweredOn]) {
        [AppUtils showInfo:@"蓝牙未打开"];
        return;
    }
    
    if (![[BluetoothMacManager defaultManager] isConnected]) {
        //提示打开蓝牙或下拉重连
        [AppUtils showInfo:@"设备未连接"];
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
                        if (![selectTag isEqualToString:CloseTag]) {
                            [[IFlySpeechSynthesizerManager defaultManager] startSpeeking:YES Callback:^(BOOL completely) {
                                if (completely) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SpeakDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        //延迟后需要做的操作
                                        [self writeDataWithRFID:selectTag WithTimeInterval:0];
                                    });
                                }
                            }];
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

-(IBAction)clickRefreshBtn:(UIButton *)sender
{
    if(popoverView != nil)
    {
        [popoverView removeFromSuperview];
        popoverView = nil;
    }
    
    CGPoint point = CGPointMake(sender.frame.origin.x + sender.frame.size.width/2, sender.frame.origin.y + sender.frame.size.height);
    popoverView = [[PopoverView alloc] initWithPoint:point titles:popoverTitle images:nil];
    
    __weak __typeof(self) weakSelf = self;
    [popoverView setSelectRowAtIndex:^(NSInteger index) {
        switch (index) {
            case 0:
            {
                [weakSelf clickScriptBtn];
            }
                break;
            case 1:
            {
                
            }
                break;
                
            default:
                break;
        }
    }];
    
    [popoverView show];
}

-(void)clickScriptBtn
{
    if (![[BluetoothMacManager defaultManager] isPoweredOn]) {
        [AppUtils showInfo:@"蓝牙未打开"];
        return;
    }
    
    if (![[BluetoothMacManager defaultManager] isConnected])
    {
        [AppUtils showInfo:@"设备未连接"];
        return;
    }
    
    if (scriptVC == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        scriptVC = [storyboard instantiateViewControllerWithIdentifier:@"ScriptViewIdentify"];
    }
    NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:KMY_BlutoothMacAddress_Key];
    [scriptVC setMacAddress:macAddress WithFruitList:_fruitsList];
    
    [self.navigationController wxs_pushViewController:scriptVC makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType = WXSTransitionAnimationTypeSpreadFromRight;
    }];
}

-(IBAction)clickSelectDeviceBtn:(id)sender
{
    if (comboxView) {
        if ([comboxView isShow]) {
            [comboxView hidden];
            comboxView = nil;
            return;
        }
    }
    NSArray *peripheralArray = [[BluetoothMacManager defaultManager] returnAllScanPeripherals];
    
    NSArray *peripheralNameArray = [[BluetoothMacManager defaultManager] returnAllScanPeripheralNames];
    NSUInteger defaultSelectedIndex = -1;
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        id connectedPeripheral = [[BluetoothMacManager defaultManager] returnConnectedPeripheral];
        if ([peripheralArray containsObject:connectedPeripheral]) {
            defaultSelectedIndex = [peripheralArray indexOfObject:connectedPeripheral];
        }
    }
    comboxView = [[ComboxMenuView alloc] initWithStartPoint:CGPointMake(0, 64)  WithTitleArray:peripheralNameArray WithDataSourceArray:peripheralArray WithDefaultSelectedIndex:defaultSelectedIndex];
    comboxView.delegate = self;
    __weak __typeof(self) weakSelf = self;
    [comboxView setHiddenCallBack:^(BOOL completion) {
        [weakSelf setSelectDeviceBtnTitle:weakSelf.btnSelectDevice.currentTitle IsEnable:YES];
    }];
    [comboxView showInView:self.view];
    [comboxView setIsScanning:isScanning];
    [weakSelf setSelectDeviceBtnTitle:weakSelf.btnSelectDevice.currentTitle IsEnable:YES];
}
#pragma mark - LewReorderableLayoutDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView *backImageView = [cell viewWithTag:1];
    UILabel *lblName = [cell viewWithTag:2];
    UIView *frontView = [cell viewWithTag:3];
    
    UIView *firstLine = [cell viewWithTag:4];
    [firstLine setHidden:YES];
    UIView *secondLine = [cell viewWithTag:5];
    [secondLine setHidden:YES];
    UIView *thirdLine = [cell viewWithTag:6];
    [thirdLine setHidden:YES];
    UIView *fourthLine = [cell viewWithTag:7];
    [fourthLine setHidden:YES];
    
    UILabel *lblEnName = [cell viewWithTag:8];
    
    Fruit *fruit = [_fruitsList objectAtIndex:indexPath.item];
    [backImageView sd_setImageWithURL:[NSURL URLWithString:fruit.fruitImage] placeholderImage:[UIImage imageNamed:@"FruitDefaultImage"] options:SDWebImageLowPriority|SDWebImageRetryFailed];
    [lblName setText:fruit.fruitName];
    [lblEnName setText:fruit.fruitEnName];
    if ([selectTag isEqualToString:fruit.fruitRFID]) {
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
    
    if (CellItemCount >= 1) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds)-0.5;
        CGFloat perPieceWidth = screenWidth / (CellItemCount * 1.0f) - ((CellMargin / (CellItemCount * 1.0f)) * (CellItemCount - 1));
        CGFloat perPieceHeight = perPieceWidth * 520.0f / 413.0f;
        return CGSizeMake(perPieceWidth, perPieceHeight);
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

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will begin Dragging");
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView *firstLine = [cell viewWithTag:4];
    [firstLine setHidden:NO];
    UIView *secondLine = [cell viewWithTag:5];
    [secondLine setHidden:NO];
    UIView *thirdLine = [cell viewWithTag:6];
    [thirdLine setHidden:NO];
    UIView *fourthLine = [cell viewWithTag:7];
    [fourthLine setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will End Dragging");
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView *firstLine = [cell viewWithTag:4];
    [firstLine setHidden:YES];
    UIView *secondLine = [cell viewWithTag:5];
    [secondLine setHidden:YES];
    UIView *thirdLine = [cell viewWithTag:6];
    [thirdLine setHidden:YES];
    UIView *fourthLine = [cell viewWithTag:7];
    [fourthLine setHidden:YES];
}

#pragma -mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [[ScriptExecuteManager defaultManager] cancelAllScripts];
    Fruit *selectFruit = [_fruitsList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",(long)indexPath.item,selectFruit.fruitName);
    if ([selectFruit.fruitRFID isEqualToString:selectTag]) {
        [self writeDataWithRFID:selectFruit.fruitRFID WithTimeInterval:0];
    }else{
        [self writeDataWithRFID:selectFruit.fruitRFID WithTimeInterval:SmellEmitDuration];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",(long)indexPath.item);
}

#pragma -mark ScanBluetoothDeviceViewProtocol
-(void)connectToBluetoothWithPeripheral:(id)peripheral WithName:(NSString *)name;
{
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        if (![[BluetoothMacManager defaultManager] isMatchConnectedPeripheral:peripheral]) {
            [[ScriptExecuteManager defaultManager] cancelAllScripts];
            [[BluetoothProcessManager defatultManager] connectToBluetooth:name WithPeripheral:peripheral];
        }else{
            [self refreshBluetoothData];
        }
    }else{
        [[BluetoothProcessManager defatultManager] connectToBluetooth:name WithPeripheral:peripheral];
    }
}


#pragma -mark FloatViewProtocol
-(void)didTapView
{
    if (![[BluetoothMacManager defaultManager] isPoweredOn]) {
        [AppUtils showInfo:@"蓝牙未打开"];
        return;
    }
    
    if (![[BluetoothMacManager defaultManager] isConnected])
    {
        [AppUtils showInfo:@"设备未连接"];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ScriptOperationViewController *scriptOperationVC = [storyboard instantiateViewControllerWithIdentifier:@"ScriptOperationViewIdentify"];
    scriptOperationVC.delegate = self;
    if (_fruitsList && _fruitsList.count > 0) {
        [scriptOperationVC setFruitList:_fruitsList];
    }
    [self.navigationController wxs_pushViewController:scriptOperationVC makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType = WXSTransitionAnimationTypeBrickOpenHorizontal;
        transition.animationTime = 0.5f;
        transition.backGestureEnable = NO;
    }];
}

#pragma -mark ComboxMenuViewProtocol
-(void)selectPeripheral:(id)peripheral WithDeviceName:(NSString *)name
{
    if (![[BluetoothMacManager defaultManager] isPoweredOn]) {
        [AppUtils showInfo:@"蓝牙未打开"];
        return;
    }
    [self connectToBluetoothWithPeripheral:peripheral WithName:name];
}

-(void)rescanBluetooth
{
    if (![[BluetoothMacManager defaultManager] isPoweredOn]) {
        [AppUtils showInfo:@"蓝牙未打开"];
        return;
    }
    [[BluetoothProcessManager defatultManager] startScanBluetooth];
}
#pragma -mark ScriptOperationViewProtocol
-(void)selectPeripheralFromOperationView:(id)peripheral WithDeviceName:(NSString *)name;
{
    [self selectPeripheral:peripheral WithDeviceName:name];
}

-(void)pushToScriptView
{
    [self clickScriptBtn];
}

-(void)startScanningFromOperationView
{
    [self rescanBluetooth];
}
@end
