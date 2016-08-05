//
//  ScriptSelectCollectionViewCell.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSelectCollectionViewCell.h"
#import "ScriptCommand.h"
#define ShadowWidth 11.5f
#define TopAndBottomFixValue 2.5f

#define CloseBtnSize CGSizeMake(25, 25)

@implementation ScriptSelectCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *backgroundImage = [UIImage imageNamed:@"SelectViewBackgroundForCell"];
        self.layer.contents = (id)backgroundImage.CGImage;
        
        [self.layer setCornerRadius:17.0f];
        [self.layer setMasksToBounds:YES];
        
        self.smellView = [[ScriptSelectSmellView alloc] initWithFrame:CGRectMake(ShadowWidth, frame.size.height  / 2.0f, frame.size.width - ShadowWidth * 2, frame.size.height / 2.0f - ShadowWidth + TopAndBottomFixValue)];
        [self.smellView setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.smellView];
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSmellView)];
        [self.smellView addGestureRecognizer:tapGestureRecognizer];
        
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCell)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
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
    if([self.delegate respondsToSelector:@selector(deleteCellWithScriptCommand:)]){
        [self.delegate deleteCellWithScriptCommand:currentScriptCommand];
    }
}

-(void)tapSmellView
{
    if ([self.delegate respondsToSelector:@selector(showPickViewWithScriptCommand:)]) {
        [self.delegate showPickViewWithScriptCommand:currentScriptCommand];
    }
}

-(void)longPressCell
{
    
}

-(void)setScriptCommand:(ScriptCommand *)scriptCommand;
{
    currentScriptCommand = scriptCommand;
    if (self.smellView) {
        [self.smellView setScriptCommand:scriptCommand];
        [self.smellView setMaxHeight:self.frame.size.height - ShadowWidth * 2 + 2 * TopAndBottomFixValue];
        [self.smellView setFrame:CGRectMake(self.smellView.frame.origin.x, (self.frame.size.height - 2 * ShadowWidth) * (1 - scriptCommand.power) + ShadowWidth - TopAndBottomFixValue, self.frame.size.width - ShadowWidth * 2, (self.frame.size.height - 2 * ShadowWidth) * scriptCommand.power + 2 * TopAndBottomFixValue)];
    }else{
        self.smellView = [[ScriptSelectSmellView alloc] initWithFrame:CGRectMake(ShadowWidth, self.frame.size.height  / 2.0f, self.frame.size.width - ShadowWidth * 2, self.frame.size.height / 2.0f - ShadowWidth + TopAndBottomFixValue)];
        [self.smellView setUserInteractionEnabled:YES];
        self.smellView.delegate = self;
        [self.smellView setScriptCommand:scriptCommand];
        [self.smellView setMaxHeight:self.frame.size.height - ShadowWidth * 2 + 2 * TopAndBottomFixValue];
        [self.contentView addSubview:self.smellView];
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSmellView)];
        [self.smellView addGestureRecognizer:tapGestureRecognizer];
    }
    self.smellView.delegate = self;
    if (longPressGestureRecognizer) {
        longPressGestureRecognizer.delegate = self.delegate;
    }
    
    if (tapGestureRecognizer) {
        tapGestureRecognizer.delegate = self.delegate;
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

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if (isShowCloseBtn) {
//        [self setIsShowCloseBtn:NO];
//    }
//}

#pragma -mark ScriptSelectSmellViewProtocol
-(void)powerValueChanged:(CGFloat)power
{
    if (power < 0.1f) {
        if([self.delegate respondsToSelector:@selector(deleteCellWithScriptCommand:)]){
            [self.delegate deleteCellWithScriptCommand:currentScriptCommand];
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
