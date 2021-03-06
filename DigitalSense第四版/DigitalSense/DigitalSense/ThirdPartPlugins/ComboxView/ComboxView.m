//
//  ComboxView.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/18.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ComboxView.h"
#import "ComboxHeadView.h"
#define Duration 0.3f
#define DefaultCellHeight 44.0f
@interface ComboxView()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *dataSourceArray;
    NSArray *titleArray;
    NSInteger selectedIndex;
    
    UIView *parentView;
    BOOL isShow;
    
    ComboxHeadView *headView;
    
    CGPoint beginPoint;
    
    HiddenCallback hiddenCallback;
}
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation ComboxView
static  NSString * const cellIdentify = @"ComboxViewCellIdentify";
-(instancetype)initWithStartPoint:(CGPoint)startPoint WithTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [super initWithFrame:CGRectMake(0, startPoint.y, screenSize.width, screenSize.height - startPoint.y)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        beginPoint = startPoint;
        titleArray = [titleList copy];
        dataSourceArray = [dataList copy];
        selectedIndex = defaultSelectedIndex;
        
        headView = [[ComboxHeadView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, DefaultCellHeight)];
        [self addSubview:headView];
        
        CGFloat height = (DefaultCellHeight * titleArray.count + 0.5) > (screenSize.height - beginPoint.y) / 2.0f ? (screenSize.height - beginPoint.y) / 2.0f : (DefaultCellHeight * titleArray.count + 0.5);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headView.frame.size.height, screenSize.width, height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        [_tableView setTableFooterView:[UIView new]];
        [self addSubview:_tableView];
    }
    return self;
}

-(void)setTitleArray:(NSArray *)titleList WithDataSourceArray:(NSArray *)dataList WithDefaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    @synchronized (self) {
        titleArray = [titleList copy];
        dataSourceArray = [dataList copy];
        selectedIndex = defaultSelectedIndex;
        if (_tableView) {
            CGFloat height = (DefaultCellHeight * titleArray.count + 0.5) > (self.frame.size.height / 2.0f - headView.frame.size.height) ? (self.frame.size.height / 2.0f - headView.frame.size.height) : (DefaultCellHeight * titleArray.count + 0.5);
            [_tableView setFrame:CGRectMake(0, 0, _tableView.frame.size.width, height)];
            [_tableView reloadData];
        }
    }
}

-(void)showInView:(UIView *)view
{
    NSLog(@"%lf,%lf",view.frame.size.width,view.frame.size.height);
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    CGPoint arrowPoint = [self convertPoint:CGPointMake(self.frame.size.width / 2.0f, beginPoint.y) fromView:view];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width / 2.0f, arrowPoint.y / self.frame.size.height);
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self setFrame:CGRectMake(0, beginPoint.y, screenSize.width, screenSize.height - beginPoint.y)];
    
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
    
    if (headView) {
        [headView removeFromSuperview];
        headView = nil;
    }
    
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
    return 44.0f;
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
    if (indexPath.row == selectedIndex) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
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
