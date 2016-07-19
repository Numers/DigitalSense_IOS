//
//  ScriptSerialCollectionViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSerialViewController.h"
#import "LewReorderableLayout.h"
#import "ScriptSerialCollectionViewCell.h"

#import "Fruit.h"

@interface ScriptSerialViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,LewReorderableLayoutDelegate,LewReorderableLayoutDataSource>
{
    NSMutableArray *fruitList;
}
@property(nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ScriptSerialViewController

static NSString * const reuseIdentifier = @"ScriptSerialCollectionViewCell";
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
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ScriptSerialCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
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
//    fruit2.fruitName = @"菠萝";
//    [fruitList addObject:fruit2];
//    
//    Fruit *fruit3 = [[Fruit alloc] init];
//    fruit3.fruitName = @"橙子";
//    [fruitList addObject:fruit3];
//    
//    Fruit *fruit4 = [[Fruit alloc] init];
//    fruit4.fruitName = @"西瓜";
//    [fruitList addObject:fruit4];
//    
//    Fruit *fruit5 = [[Fruit alloc] init];
//    fruit5.fruitName = @"猕猴桃";
//    [fruitList addObject:fruit5];
//    
//    Fruit *fruit6 = [[Fruit alloc] init];
//    fruit6.fruitName = @"草莓";
//    [fruitList addObject:fruit6];
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
}

-(void)setFruitList:(NSArray *)list
{
    if (list && list.count > 0) {
        [self inilizedData];
        [fruitList addObjectsFromArray:list];
        if (_collectionView) {
            [_collectionView reloadData];
        }
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
    ScriptSerialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Fruit *fruit = [fruitList objectAtIndex:indexPath.item];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setFruit:fruit];
        });
    });
    // Configure the cell
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return fruitList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = (collectionView.frame.size.height - 0.5)/ 2.0f;
    return CGSizeMake(height, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0.5);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
    Fruit *fruit = [fruitList objectAtIndex:fromIndexPath.item];
    [fruitList removeObjectAtIndex:fromIndexPath.item];
    [fruitList insertObject:fruit atIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will begin Dragging");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will End Dragging");
    
}

#pragma -mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Fruit *selectFruit = [fruitList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",indexPath.item,selectFruit.fruitName);
    if ([self.delegate respondsToSelector:@selector(selectFruit:)]) {
        [self.delegate selectFruit:selectFruit];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",indexPath.item);
}
@end
