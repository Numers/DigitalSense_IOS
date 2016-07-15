//
//  DataPickViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/13.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "DataPickViewController.h"
#define ToolBarHeight 40.0f
#define Duration 0.3f
@interface DataPickViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *dataSourceArray;
    NSArray *titleSourceArray;
    id pickViewIdentify;
    id selectObject;
    UIView *parentView;
    BOOL isShow;
    NSInteger selectRow;
}
@property(nonatomic, strong) UIPickerView *pickView;
@property(nonatomic, strong) UIToolbar *toolBar;
@end

@implementation DataPickViewController
-(instancetype)initWithDataArray:(NSArray *)dataArray WithTitleArray:(NSArray *)titleArray WithIdentify:(id)identify
{
    self = [super init];
    if (self) {
        if ((dataArray && titleArray) && (dataArray.count == titleArray.count)) {
            dataSourceArray = [NSArray arrayWithArray:dataArray];
            titleSourceArray = [NSArray arrayWithArray:titleArray];
        }else{
            NSLog(@"数据源与标题源数据不匹配");
            dataSourceArray = [NSArray array];
            titleSourceArray = [NSArray array];
        }
        pickViewIdentify = identify;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpPickView];
    
    float viewHeight = _toolBar.frame.size.height + _pickView.frame.size.height;
    self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, viewHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpPickView
{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ToolBarHeight)];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancelBtn)];
    [leftBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:10/255.f green:190/255.f blue:196/255.f alpha:1.f] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickComfirmBtn)];
    [rightBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:10/255.f green:190/255.f blue:196/255.f alpha:1.f] forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
    _toolBar.items=@[leftBarItem,centerSpace,rightBarItem];
    [self.view addSubview:_toolBar];
    
    _pickView = [[UIPickerView alloc] init];
    [_pickView setFrame:CGRectMake(0, ToolBarHeight, [UIScreen mainScreen].bounds.size.width, _pickView.frame.size.height)];
    _pickView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    _pickView.delegate = self;
    _pickView.dataSource = self;
    [_pickView setShowsSelectionIndicator:YES];
    [self.view addSubview:_pickView];
    if (dataSourceArray.count > 0) {
        [_pickView selectRow:selectRow inComponent:0 animated:NO];
        selectObject = [dataSourceArray objectAtIndex:selectRow];
    }
}

-(void)setSelectRow:(NSInteger)row
{
    if (row < dataSourceArray.count) {
        selectRow = row;
        if (_pickView) {
            [_pickView selectRow:row inComponent:0 animated:NO];
            selectObject = [dataSourceArray objectAtIndex:row];
        }
    }
}

-(void)showInView:(UIView *)view
{
    CATransition *animation = [CATransition  animation];
    animation.duration = Duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.view setAlpha:1.0f];
    [self.view.layer addAnimation:animation forKey:@"DDLocateView"];
    
    self.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
    [view setUserInteractionEnabled:NO];
    parentView = view;
    isShow = YES;
}

-(void)hidden
{
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = Duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.view setAlpha:0.0f];
    [self.view.layer addAnimation:animation forKey:@"TSLocateView"];
    isShow = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [parentView setUserInteractionEnabled:YES];
    [self performSelector:@selector(removeView) withObject:nil];
}

-(void)removeView
{
    [_toolBar removeFromSuperview];
    _toolBar = nil;
    
    [_pickView removeFromSuperview];
    _pickView = nil;
    
    [self.view removeFromSuperview];
}

-(BOOL)isShow
{
    return isShow;
}

-(void)clickCancelBtn
{
    [self hidden];
}

-(void)clickComfirmBtn
{
    if ([_delegate respondsToSelector:@selector(pickData:WithIdentify:)]) {
        [_delegate pickData:selectObject WithIdentify:pickViewIdentify];
    }
    [self hidden];
}

#pragma -mark pickViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = [titleSourceArray objectAtIndex:row];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectObject = [dataSourceArray objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return titleSourceArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
@end
