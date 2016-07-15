//
//  UINavigationController+UIInterfaceOrientations.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/14.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "UINavigationController+UIInterfaceOrientations.h"

@implementation UINavigationController (UIInterfaceOrientations)
- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}
@end
