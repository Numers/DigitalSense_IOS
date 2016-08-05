//
//  ScriptSelectSmellView.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSelectSmellView.h"
#import "ScriptCommand.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"

#define DefaultMaxHeight 20.0f
#define FruitImageMargin 2.0f
#define LabelHeight 20.0f

@implementation ScriptSelectSmellView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:17.0f];
        [self.layer setMasksToBounds:YES];
        self.fruitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 2 * FruitImageMargin, frame.size.width - 2 * FruitImageMargin)];
        [self.fruitImageView setImage:[UIImage imageNamed:@"SelectViewCircleForCell"]];
        self.fruitImageView.center = CGPointMake(frame.size.width/ 2, frame.size.width/ 2);
        [self addSubview:self.fruitImageView];
        
        self.lblFruitName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, LabelHeight)];
        [self.lblFruitName setCenter:CGPointMake(frame.size.width/ 2, frame.size.width/ 2)];
        [self.lblFruitName setTextAlignment:NSTextAlignmentCenter];
        [self.lblFruitName setFont:[UIFont boldSystemFontOfSize:10.0f]];
        [self.lblFruitName setNumberOfLines:0];
        [self.lblFruitName setTextColor:[UIColor whiteColor]];
        [self insertSubview:self.lblFruitName aboveSubview:self.fruitImageView];
        
        self.lblDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - LabelHeight - 10, frame.size.width, LabelHeight)];
        [self.lblDuration setTextAlignment:NSTextAlignmentCenter];
        [self.lblDuration setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.lblDuration setNumberOfLines:0];
        [self.lblDuration setTextColor:[UIColor whiteColor]];
        [self addSubview:self.lblDuration];
        
        maxHeight = DefaultMaxHeight;
    }
    return self;
}

-(void)setScriptCommand:(ScriptCommand *)scriptCommand
{
//    if (self.fruitImageView) {
//        [self.fruitImageView sd_setImageWithURL:[NSURL URLWithString:fruit.fruitImage] placeholderImage:[UIImage imageNamed:@"FruitDefaultImage"]];
//    }
    if ([AppUtils isNullStr:scriptCommand.rfId]) {
        canMove = NO;
    }else{
        canMove = YES;
    }
    [self setBackgroundColor:[UIColor colorFromHexString:scriptCommand.color]];
    if (self.lblFruitName) {
        [self.lblFruitName setText:scriptCommand.smellName];
    }
    
    if (self.lblDuration) {
        [self.lblDuration setText:[NSString stringWithFormat:@"%lds",(long)scriptCommand.duration]];
    }
}

-(void)setMaxHeight:(CGFloat)height
{
    maxHeight = height;
}

#pragma -mark TouchEvent
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!canMove) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint previoisPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
    
    CGFloat vectorDy = previoisPoint.y - currentPoint.y;
    CGFloat height = vectorDy  + self.frame.size.height;
//    if ((height > self.frame.size.width - 2 * FruitImageMargin) && height <= maxHeight) {
    if (height >= 0.0f && height <= maxHeight) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - vectorDy, self.frame.size.width, height);
        [self setNeedsDisplay];
        if ([self.delegate respondsToSelector:@selector(powerValueChanged:)]) {
            [self.delegate powerValueChanged:height/maxHeight];
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.fruitImageView) {
        self.fruitImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
    }
    
    if (self.lblFruitName) {
        self.lblFruitName.center = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
    }
    
    if (self.lblDuration) {
        [self.lblDuration setFrame:CGRectMake(0, self.frame.size.height - LabelHeight, self.frame.size.width, LabelHeight)];
        [self.lblDuration sizeThatFits:CGSizeMake(self.frame.size.width, LabelHeight)];
    }
    
//    if (self.fruitImageView.center.y > (self.fruitImageView.frame.size.height / 2.0f  + 2 * LabelHeight)) {
//        [self.lblFruitName setAlpha:1.0f];
//        [self.lblDuration setAlpha:1.0f];
//    }else{
//        CGFloat tempMargin = (self.fruitImageView.frame.size.height / 2.0f  + 2 * LabelHeight) - self.fruitImageView.center.y;
//        if (tempMargin < 10.0f) {
//            [self.lblFruitName setAlpha:(10.0f - tempMargin) / 10.0f];
//            [self.lblDuration setAlpha:(10.0f - tempMargin) / 10.0f];
//        }else{
//            [self.lblFruitName setAlpha:0.0f];
//            [self.lblDuration setAlpha:0.0f];
//        }
//    }
}
@end
