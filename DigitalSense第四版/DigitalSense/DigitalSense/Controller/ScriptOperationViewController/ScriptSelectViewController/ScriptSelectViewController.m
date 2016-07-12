//
//  ScriptSelectCollectionViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSelectViewController.h"
#import "LewReorderableLayout.h"
#import "ScriptSelectCollectionViewCell.h"

#import "Fruit.h"
#import "ScriptCommand.h"

@interface ScriptSelectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,LewReorderableLayoutDelegate,LewReorderableLayoutDataSource,ScriptSelectCollectionViewCellProtocol>
{
    NSMutableArray *fruitList;
    NSMutableArray *scriptCommandList;
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
    [self.view setBackgroundColor:[UIColor grayColor]];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    LewReorderableLayout *layout = [[LewReorderableLayout alloc] init];
    layout.delegate = self;
    layout.dataSource = self;
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, controllerFrame.size.width, controllerFrame.size.height) collectionViewLayout:layout];
    [self.collectionView setScrollEnabled:YES];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    [self.collectionView registerClass:[ScriptSelectCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // Do any additional setup after loading the view.
    [self inilizedData];
    
//    Fruit *fruit = [[Fruit alloc] init];
//    fruit.fruitName = @"苹果";
//    [fruitList addObject:fruit];
//    
//    Fruit *fruit1 = [[Fruit alloc] init];
//    fruit1.fruitName = @"香蕉";
//    [fruitList addObject:fruit1];
//    
//    Fruit *fruit2 = [[Fruit alloc] init];
//    fruit2.fruitName = @"香蕉";
//    [fruitList addObject:fruit2];
//    
//    Fruit *fruit3 = [[Fruit alloc] init];
//    fruit3.fruitName = @"香蕉";
//    [fruitList addObject:fruit3];
//    
//    Fruit *fruit4 = [[Fruit alloc] init];
//    fruit4.fruitName = @"香蕉";
//    [fruitList addObject:fruit4];
//    
//    Fruit *fruit5 = [[Fruit alloc] init];
//    fruit5.fruitName = @"香蕉";
//    [fruitList addObject:fruit5];
//    
//    Fruit *fruit6 = [[Fruit alloc] init];
//    fruit6.fruitName = @"香蕉";
//    [fruitList addObject:fruit6];
//    
//    Fruit *fruit7 = [[Fruit alloc] init];
//    fruit7.fruitName = @"香蕉";
//    [fruitList addObject:fruit7];
//    
//    Fruit *fruit8 = [[Fruit alloc] init];
//    fruit8.fruitName = @"香蕉";
//    [fruitList addObject:fruit8];
//    
//    Fruit *fruit9 = [[Fruit alloc] init];
//    fruit9.fruitName = @"香蕉";
//    [fruitList addObject:fruit9];
//    
//    ScriptCommand *command = [[ScriptCommand alloc] init];
//    command.duration = 3;
//    command.power = 0.5;
//    [scriptCommandList addObject:command];
//    
//    ScriptCommand *command1 = [[ScriptCommand alloc] init];
//    command1.duration = 3;
//    command1.power = 0.5;
//    [scriptCommandList addObject:command1];
//    
//    ScriptCommand *command2 = [[ScriptCommand alloc] init];
//    command2.duration = 3;
//    command2.power = 0.5;
//    [scriptCommandList addObject:command2];
//    
//    ScriptCommand *command3 = [[ScriptCommand alloc] init];
//    command3.duration = 3;
//    command3.power = 0.5;
//    [scriptCommandList addObject:command3];
//    
//    ScriptCommand *command4 = [[ScriptCommand alloc] init];
//    command4.duration = 3;
//    command4.power = 0.5;
//    [scriptCommandList addObject:command4];
//    
//    ScriptCommand *command5 = [[ScriptCommand alloc] init];
//    command5.duration = 3;
//    command5.power = 0.5;
//    [scriptCommandList addObject:command5];
//    
//    ScriptCommand *command6 = [[ScriptCommand alloc] init];
//    command6.duration = 3;
//    command6.power = 0.5;
//    [scriptCommandList addObject:command6];
//    
//    ScriptCommand *command7 = [[ScriptCommand alloc] init];
//    command7.duration = 3;
//    command7.power = 0.5;
//    [scriptCommandList addObject:command7];
//    
//    ScriptCommand *command8 = [[ScriptCommand alloc] init];
//    command8.duration = 3;
//    command8.power = 0.5;
//    [scriptCommandList addObject:command8];
//    
//    ScriptCommand *command9 = [[ScriptCommand alloc] init];
//    command9.duration = 3;
//    command9.power = 0.5;
//    [scriptCommandList addObject:command9];
//    
//    [self.collectionView reloadData];
}

-(void)inilizedData
{
    if (fruitList) {
        [fruitList removeAllObjects];
    }else{
        fruitList = [NSMutableArray array];
    }
    
    if (scriptCommandList) {
        [scriptCommandList removeAllObjects];
    }else{
        scriptCommandList = [NSMutableArray array];
    }
}

-(void)addFruit:(Fruit *)fruit
{
    if (fruit) {
        Fruit *addFruit = [[Fruit alloc] init];
        addFruit.fruitRFID = fruit.fruitRFID;
        addFruit.fruitName = fruit.fruitName;
        addFruit.fruitImage = fruit.fruitImage;
        addFruit.fruitEnName = fruit.fruitEnName;
        addFruit.fruitKeyWords = fruit.fruitKeyWords;
        addFruit.tag = fruit.tag;
        [fruitList addObject:addFruit];
        
        ScriptCommand *command = [[ScriptCommand alloc] init];
        command.rfId = fruit.fruitRFID;
        command.duration = 3;
        command.power = 0.5;
        [scriptCommandList addObject:command];
        
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:scriptCommandList.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
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
        Fruit *fruit = [fruitList objectAtIndex:indexPath.item];
        ScriptCommand *command = [scriptCommandList objectAtIndex:indexPath.item];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setFruitSmell:fruit WithScriptCommand:command];
        });
    });
    // Configure the cell
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (fruitList.count == scriptCommandList.count) ? fruitList.count : 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ScriptCommand *command = [scriptCommandList objectAtIndex:indexPath.item];
    CGFloat width = 15 * command.duration;
    CGFloat height = self.view.frame.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
    Fruit *fruit = [fruitList objectAtIndex:fromIndexPath.item];
    [fruitList removeObjectAtIndex:fromIndexPath.item];
    [fruitList insertObject:fruit atIndex:toIndexPath.item];
    
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
    Fruit *selectFruit = [fruitList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",indexPath.item,selectFruit.fruitName);
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",indexPath.item);
}

#pragma -mark ScriptSelectCollectionViewCellProtocol
-(void)deleteCellWithFruit:(Fruit *)fruit WithScriptCommand:(ScriptCommand *)command
{
    if ([fruitList containsObject:fruit]) {
        [fruitList removeObject:fruit];
    }
    
    if ([scriptCommandList containsObject:command]) {
        [scriptCommandList removeObject:command];
    }
    
    [self.collectionView reloadData];
}
@end
