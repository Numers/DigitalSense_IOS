//
//  ScriptSelectCollectionViewCell.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSelectCollectionViewCell.h"
#import "ScriptCommand.h"

#define CloseBtnSize CGSizeMake(25, 25)

@implementation ScriptSelectCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.smellView = [[ScriptSelectSmellView alloc] initWithFrame:CGRectMake(0, frame.size.height  / 2.0f, frame.size.width, frame.size.height  / 2.0f)];
        self.smellView.delegate = self;
        [self.contentView addSubview:self.smellView];
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSmellView)];
        [self.smellView addGestureRecognizer:tapGestureRecognizer];
        
        self.btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CloseBtnSize.width, CloseBtnSize.height)];
        [self.btnClose setBackgroundImage:[UIImage imageNamed:@"ScriptCommand_Delete"] forState:UIControlStateNormal];
        [self.btnClose addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView insertSubview:self.btnClose aboveSubview:self.smellView];
        [self.btnClose setCenter:CGPointMake(self.smellView.frame.origin.x + self.smellView.frame.size.width - CloseBtnSize.width / 2.0f, self.smellView.frame.origin.y + CloseBtnSize.height / 2.0f)];
        [self.btnClose setHidden:!isShowCloseBtn];
    }
    return self;
}

-(void)setIsShowCloseBtn:(BOOL)isShow
{
    isShowCloseBtn = isShow;
    if (self.btnClose) {
        [self.btnClose setHidden:!isShow];
    }
}

-(void)clickCloseBtn
{
    if([self.delegate respondsToSelector:@selector(deleteCellWithFruit:WithScriptCommand:)]){
        [self.delegate deleteCellWithFruit:currentFruit WithScriptCommand:currentScriptCommand];
    }
}

-(void)tapSmellView
{
    if ([self.delegate respondsToSelector:@selector(showPickViewWithScriptCommand:)]) {
        [self.delegate showPickViewWithScriptCommand:currentScriptCommand];
    }
}

-(void)setFruitSmell:(Fruit *)fruit WithScriptCommand:(ScriptCommand *)scriptCommand;
{
    currentFruit = fruit;
    currentScriptCommand = scriptCommand;
    if (self.smellView) {
        [self.smellView setFruit:fruit WithDuration:scriptCommand.duration];
        [self.smellView setMaxHeight:self.frame.size.height];
        [self.smellView setFrame:CGRectMake(self.smellView.frame.origin.x, self.frame.size.height * (1 - scriptCommand.power), self.frame.size.width, self.frame.size.height * scriptCommand.power)];
    }else{
        self.smellView = [[ScriptSelectSmellView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * (1 - scriptCommand.power), self.frame.size.width, self.frame.size.height * scriptCommand.power)];
        self.smellView.delegate = self;
        [self.smellView setFruit:fruit WithDuration:scriptCommand.duration];
        [self.smellView setMaxHeight:self.frame.size.height];
        [self.contentView addSubview:self.smellView];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSmellView)];
        [self.smellView addGestureRecognizer:tapGestureRecognizer];
    }
    [self.smellView setNeedsDisplay];
    
    if (self.btnClose == nil) {
        self.btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CloseBtnSize.width, CloseBtnSize.height)];
        [self.btnClose setBackgroundImage:[UIImage imageNamed:@"ScriptCommand_Delete"] forState:UIControlStateNormal];
        [self.btnClose addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView insertSubview:self.btnClose aboveSubview:self.smellView];
        [self.btnClose setCenter:CGPointMake(self.smellView.frame.origin.x + self.smellView.frame.size.width - CloseBtnSize.width / 2.0f, self.smellView.frame.origin.y + CloseBtnSize.height / 2.0f)];
        [self.btnClose setHidden:!isShowCloseBtn];
    }
    [self.btnClose setCenter:CGPointMake(self.smellView.frame.origin.x + self.smellView.frame.size.width - CloseBtnSize.width / 2.0f, self.smellView.frame.origin.y + CloseBtnSize.height / 2.0f)];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (isShowCloseBtn) {
        [self setIsShowCloseBtn:NO];
    }
}

#pragma -mark ScriptSelectSmellViewProtocol
-(void)powerValueChanged:(CGFloat)power
{
    if (power == 0.0f) {
        if([self.delegate respondsToSelector:@selector(deleteCellWithFruit:WithScriptCommand:)]){
            [self.delegate deleteCellWithFruit:currentFruit WithScriptCommand:currentScriptCommand];
        }
        return;
    }
    
    if (currentScriptCommand) {
        currentScriptCommand.power = power;
    }
    
    if (self.btnClose) {
        [self.btnClose setCenter:CGPointMake(self.smellView.frame.origin.x + self.smellView.frame.size.width - CloseBtnSize.width / 2.0f, self.smellView.frame.origin.y + CloseBtnSize.height / 2.0f)];
    }
}
@end
