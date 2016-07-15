//
//  ScriptSelectCollectionViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Fruit;
@protocol ScriptSelectViewProtocol <NSObject>

-(void)scriptCommandTimeDidChanged:(NSInteger)time;

@end
@interface ScriptSelectViewController : UIViewController
{
    CGRect controllerFrame;
}
@property(nonatomic, assign) id<ScriptSelectViewProtocol> delegate;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)addFruit:(Fruit *)fruit;
-(NSMutableArray *)returnAllScriptCommand;
@end
