//
//  ScriptSelectSmellView.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptSelectSmellView.h"
#import "Fruit.h"
#import "UIImageView+WebCache.h"

#define DefaultMaxHeight 20.0f
#define FruitImageMargin 2.0f
#define LabelHeight 20.0f

@implementation ScriptSelectSmellView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blueColor]];
        self.fruitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 2 * FruitImageMargin, frame.size.width - 2 * FruitImageMargin)];
        self.fruitImageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        [self addSubview:self.fruitImageView];
        
        self.lblFruitName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.fruitImageView.frame.origin.y + self.fruitImageView.frame.size.height, frame.size.width, LabelHeight)];
        [self.lblFruitName setTextAlignment:NSTextAlignmentCenter];
        [self.lblFruitName setFont:[UIFont systemFontOfSize:15.0f]];
        [self.lblFruitName setNumberOfLines:0];
        [self.lblFruitName setTextColor:[UIColor whiteColor]];
        [self addSubview:self.lblFruitName];
        
        self.lblDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - LabelHeight, frame.size.width, LabelHeight)];
        [self.lblDuration setTextAlignment:NSTextAlignmentCenter];
        [self.lblDuration setFont:[UIFont systemFontOfSize:12.0f]];
        [self.lblDuration setNumberOfLines:0];
        [self.lblDuration setTextColor:[UIColor whiteColor]];
        [self addSubview:self.lblDuration];
        
        maxHeight = DefaultMaxHeight;
    }
    return self;
}

-(void)setFruit:(Fruit *)fruit WithDuration:(NSInteger)duration
{
    if (self.fruitImageView) {
        [self.fruitImageView sd_setImageWithURL:[NSURL URLWithString:fruit.fruitImage] placeholderImage:[UIImage imageNamed:@"FruitDefaultImage"]];
    }
    
    if (self.lblFruitName) {
        [self.lblFruitName setText:fruit.fruitName];
    }
    
    if (self.lblDuration) {
        [self.lblDuration setText:[NSString stringWithFormat:@"%lds",duration]];
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
        self.fruitImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    
    if (self.lblFruitName) {
        [self.lblFruitName setFrame:CGRectMake(0, self.fruitImageView.frame.origin.y + self.fruitImageView.frame.size.height, self.frame.size.width, LabelHeight)];
    }
    
    if (self.lblDuration) {
        [self.lblDuration setFrame:CGRectMake(0, self.frame.size.height - LabelHeight, self.frame.size.width, LabelHeight)];
    }
    
    if (self.fruitImageView.center.y > (self.fruitImageView.frame.size.height / 2.0f  + 2 * LabelHeight)) {
        [self.lblFruitName setAlpha:1.0f];
        [self.lblDuration setAlpha:1.0f];
    }else{
        CGFloat tempMargin = (self.fruitImageView.frame.size.height / 2.0f  + 2 * LabelHeight) - self.fruitImageView.center.y;
        if (tempMargin < 10.0f) {
            [self.lblFruitName setAlpha:(10.0f - tempMargin) / 10.0f];
            [self.lblDuration setAlpha:(10.0f - tempMargin) / 10.0f];
        }else{
            [self.lblFruitName setAlpha:0.0f];
            [self.lblDuration setAlpha:0.0f];
        }
    }
}
@end
