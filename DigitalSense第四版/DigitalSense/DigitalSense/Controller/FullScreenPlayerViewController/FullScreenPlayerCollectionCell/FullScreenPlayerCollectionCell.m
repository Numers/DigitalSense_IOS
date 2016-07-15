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
        smellView = [[FullScreenSmellView alloc] initWithFrame:CGRectMake(0, frame.size.height  / 2.0f, frame.size.width, frame.size.height  / 2.0f)];
        [self.contentView addSubview:smellView];
    }
    return self;
}

-(void)setScriptCommand:(ScriptCommand *)scriptCommand
{
    if (smellView) {
        [smellView setFruitName:scriptCommand.desc WithDuration:scriptCommand.duration];
        [smellView setFrame:CGRectMake(smellView.frame.origin.x, self.frame.size.height * (1 - scriptCommand.power), self.frame.size.width, self.frame.size.height * scriptCommand.power)];
    }else{
        smellView = [[FullScreenSmellView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * (1 - scriptCommand.power), self.frame.size.width, self.frame.size.height * scriptCommand.power)];
        [smellView setFruitName:scriptCommand.desc WithDuration:scriptCommand.duration];
        [self.contentView addSubview:smellView];
    }
    [smellView setNeedsDisplay];
}
@end
