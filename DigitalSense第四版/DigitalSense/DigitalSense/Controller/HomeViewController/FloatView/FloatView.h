//
//  FloatView.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/18.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FloatViewProtocol <NSObject>
-(void)didTapView;
@end
@interface FloatView : UIView
{
    UITapGestureRecognizer *tapGesture;
    CGFloat TopAndBottomPADDING;
    CGFloat LeftAndRightPADDING;
}
@property(nonatomic, assign) id<FloatViewProtocol> delegate;
@property(nonatomic,assign,getter = isDragEnable)   BOOL dragEnable;
@property(nonatomic,assign,getter = isAdsorbEnable) BOOL adsorbEnable;
@end
