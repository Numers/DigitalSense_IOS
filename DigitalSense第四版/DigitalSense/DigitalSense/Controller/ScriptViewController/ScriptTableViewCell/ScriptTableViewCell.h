//
//  ScriptTableViewCell.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Script;
@protocol ScriptTableViewCellProtocol <NSObject>
-(void)playScript:(Script *)script;
@end
@interface ScriptTableViewCell : UITableViewCell
{
    Script *script;
}
@property(nonatomic, strong) IBOutlet UILabel *lblScriptName;
@property(nonatomic, strong) IBOutlet UIButton *btnPlayScript;
@property(nonatomic, assign) id<ScriptTableViewCellProtocol> delagate;

-(void)setupCellWithScript:(Script *)st;
@end
