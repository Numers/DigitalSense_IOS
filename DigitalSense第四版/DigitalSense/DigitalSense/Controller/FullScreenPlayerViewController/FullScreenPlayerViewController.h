//
//  FullScreenPlayerViewController.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/14.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RelativeTimeScript;
@interface FullScreenPlayerViewController : UIViewController
-(void)setScript:(RelativeTimeScript *)script IsLoop:(BOOL)loop;
@end
