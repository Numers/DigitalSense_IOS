//
//  FullScreenSmellView.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenSmellView : UIView
@property(nonatomic, strong) UILabel *lblFruitName;
@property(nonatomic, strong) UILabel *lblDuration;
-(void)setFruitName:(NSString *)name WithDuration:(NSInteger)duration;
@end
