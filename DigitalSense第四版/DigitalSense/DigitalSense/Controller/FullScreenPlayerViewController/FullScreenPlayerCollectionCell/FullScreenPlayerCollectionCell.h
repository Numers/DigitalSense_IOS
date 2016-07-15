//
//  FullScreenPlayerCollectionCell.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FullScreenSmellView,ScriptCommand;
@interface FullScreenPlayerCollectionCell : UICollectionViewCell
{
    FullScreenSmellView *smellView;
}

-(void)setScriptCommand:(ScriptCommand *)scriptCommand;
@end
