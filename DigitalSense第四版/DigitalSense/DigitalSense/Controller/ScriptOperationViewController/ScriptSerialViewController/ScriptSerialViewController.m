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

@interface ScriptSerialViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,LewReorderableLayoutDelegate,LewReorderableLayoutDataSource,ScriptSerialCollectionViewCellProtocol,UIScrollViewDelegate>
{
    NSMutableArray *fruitList;
}
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIPageControl *pageControl;
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
    [self.view setBackgroundColor:[UIColor clearColor]];
    // Uncomment the following line to preserve selection between presentations
    LewReorderableLayout *layout = [[LewReorderableLayout alloc] init];
    layout.delegate = self;
    layout.dataSource = self;
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, controllerFrame.size.width, controllerFrame.size.height - 16) collectionViewLayout:layout];
    UIImage *collectionBackgroundImage = [UIImage imageNamed:@"SerialViewBackgroundViewImage"];
    self.collectionView.layer.contents = (id)collectionBackgroundImage.CGImage;
    [self.collectionView setScrollEnabled:YES];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ScriptSerialCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    //add PageControl
    self.pageControl = [[UIPageControl alloc] init];
    [self.pageControl setHidesForSinglePage:NO];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithWhite:1.0f alpha:0.8]];
    [self.pageControl setPageIndicatorTintColor:[UIColor colorWithWhite:0.667 alpha:0.600]];
    [self.view addSubview:self.pageControl];
    [self.pageControl setCenter:CGPointMake(controllerFrame.size.width / 2.0f, controllerFrame.size.height - 8)];
    // Do any additional setup after loading the view.
    [self inilizedData];
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
        Fruit *fruit = [[Fruit alloc] init];
        fruit.fruitName = @"间隔";
        fruit.fruitRFID = @"";
        fruit.fruitImage = @"SerialViewClockForCell";
        fruit.fruitColor = @"#000000";
        [fruitList addObject:fruit];
        NSInteger i = 1;
        for (Fruit *f in list) {
            [fruitList addObject:f];
            i++;
            if (i % 8 == 0) {
                [fruitList addObject:fruit];
                i++;
            }
        }
        [self.pageControl setNumberOfPages:(fruitList.count + 7)/8];
        [_collectionView scrollsToTop];
        [self.pageControl setCurrentPage:0];
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
    if (indexPath.item >= fruitList.count) {
        [cell setFruit:nil];
    }else{
        cell.delegate = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Fruit *fruit = [fruitList objectAtIndex:indexPath.item];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setFruit:fruit];
            });
        });
    }
    // Configure the cell
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return ((fruitList.count + 7) / 8) * 8;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (collectionView.frame.size.width - 1.5) / 4.0f;
    CGFloat height = (collectionView.frame.size.height - 0.5)/ 2.0f;
    return CGSizeMake(width, height);
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
    if (indexPath.item >= fruitList.count) {
        return;
    }
    Fruit *selectFruit = [fruitList objectAtIndex:indexPath.item];
    NSLog(@"select %ld, FruitName is %@",(long)indexPath.item,selectFruit.fruitName);
    if ([self.delegate respondsToSelector:@selector(selectFruit:)]) {
        [self.delegate selectFruit:selectFruit];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselect %ld",(long)indexPath.item);
}

#pragma -mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = [scrollView contentOffset];
    NSInteger page = offset.x / _collectionView.frame.size.width;
    [self.pageControl setCurrentPage:page];
}
#pragma -mark ScriptSerialCollectionViewCellProtocol
-(void)swipeCellForFruit:(Fruit *)fruit
{
    if (fruit) {
        if ([fruitList containsObject:fruit]) {
            if ([self.delegate respondsToSelector:@selector(selectFruit:)]) {
                [self.delegate selectFruit:fruit];
            }
        }
    }
}
@end
