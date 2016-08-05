//
//  ScriptSelectSmellView.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScriptCommand;
@protocol ScriptSelectSmellViewProtocol <NSObject>
-(void)powerValueChanged:(CGFloat)power;
@end

@interface ScriptSelectSmellView : UIView
{
    CGFloat maxHeight;
    
    BOOL canMove;
}
@property(nonatomic, assign) id<ScriptSelectSmellViewProtocol> delegate;
@property(nonatomic, strong) UIImageView *fruitImageView;
@property(nonatomic, strong) UILabel *lblFruitName;
@property(nonatomic, strong) UILabel *lblDuration;
-(void)setScriptCommand:(ScriptCommand *)scriptCommand;
-(void)setMaxHeight:(CGFloat)height;
@end
