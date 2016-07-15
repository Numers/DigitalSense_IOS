//
//  ScriptOperationViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/6.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptOperationViewController.h"
#import "ScriptSelectViewController.h"
#import "ScriptSerialViewController.h"

#import "UINavigationController+WXSTransition.h"
#import "FullScreenPlayerViewController.h"
#import "ScriptCommand.h"
#import "RelativeTimeScript.h"

@interface ScriptOperationViewController ()<ScriptSerialViewProtocol,ScriptSelectViewProtocol>
{
    ScriptSelectViewController *scriptSelectVC;
    ScriptSerialViewController *scriptSerialVC;
    
    BOOL isLoop;
    
    RelativeTimeScript *currentScript;
}
@property(nonatomic, strong) IBOutlet UIView *playView;
@property(nonatomic, strong) IBOutlet UILabel *lblAllTime;
@property(nonatomic, strong) IBOutlet UIButton *btnLoop;
@end

@implementation ScriptOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    scriptSelectVC = [[ScriptSelectViewController alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, (screenSize.height - _playView.frame.size.height - 64) * 2 / 3.0f)];
    scriptSelectVC.delegate = self;
    [self.view addSubview:scriptSelectVC.view];
    
    scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (screenSize.height - _playView.frame.size.height - 64) / 3.0f, self.view.frame.size.width, (screenSize.height - _playView.frame.size.height - 64) / 3.0f)];
    scriptSerialVC.delegate = self;
    [self.view addSubview:scriptSerialVC.view];
    
    [self.view bringSubviewToFront:_playView];
    
    [self setIsLoop:YES];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_playView setFrame:CGRectMake(_playView.frame.origin.x, scriptSelectVC.view.frame.origin.y + scriptSelectVC.view.frame.size.height, _playView.frame.size.width, _playView.frame.size.height)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

#pragma -mark private Functions
-(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger tempMinite = (seconds - second) / 60;
    NSInteger minite = tempMinite % 60;
    NSInteger hour = tempMinite / 60;
    NSString *result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minite,second];
    return result;
}

-(NSInteger)doWithScriptCommandList:(NSArray *)scriptCommandList
{
    if (scriptCommandList.count == 0) {
        return 0;
    }
    NSInteger allTime = 0;
    ScriptCommand *previousCommand = nil;
    for (ScriptCommand *command in scriptCommandList) {
        if (previousCommand == nil) {
            command.startRelativeTime = 0;
        }else{
            command.startRelativeTime = previousCommand.startRelativeTime + previousCommand.duration;
        }
        //组成command命令
        command.command = @"";
        previousCommand = command;
        allTime = allTime + command.duration;
    }
    return allTime;
}

-(void)setIsLoop:(BOOL)loop
{
    isLoop = loop;
    if (loop) {
        [_btnLoop setImage:[UIImage imageNamed:@"Player_Repeat"] forState:UIControlStateNormal];
    }else{
        [_btnLoop setImage:[UIImage imageNamed:@"Player_Once"] forState:UIControlStateNormal];
    }
}

#pragma -mark ButtonEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)clickPlayBtn:(id)sender
{
    FullScreenPlayerViewController *fullScreenPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FullScreenPlayerViewIdentify"];
    RelativeTimeScript *script = [[RelativeTimeScript alloc] init];
    script.scriptId = @"10000";
    script.scriptName = @"自定义脚本";
    script.sceneName = @"气味王国";
    script.state =  ScriptIsNormal;
    script.type =  ScriptIsRelativeTime;
    script.isLoop = NO;
    NSMutableArray *scriptCommandList = [scriptSelectVC returnAllScriptCommand];
    script.scriptTime = [self doWithScriptCommandList:scriptCommandList];
    script.scriptCommandList = scriptCommandList;
    fullScreenPlayerVC.startView = _playView;
    currentScript = script;
    [fullScreenPlayerVC setScript:script IsLoop:isLoop];
    [self.navigationController wxs_pushViewController:fullScreenPlayerVC makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType = WXSTransitionAnimationTypeFragmentShowFromRight;
        transition.animationTime = 1.0f;
        transition.backGestureEnable = NO;
    }];
}

-(IBAction)clickLoopBtn:(id)sender
{
    if (isLoop) {
        [self setIsLoop:NO];
    }else{
        [self setIsLoop:YES];
    }
}

#pragma -mark ScriptSerialViewProtocol
-(void)selectFruit:(Fruit *)fruit
{
    if (scriptSerialVC) {
        [scriptSelectVC addFruit:fruit];
    }
}

#pragma -mark ScriptSelectViewProtocol
-(void)scriptCommandTimeDidChanged:(NSInteger)time
{
    NSString *timeStr = [self switchSecondsToTime:time];
    [_lblAllTime setText:timeStr];
}
@end
