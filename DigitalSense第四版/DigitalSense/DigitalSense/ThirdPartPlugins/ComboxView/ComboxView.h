//
//  ComboxView.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/18.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ComboxViewProtocol <NSObject>
-(void)selectPeripheral:(id)peripheral WithDeviceName:(NSString *)name;
@end
typedef void (^ HiddenCallback)(BOOL completion);
@interface ComboxView : UIView
@property(nonatomic, assign) id<ComboxViewProtocol> delegate;
-(instancetype)initWithStartPoint:(CGPoint)startPoint WithTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex;

-(void)showInView:(UIView *)view;

-(void)hidden;

-(void)setHiddenCallBack:(HiddenCallback)callback;

-(BOOL)isShow;
@end
