//
//  ScriptSerialCollectionViewCell.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Fruit;
@protocol ScriptSerialCollectionViewCellProtocol <NSObject>

-(void)swipeCellForFruit:(Fruit *)fruit;

@end
@interface ScriptSerialCollectionViewCell : UICollectionViewCell
{
    Fruit *currentFruit;
    UISwipeGestureRecognizer *swipeGestureRecognizer;
}
@property(nonatomic, strong) IBOutlet UIImageView *fruitImageView;
@property(nonatomic, strong) IBOutlet UILabel *lblFruitName;
@property(nonatomic, assign) id<ScriptSerialCollectionViewCellProtocol> delegate;
-(void)setFruit:(Fruit *)fruit;
@end
