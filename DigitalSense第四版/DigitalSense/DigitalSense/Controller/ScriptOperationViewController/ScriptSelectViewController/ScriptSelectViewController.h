//
//  ScriptSelectCollectionViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Fruit;
@interface ScriptSelectViewController : UIViewController
{
    CGRect controllerFrame;
}

-(instancetype)initWithFrame:(CGRect)frame;
-(void)addFruit:(Fruit *)fruit;
@end
