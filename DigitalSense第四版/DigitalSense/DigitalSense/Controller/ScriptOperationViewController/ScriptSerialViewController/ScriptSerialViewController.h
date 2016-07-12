//
//  ScriptSerialCollectionViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Fruit;
@protocol ScriptSerialViewProtocol <NSObject>
-(void)selectFruit:(Fruit *)fruit;
@end
@interface ScriptSerialViewController : UIViewController
{
    CGRect controllerFrame;
}
@property(nonatomic, assign) id<ScriptSerialViewProtocol> delegate;
-(instancetype)initWithFrame:(CGRect)frame;
@end
