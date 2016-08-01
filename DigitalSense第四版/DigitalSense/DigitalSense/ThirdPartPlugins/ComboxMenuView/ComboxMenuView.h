//
//  ComboxMenuView.h
//  DigitalSense
//
//  Created by baolicheng on 16/8/1.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ComboxMenuViewProtocol <NSObject>
-(void)selectPeripheral:(id)peripheral WithDeviceName:(NSString *)name;
-(void)rescanBluetooth;
@end
typedef void (^ HiddenCallback)(BOOL completion);

typedef enum{
    BeginScanningState,
    StopScanningState
}BluetoothScanState;
@interface ComboxMenuView : UIView
@property(nonatomic, assign) id<ComboxMenuViewProtocol> delegate;
-(instancetype)initWithStartPoint:(CGPoint)startPoint WithTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex;

-(void)setTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex;

-(void)setIsScanning:(BOOL)isScanning;

-(void)showInView:(UIView *)view;

-(void)hidden;

-(void)setHiddenCallBack:(HiddenCallback)callback;

-(BOOL)isShow;
@end
