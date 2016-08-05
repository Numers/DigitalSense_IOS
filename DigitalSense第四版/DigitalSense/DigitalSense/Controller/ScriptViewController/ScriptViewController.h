//
//  ScriptViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ScriptViewProtocol <NSObject>
-(void)stopCurrentSmell;
@end
@interface ScriptViewController : UIViewController
@property(nonatomic, assign) id<ScriptViewProtocol> delegate;
-(void)setMacAddress:(NSString *)macAddr WithFruitList:(NSArray *)list;
@end
