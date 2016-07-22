//
//  FloatView.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/18.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FloatView.h"
#import <objc/runtime.h>
static void *DragEnableKey = &DragEnableKey;
static void *AdsorbEnableKey = &AdsorbEnableKey;
@implementation FloatView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor colorWithRed:0.127 green:0.568 blue:0.730 alpha:1.000]];
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
        [self addGestureRecognizer:tapGesture];
        [self changeFrame:frame];
    }
    return self;
}

-(void)tapView
{
    if ([self.delegate respondsToSelector:@selector(didTapView)]) {
        [self.delegate didTapView];
    }
}

-(void)fullScreenViewMargin
{
    TopAndBottomPADDING = 0.0f;
    LeftAndRightPADDING = 0.0f;
}

-(void)smallScreenViewMargin
{
    TopAndBottomPADDING = 40.0f;
    LeftAndRightPADDING = 0.0f;
}

-(void)changeFrame:(CGRect)frame
{
    [self setFrame:frame];
    if (frame.size.width == [UIScreen mainScreen].bounds.size.width) {
        [self fullScreenViewMargin];
        [self setDragEnable:NO];
        [self setAdsorbEnable:NO];
    }else{
        [self smallScreenViewMargin];
        [self fullScreenViewMargin];
        [self setDragEnable:YES];
        [self setAdsorbEnable:YES];
    }
}

-(void)setDragEnable:(BOOL)dragEnable
{
    objc_setAssociatedObject(self, DragEnableKey,@(dragEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isDragEnable
{
    return [objc_getAssociatedObject(self, DragEnableKey) boolValue];
}

-(void)setAdsorbEnable:(BOOL)adsorbEnable
{
    objc_setAssociatedObject(self, AdsorbEnableKey,@(adsorbEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isAdsorbEnable
{
    return [objc_getAssociatedObject(self, AdsorbEnableKey) boolValue];
}

CGPoint beginPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![objc_getAssociatedObject(self, DragEnableKey) boolValue]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    beginPoint = [touch locationInView:self];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![objc_getAssociatedObject(self, DragEnableKey) boolValue]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
    
    self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview && [objc_getAssociatedObject(self,AdsorbEnableKey) boolValue] ) {
        float marginLeft = self.frame.origin.x;
        float marginRight = self.superview.frame.size.width - self.frame.origin.x - self.frame.size.width;
        float marginTop = self.frame.origin.y;
        float marginBottom = self.superview.frame.size.height - self.frame.origin.y - self.frame.size.height;
        [UIView animateWithDuration:0.125 animations:^(void){
            if (marginTop<60) {
                self.frame = CGRectMake(marginLeft<marginRight?marginLeft<LeftAndRightPADDING?LeftAndRightPADDING:self.frame.origin.x:marginRight<LeftAndRightPADDING?self.superview.frame.size.width -self.frame.size.width-LeftAndRightPADDING:self.frame.origin.x,
                                        TopAndBottomPADDING,
                                        self.frame.size.width,
                                        self.frame.size.height);
            }
            else if (marginBottom<60) {
                self.frame = CGRectMake(marginLeft<marginRight?marginLeft<LeftAndRightPADDING?LeftAndRightPADDING:self.frame.origin.x:marginRight<LeftAndRightPADDING?self.superview.frame.size.width -self.frame.size.width-LeftAndRightPADDING:self.frame.origin.x,
                                        self.superview.frame.size.height - self.frame.size.height-TopAndBottomPADDING,
                                        self.frame.size.width,
                                        self.frame.size.height);
                
            }
            else {
                self.frame = CGRectMake(marginLeft<marginRight?LeftAndRightPADDING:self.superview.frame.size.width - self.frame.size.width-LeftAndRightPADDING,
                                        self.frame.origin.y,
                                        self.frame.size.width,
                                        self.frame.size.height);
                
            }
        }];
        
    }
}
@end
