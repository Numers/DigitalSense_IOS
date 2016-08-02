//
//  ComboxMenuView.m
//  DigitalSense
//
//  Created by baolicheng on 16/8/1.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ComboxMenuView.h"
#define Duration 0.3f
#define DefaultCellHeight 44.0f
#define DefaultScanBtnSize CGSizeMake(110,40)
#define DefaultTableViewMarginToBottom (DefaultScanBtnSize.height + 20.0f)
#define ViewMarginLeftAndRight 15.0f
@interface ComboxMenuView()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *dataSourceArray;
    NSArray *titleArray;
    NSInteger selectedIndex;
    
    UIView *backView;
    UIImageView *pointImageView;
    
    UIView *parentView;
    BOOL isShow;
    
    CGPoint beginPoint;
    
    HiddenCallback hiddenCallback;
}
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *btnRescan;
@end
@implementation ComboxMenuView
static  NSString * const cellIdentify = @"ComboxMenuViewCellIdentify";
-(instancetype)initWithStartPoint:(CGPoint)startPoint WithTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [super initWithFrame:CGRectMake(ViewMarginLeftAndRight, startPoint.y, screenSize.width - 2 * ViewMarginLeftAndRight, screenSize.height - startPoint.y)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        beginPoint = startPoint;
        titleArray = [titleList copy];
        dataSourceArray = [dataList copy];
        selectedIndex = defaultSelectedIndex;
        
        //箭头的位置
        UIImage *pointImage = [UIImage imageNamed:@"Combox_PointImage"];
        pointImageView = [[UIImageView alloc] initWithImage:pointImage];
        [pointImageView setFrame:CGRectMake(0, 0, pointImage.size.width, pointImage.size.height)];
        [pointImageView setCenter:CGPointMake(self.frame.size.width / 2.0f, pointImage.size.height / 2.0f + 0.25)];
        [self addSubview:pointImageView];
        
        
        CGFloat height = (DefaultCellHeight * titleArray.count + 0.5 + DefaultTableViewMarginToBottom + pointImageView.frame.size.height) > self.frame.size.height / 2.0f ? self.frame.size.height / 2.0f : (DefaultCellHeight * titleArray.count + 0.5 + DefaultTableViewMarginToBottom + pointImageView.frame.size.height);
        
        //backView的位置
        backView = [[UIView alloc] initWithFrame:CGRectMake(0, pointImageView.frame.size.height, self.frame.size.width, height - pointImageView.frame.size.height)];
        [backView.layer setCornerRadius:5.0f];
        [backView.layer setMasksToBounds:YES];
        [backView setBackgroundColor:[UIColor colorWithWhite:0.114 alpha:0.900]];
        [self addSubview:backView];
        
        //tableView位置
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(17, 0, backView.frame.size.width - 34, backView.frame.size.height - DefaultTableViewMarginToBottom) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setSeparatorColor:[UIColor colorWithWhite:0.263 alpha:1.000]];
        [_tableView setShowsVerticalScrollIndicator:NO];
        
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        [_tableView setTableFooterView:[UIView new]];
        [backView addSubview:_tableView];
        
        //重新搜索按钮位置
        _btnRescan = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnRescan setFrame:CGRectMake(backView.frame.size.width - 17 - DefaultScanBtnSize.width, backView.frame.size.height - DefaultTableViewMarginToBottom + 10.0f, DefaultScanBtnSize.width, DefaultTableViewMarginToBottom - 2 * 10.0f)];
        [_btnRescan addTarget:self action:@selector(clickRescanBtn) forControlEvents:UIControlEventTouchUpInside];
        [self setRescanBtnState:BeginScanningState];
        [backView addSubview:_btnRescan];
    }
    return self;
}

-(void)setIsScanning:(BOOL)isScanning
{
    if (isScanning) {
        [self setRescanBtnState:BeginScanningState];
    }else{
        [self setRescanBtnState:StopScanningState];
    }
}

