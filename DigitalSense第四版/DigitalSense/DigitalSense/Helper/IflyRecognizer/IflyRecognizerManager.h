//
//  IflyRecognizerManager.h
//  FruitCut
//
//  Created by baolicheng on 16/5/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iflyMSC/IFlyRecognizerViewDelegate.h>
typedef void (^IFlyRecognizerCallback) (NSString *result);
@class IFlyRecognizerView;
@interface IflyRecognizerManager : NSObject<IFlyRecognizerViewDelegate>
{
    NSMutableString *tempResult;
    IFlyRecognizerCallback recogniserCallback;
}
+(id)defaultManager;

-(void)startRecognizer:(NSString *)grammarContent Callback:(IFlyRecognizerCallback)callback;

-(void)stopRecongnizer;
@end
