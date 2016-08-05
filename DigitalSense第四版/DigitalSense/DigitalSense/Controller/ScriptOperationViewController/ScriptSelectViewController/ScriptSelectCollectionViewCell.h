//
//  ScriptSelectCollectionViewCell.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScriptSelectSmellView.h"
@class ScriptSelectSmellView,ScriptCommand;
@protocol ScriptSelectCollectionViewCellProtocol <NSObject>
-(void)deleteCellWithScriptCommand:(ScriptCommand *)command;
-(void)showPickViewWithScriptCommand:(ScriptCommand *)command;
@end
@interface ScriptSelectCollectionViewCell : UICollectionViewCell<ScriptSelectSmellViewProtocol>
{
    BOOL isShowCloseBtn;
    ScriptCommand *currentScriptCommand;
    
    UITapGestureRecognizer *tapGestureRecognizer;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
}
@property(nonatomic, assign) id<ScriptSelectCollectionViewCellProtocol,UIGestureRecognizerDelegate> delegate;
@property(nonatomic, strong) UIButton *btnClose;
@property(nonatomic, strong) ScriptSelectSmellView *smellView;

-(void)setScriptCommand:(ScriptCommand *)scriptCommand;
-(void)setIsShowCloseBtn:(BOOL)isShow;
@end
