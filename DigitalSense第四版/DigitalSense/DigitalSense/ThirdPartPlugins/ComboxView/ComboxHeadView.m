//
//  ComboxHeadView.m
//  DigitalSense
//
//  Created by baolicheng on 16/8/1.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ComboxHeadView.h"
#define ScanButtonSize CGSizeMake(150,44)
@implementation ComboxHeadView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        _btnRescan = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setScanBtnNormalState];
        [self addSubview:_btnRescan];
        
    }
    return self;
}

-(void)setScanBtnNormalState
{
    [_btnRescan setBackgroundColor:[UIColor lightGrayColor]];
    [_btnRescan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setRescanBtn:@"重新搜索" WithImage:[UIImage imageNamed:@"RefreshImage_Normal"]];
    [_btnRescan setEnabled:YES];
}

-(void)setScanBtnSearchState
{
    [_btnRescan setBackgroundColor:[UIColor grayColor]];
    [_btnRescan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setRescanBtn:@"正在搜索" WithImage:[UIImage imageNamed:@"RefreshImage_Normal"]];
    [_btnRescan setEnabled:NO];
}

-(void)setRescanBtn:(NSString *)title WithImage:(UIImage *)image
{
    //让按钮左标题，右图片
    if (title) {
        CGFloat fontSize = [UIDevice adaptTextFontSizeWithIphone5FontSize:14.0f IsBold:YES];
        [_btnRescan.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
        CGRect rect = [title boundingRectWithSize:CGSizeMake(300, 21) options:0 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]} context:nil];
        [_btnRescan setImageEdgeInsets:UIEdgeInsetsMake(0, rect.size.width + 5, 0, -rect.size.width - 5)];
    }else{
        [_btnRescan setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if (image) {
        [_btnRescan setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width)];
    }else{
        [_btnRescan setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    [_btnRescan setFrame:CGRectMake(self.frame.size.width - ScanButtonSize.width - 5, (self.frame.size.height - ScanButtonSize.height) / 2.0f, ScanButtonSize.width, ScanButtonSize.height)];
    [_btnRescan setTitle:title forState:UIControlStateNormal];
    [_btnRescan setImage:image forState:UIControlStateNormal];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
