//
//  FullScreenSmellView.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FullScreenSmellView.h"
#import "ScriptCommand.h"
#import "UIColor+HexString.h"
#define LabelHeight 20.0f

@implementation FullScreenSmellView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:3.0f];
        [self.layer setMasksToBounds:YES];
        
        self.lblFruitName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, frame.size.height - LabelHeight)];
        [self.lblFruitName setCenter:CGPointMake(frame.size.width / 2, (frame.size.height - LabelHeight)/2)];
        [self.lblFruitName setTextAlignment:NSTextAlignmentCenter];
        [self.lblFruitName setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self.lblFruitName setNumberOfLines:0];
        [self.lblFruitName setTextColor:[UIColor whiteColor]];
        [self addSubview:self.lblFruitName];
        
        self.lblDuration = [[UILabel alloc] initWithFrame:CGRectMake(0,frame.size.height -  LabelHeight, frame.size.width, LabelHeight)];
        [self.lblDuration setTextAlignment:NSTextAlignmentCenter];
        [self.lblDuration setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.lblDuration setNumberOfLines:0];
        [self.lblDuration setTextColor:[UIColor whiteColor]];
        [self addSubview:self.lblDuration];
    }
    return self;
}

-(void)setScriptCommand:(ScriptCommand *)command
{
    [self setBackgroundColor:[UIColor colorFromHexString:command.color]];
    if (self.lblFruitName) {
        [self.lblFruitName setText:command.desc];
    }
    
    if (self.lblDuration) {
        NSString *durationStr = [NSString stringWithFormat:@"%lds",(long)command.duration];
        [self.lblDuration setText:durationStr];
    }
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    CGContextSetLineWidth(context, 0.5f);
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0f);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 0, self.frame.size.height);
    
    CGContextAddLineToPoint(context, 0, 0);
    
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    
    CGContextStrokePath(context);
    
    if (self.lblFruitName) {
//        [self.lblFruitName setFrame:CGRectMake(0, 0, 20, self.frame.size.height - LabelHeight)];
        [self.lblFruitName setCenter:CGPointMake(self.frame.size.width / 2, (self.frame.size.height - LabelHeight)/2)];
    }
    
    if (self.lblDuration) {
//        [self.lblDuration setFrame:CGRectMake(0, self.frame.size.height -  LabelHeight, self.frame.size.width, LabelHeight)];
        [self.lblDuration setFrame:CGRectMake(0, self.frame.size.height - LabelHeight, self.frame.size.width, LabelHeight)];
    }
}
@end
