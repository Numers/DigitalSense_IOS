//
//  ScriptSelectCollectionViewCell.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptSelectSmellView.h"
@class ScriptSelectSmellView,Fruit,ScriptCommand;
@protocol ScriptSelectCollectionViewCellProtocol <NSObject>
-(void)deleteCellWithFruit:(Fruit *)fruit WithScriptCommand:(ScriptCommand *)command;
-(void)showPickViewWithScriptCommand:(ScriptCommand *)command;
@end
@interface ScriptSelectCollectionViewCell : UICollectionViewCell<ScriptSelectSmellViewProtocol>
{
    BOOL isShowCloseBtn;
    Fruit *currentFruit;
    ScriptCommand *currentScriptCommand;
    
    UITapGestureRecognizer *tapGestureRecognizer;
}
@property(nonatomic, assign) id<ScriptSelectCollectionViewCellProtocol> delegate;
@property(nonatomic, strong) UIButton *btnClose;
@property(nonatomic, strong) ScriptSelectSmellView *smellView;

-(void)setFruitSmell:(Fruit *)fruit WithScriptCommand:(ScriptCommand *)scriptCommand;
-(void)setIsShowCloseBtn:(BOOL)isShow;
@end
