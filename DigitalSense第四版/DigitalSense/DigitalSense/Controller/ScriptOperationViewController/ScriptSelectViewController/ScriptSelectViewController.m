//
//  ScriptSelectCollectionViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSelectViewController.h"
#import "DataPickViewController.h"
#import "LewReorderableLayout.h"
#import "ScriptSelectCollectionViewCell.h"

#import "Fruit.h"
#import "ScriptCommand.h"

@interface ScriptSelectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,LewReorderableLayoutDelegate,LewReorderableLayoutDataSource,ScriptSelectCollectionViewCellProtocol,DataPickViewProtocol>
{
    NSMutableArray *scriptCommandList;
    
    DataPickViewController *dataPickVC;
    
    NSInteger allTime;
}
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ScriptSelectViewController

static NSString * const reuseIdentifier = @"ScriptSelectCollectionViewCell";

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        controllerFrame = frame;
        [self.view setFrame:frame];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    LewReorderableLayout *layout = [[LewReorderableLayout alloc] init];
    layout.delegate = self;
    layout.dataSource = self;
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, controllerFrame.size.width, controllerFrame.size.height) collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setScrollEnabled:YES];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    [self.collectionView registerClass:[ScriptSelectCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // Do any additional setup after loading the view.
    if (scriptCommandList && scriptCommandList.count > 0) {
        
    }else{
        [self inilizedData];
    }
}

-(void)inilizedData
{
    if (scriptCommandList) {
        [scriptCommandList removeAllObjects];
    }else{
        scriptCommandList = [NSMutableArray array];
    }
    
    allTime = 0;
}

-(void)addFruit:(Fruit *)fruit
{
    if (fruit) {
        ScriptCommand *command = [[ScriptCommand alloc] init];
        command.rfId = fruit.fruitRFID;
        command.smellName = fruit.fruitName;
        command.duration = 3;
        command.power = 0.5;
        command.desc = fruit.fruitName;
        command.color = fruit.fruitColor;
        [scriptCommandList addObject:command];
        
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:scriptCommandList.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        
        [self scriptTimeChanged:command.duration];
    }
}

-(void)setScriptCommandList:(NSArray *)commandList WithScriptTime:(NSInteger)scriptTime
{
    if (commandList == nil || commandList.count == 0) {
        return;
    }
    
    if (scriptCommandList) {
        [scriptCommandList removeAllObjects];
    }else{
        scriptCommandList = [NSMutableArray array];
    }
    [scriptCommandList addObjectsFromArray:commandList];
    allTime = scriptTime;
    if (_collectionView) {
        [_collectionView reloadData];
    }
}

-(NSMutableArray *)returnAllScriptCommand
{
    return scriptCommandList;
}

-(void)scriptTimeChanged:(NSInteger)addTime
{
    allTime += addTime;
    if ([self.delegate respondsToSelector:@selector(scriptCommandTimeDidChanged:)]) {
        [self.delegate scriptCommandTimeDidChanged:allTime];
    }
}

-(void)clearAllData
{
    [self inilizedData];
    if ([self.delegate respondsToSelector:@selector(scriptCommandTimeDidChanged:)]) {
        [self.delegate scriptCommandTimeDidChanged:allTime];
    }
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - LewReorderableLayoutDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ScriptSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setIsShowCloseBtn:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ScriptCommand *command = [scriptCommandList objectAtIndex:indexPath.item];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setScriptCommand:command];
        });
    });
    // Configure the cell
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return scriptCommandList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    ScriptCommand *command = [scriptCommandList objectAtIndex:indexPath.item];
//    CGFloat width = 15 * command.duration;
    CGFloat height = collectionView.frame.size.height;
    CGFloat width = 180.0f * height / 692.0f;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 11;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 11;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
    ScriptCommand *command = [scriptCommandList objectAtIndex:fromIndexPath.item];
    [scriptCommandList removeObjectAtIndex:fromIndexPath.item];
    [scriptCommandList insertObject:command atIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will begin Dragging %ld",indexPath.item);
    ScriptSelectCollectionViewCell *cell = (ScriptSelectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setIsShowCloseBtn:YES];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will End Dragging");

}

#pragma -mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ScriptCommand *command = [scriptCommandList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",indexPath.item,command.smellName);
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",indexPath.item);
}

#pragma -mark ScriptSelectCollectionViewCellProtocol
-(void)deleteCellWithScriptCommand:(ScriptCommand *)command
{
    @synchronized (self) {
        if ([scriptCommandList containsObject:command]) {
            [scriptCommandList removeObject:command];
            [self.collectionView reloadData];
            [self scriptTimeChanged:-command.duration];
        }
    }
}

-(void)showPickViewWithScriptCommand:(ScriptCommand *)command
{
    if (dataPickVC) {
        dataPickVC = nil;
    }
    dataPickVC = [[DataPickViewController alloc] initWithDataArray:@[@1,@2,@3,@4,@5,@6,@7,@8] WithTitleArray:@[@"1s",@"2s",@"3s",@"4s",@"5s",@"6s",@"7s",@"8s"] WithIdentify:command];
    dataPickVC.delegate = self;
    [dataPickVC showInView:[self.view superview]];
    
}

#pragma -mark DataPickViewProtocol
-(void)pickData:(id)data WithIdentify:(id)identify
{
    if ([data isKindOfClass:[NSNumber class]] && [identify isKindOfClass:[ScriptCommand class]]) {
        ScriptCommand *command = (ScriptCommand *)identify;
        NSNumber *duration = (NSNumber *)data;
        NSInteger added = [duration integerValue] - command.duration;
        command.duration = [duration integerValue];
        
        [self.collectionView reloadData];
        [self scriptTimeChanged:added];
    }
}
@end
