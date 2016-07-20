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
    if ([AppUtils isNetworkURL:fruit.fruitImage]) {
        [self.fruitImageView sd_setImageWithURL:[NSURL URLWithString:fruit.fruitImage] placeholderImage:[UIImage imageNamed:@"FruitDefaultImage"]];
    }else{
        [self.fruitImageView setImage:[UIImage imageNamed:fruit.fruitImage]];
    }
    
    [self.lblFruitName setText:fruit.fruitName];
}
@end
