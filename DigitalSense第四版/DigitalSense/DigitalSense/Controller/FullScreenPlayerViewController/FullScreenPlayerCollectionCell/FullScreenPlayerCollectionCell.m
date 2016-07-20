//
//  FullScreenPlayerCollectionCell.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FullScreenPlayerCollectionCell.h"
#import "FullScreenSmellView.h"
#import "ScriptCommand.h"
@implementation FullScreenPlayerCollectionCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setShadowColor:[UIColor colorWithWhite:0.f alpha:0.2f].CGColor];
        [self.layer setShadowOffset:CGSizeMake(0, 5)];
        [self.layer setShadowOpacity:1.0f];
        smellView = [[FullScreenSmellView alloc] initWithFrame:CGRectMake(0, frame.size.height  / 2.0f, frame.size.width, frame.size.height  / 2.0f)];
        [self.contentView addSubview:smellView];
    }
    return self;
}

-(void)setScriptCommand:(ScriptCommand *)scriptCommand
{
    if (smellView) {
        [smellView setScriptCommand:scriptCommand];
        [smellView setFrame:CGRectMake(smellView.frame.origin.x, self.frame.size.height * (1 - scriptCommand.power), self.frame.size.width, self.frame.size.height * scriptCommand.power)];
    }else{
        smellView = [[FullScreenSmellView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * (1 - scriptCommand.power), self.frame.size.width, self.frame.size.height * scriptCommand.power)];
        [smellView setScriptCommand:scriptCommand];
        [self.contentView addSubview:smellView];
    }
    [smellView setNeedsDisplay];
}
@end
