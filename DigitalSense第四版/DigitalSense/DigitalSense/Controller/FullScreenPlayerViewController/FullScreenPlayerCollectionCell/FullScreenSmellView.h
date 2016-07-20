//
//  FullScreenSmellView.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScriptCommand;
@interface FullScreenSmellView : UIView
@property(nonatomic, strong) UILabel *lblFruitName;
@property(nonatomic, strong) UILabel *lblDuration;
-(void)setScriptCommand:(ScriptCommand *)command;
@end