-(void)setRescanBtnState:(BluetoothScanState)state
{
    switch (state) {
        case BeginScanningState:
        {
            [_btnRescan setImage:[UIImage imageNamed:@"Combox_ScanningImage_Normal"] forState:UIControlStateNormal];
            [_btnRescan setEnabled:NO];
            break;
        }
        case StopScanningState:
        {
            [_btnRescan setImage:[UIImage imageNamed:@"Combox_RescanImage_Normal"] forState:UIControlStateNormal];
            [_btnRescan setEnabled:YES];
            break;
        }
   
        default:
            break;
    }
}

-(void)setTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    @synchronized (self) {
        titleArray = [titleList copy];
        dataSourceArray = [dataList copy];
        selectedIndex = defaultSelectedIndex;
        if (_tableView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat height = (DefaultCellHeight * titleArray.count + 0.5 + DefaultTableViewMarginToBottom + pointImageView.frame.size.height) > self.frame.size.height / 2.0f ? self.frame.size.height / 2.0f : (DefaultCellHeight * titleArray.count + 0.5 + DefaultTableViewMarginToBottom + pointImageView.frame.size.height);
                [backView setFrame:CGRectMake(0, pointImageView.frame.size.height, self.frame.size.width, height - pointImageView.frame.size.height)];
                [_tableView setFrame:CGRectMake(17, 0, backView.frame.size.width - 34, backView.frame.size.height - DefaultTableViewMarginToBottom)];
                [_btnRescan setFrame:CGRectMake(backView.frame.size.width - 17 - DefaultScanBtnSize.width, backView.frame.size.height - DefaultTableViewMarginToBottom + 10.0f, DefaultScanBtnSize.width, DefaultTableViewMarginToBottom - 2 * 10.0f)];
                [_tableView reloadData];
            });
        }
    }
}

-(void)clickRescanBtn
{
    if ([self.delegate respondsToSelector:@selector(rescanBluetooth)]) {
        [self.delegate rescanBluetooth];
    }
}

-(void)showInView:(UIView *)view
{
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    CGPoint arrowPoint = [self convertPoint:CGPointMake(self.frame.size.width / 2.0f, beginPoint.y) fromView:view];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width / 2.0f, arrowPoint.y / self.frame.size.height);
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self setFrame:CGRectMake(ViewMarginLeftAndRight, beginPoint.y, screenSize.width - 2 * ViewMarginLeftAndRight, screenSize.height - beginPoint.y)];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(1.0f, 0.1f);
    [UIView animateWithDuration:Duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
        parentView = view;
        isShow = YES;
    }];
}

-(void)hidden
{
    [UIView animateWithDuration:Duration animations:^{
        self.transform = CGAffineTransformMakeScale(1.0f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        if (hiddenCallback) {
            hiddenCallback(finished);
        }
        isShow = NO;
        [parentView setUserInteractionEnabled:YES];
        [self performSelector:@selector(removeView) withObject:nil];
    }];
}

-(void)setHiddenCallBack:(HiddenCallback)callback
{
    hiddenCallback = callback;
}

-(void)removeView
{
    [_tableView removeFromSuperview];
    _tableView = nil;
    
    [pointImageView removeFromSuperview];
    [backView removeFromSuperview];
    [_btnRescan removeFromSuperview];
    [self removeFromSuperview];
}

-(BOOL)isShow
{
    return isShow;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hidden];
}
#pragma -mark UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DefaultCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArray.count == dataSourceArray.count ? titleArray.count : 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.114 alpha:0.850]];
    
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:title];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    
    [cell.imageView setImage:[UIImage imageNamed:@"Combox_Bluetooth"]];
    if (indexPath.row == selectedIndex) {
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Combox_SelectedImage"]]];
    }else{
        [cell setAccessoryView:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id peripheral = [dataSourceArray objectAtIndex:indexPath.row];
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(selectPeripheral:WithDeviceName:)]) {
        [self.delegate selectPeripheral:peripheral WithDeviceName:title];
    }
    [self hidden];
}

@end
