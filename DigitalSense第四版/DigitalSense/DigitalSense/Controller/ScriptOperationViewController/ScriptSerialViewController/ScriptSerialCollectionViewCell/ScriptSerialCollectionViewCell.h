//
//  ScriptSerialCollectionViewCell.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Fruit;
@interface ScriptSerialCollectionViewCell : UICollectionViewCell
{
    Fruit *currentFruit;
}
@property(nonatomic, strong) IBOutlet UIImageView *fruitImageView;
@property(nonatomic, strong) IBOutlet UILabel *lblFruitName;

-(void)setFruit:(Fruit *)fruit;
@end
