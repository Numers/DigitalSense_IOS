//
//  ScriptSerialCollectionViewCell.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSerialCollectionViewCell.h"
#import "Fruit.h"

#import "UIImageView+WebCache.h"
@implementation ScriptSerialCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setFruit:(Fruit *)fruit
{
    [self setBackgroundColor:[UIColor clearColor]];
    currentFruit = fruit;
    if (swipeGestureRecognizer == nil) {
        swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeGestureRecognizer];
    }
    if ([AppUtils isNetworkURL:fruit.fruitImage]) {
        [self.fruitImageView sd_setImageWithURL:[NSURL URLWithString:fruit.fruitImage] placeholderImage:[UIImage imageNamed:@"FruitDefaultImage"]];
    }else{
        [self.fruitImageView setImage:[UIImage imageNamed:fruit.fruitImage]];
    }
    
    [self.lblFruitName setText:fruit.fruitName];
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touched");
//}

-(void)swipeGesture
{
    if ([self.delegate respondsToSelector:@selector(swipeCellForFruit:)]) {
        [self.delegate swipeCellForFruit:currentFruit];
    }
}
@end
