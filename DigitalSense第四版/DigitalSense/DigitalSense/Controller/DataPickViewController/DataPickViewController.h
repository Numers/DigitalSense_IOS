//
//  DataPickViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/13.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DataPickViewProtocol <NSObject>
-(void)pickData:(id)data WithIdentify:(id)identify;
@end
@interface DataPickViewController : UIViewController
@property(nonatomic, assign) id<DataPickViewProtocol> delegate;

-(id)initWithDataArray:(NSArray *)dataArray WithTitleArray:(NSArray *)titleArray WithIdentify:(id)identify;
-(void)setSelectRow:(NSInteger)row;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
