//
//  IflyRecognizerManager.m
//  FruitCut
//
//  Created by baolicheng on 16/5/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "IflyRecognizerManager.h"
#import <iflyMSC/IFlyRecognizerView.h>
#import <iflyMSC/IFlySpeechRecognizer.h>
#import <iflyMSC/IFlyDataUploader.h>
#import <iflyMSC/IFlyUserWords.h>
#import <iflyMSC/IFlySpeechUtility.h>
#import <iflyMSC/IFlySpeechConstant.h>
#define GRAMMAR_TYPE_BNF     @"bnf"
#define GRAMMAR_TYPE_ABNF    @"abnf"
#define IFLYDOMAIN @"asr" //识别模式 iat/语音识别  asr/在线语法识别

#define OnlineGrammarIDKey @"ONLINEGRAMMERIDKEY"
static IflyRecognizerManager *iFlyRecognizerManager;
static IFlyRecognizerView *iFlyRecognizerView;
@implementation IflyRecognizerManager
+(id)defaultManager
{
    if(iFlyRecognizerManager == nil)
    {
        iFlyRecognizerManager = [[IflyRecognizerManager alloc] init];
        
        [self initRecognizerView];
    }
    return iFlyRecognizerManager;
}

+(void)initRecognizerView
{
    iFlyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:[UIApplication sharedApplication].keyWindow.center];
    iFlyRecognizerView.delegate = iFlyRecognizerManager;
    
    //设置识别模式
    [iFlyRecognizerView setParameter:IFLYDOMAIN forKey:[IFlySpeechConstant IFLY_DOMAIN]];
}

-(void)startRecognizer:(IFlyRecognizerCallback)callback
{
    recogniserCallback = callback;
    tempResult = [[NSMutableString alloc] init];
    
    [iFlyRecognizerView setParameter:IFLYDOMAIN forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //设置结果数据格式，可设置为json，xml，plain，默认为json。
    [iFlyRecognizerView setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    NSString *grammarId = [[NSUserDefaults standardUserDefaults] objectForKey:OnlineGrammarIDKey];
    if (grammarId) {
        //设置字符编码
        [iFlyRecognizerView setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
        [iFlyRecognizerView setParameter:grammarId forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
    }else{
        [iFlyRecognizerManager buildGrammer];
    }
    
    [iFlyRecognizerView start];
}

-(void)stopRecongnizer
{
    [iFlyRecognizerView cancel];
    [iFlyRecognizerView setDelegate:nil];
}

#pragma -mark 构建语法上传
/**
 文件读取
 *****/
-(NSString *)readFile:(NSString *)filePath
{
    NSData *reader = [NSData dataWithContentsOfFile:filePath];
    return [[NSString alloc] initWithData:reader encoding:NSUTF8StringEncoding];
}

/**
 构建语法
 ****/
-(void) buildGrammer
{
    NSString *grammarContent = nil;
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    
    //读取abnf内容
    NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/grammar_sample.abnf",appPath];
    grammarContent = [self readFile:bnfFilePath];
    
//    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc] initWithJson:grammarContent];
//    NSLog(@"%@",[iFlyUserWords toString]);
//    
//    IFlyDataUploader *uploader = [[IFlyDataUploader alloc] init];
//    [uploader setParameter:IFLYDOMAIN forKey:@"sub"];
//    [uploader setParameter:GRAMMAR_TYPE_ABNF forKey:@"dtt"];
//    [uploader uploadDataWithCompletionHandler:^(NSString *result, IFlySpeechError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            if (![error errorCode]) {
//                
//                NSLog(@"上传成功! errorCode=%d",[error errorCode]);
//                //设置grammarid
//                [[NSUserDefaults standardUserDefaults] setObject:result forKey:OnlineGrammarIDKey];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                if (iFlyRecognizerView) {
//                    //设置字符编码
//                    [iFlyRecognizerView setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
//                    [iFlyRecognizerView setParameter:result forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
//                }
//            }
//            else {
//                NSLog(@"上传失败");
//            }
//        });
//    } name:GRAMMAR_TYPE_ABNF data:[iFlyUserWords toString]];
    //开始构建
        [[IFlySpeechRecognizer sharedInstance] buildGrammarCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
    
            dispatch_async(dispatch_get_main_queue(), ^{
    
                if (![error errorCode]) {
    
                    NSLog(@"上传成功! errorCode=%d",[error errorCode]);
                    [[NSUserDefaults standardUserDefaults] setObject:grammerID forKey:OnlineGrammarIDKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //设置grammarid
                    if (iFlyRecognizerView) {
                        //设置字符编码
                        [iFlyRecognizerView setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
                        [iFlyRecognizerView setParameter:grammerID forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
                    }
                }
                else {
                    NSLog(@"上传失败");
                }
//                [[IFlySpeechRecognizer sharedInstance] destroy];
            });
    
        }grammarType:GRAMMAR_TYPE_ABNF grammarContent:grammarContent];
}

#pragma mark IFlyRecognizerViewDelegate

/** 识别结果回调方法
 @param resultArray 结果列表
 @param isLast YES 表示最后一个，NO表示后面还有结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [tempResult appendFormat:@"%@",key];
    }
    if (isLast) {
        if (recogniserCallback) {
            recogniserCallback([NSString stringWithString:tempResult]);
        }
    }
}

/** 识别结束回调方法
 @param error 识别错误
 */
- (void)onError:(IFlySpeechError *)error
{
    NSLog(@"errorCode:%d",[error errorCode]);
}

@end
