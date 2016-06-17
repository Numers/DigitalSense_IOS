//
//  ScriptPlayDetailsViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptPlayDetailsViewController.h"
#import "Script.h"
#import "ScriptCommand.h"
#import "ScriptExecuteManager.h"

@interface ScriptPlayDetailsViewController ()
{
    Script *currentScript;
}
@property(nonatomic, strong) IBOutlet UILabel *lblScriptName;
@property(nonatomic, strong) IBOutlet UILabel *lblPlayTime;
@property(nonatomic, strong) IBOutlet UILabel *lblAllTime;
@property(nonatomic, strong) IBOutlet UIProgressView *progressView;
@property(nonatomic, strong) IBOutlet UITextView *textView;
@end

@implementation ScriptPlayDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (currentScript) {
        [self setCurrentScript:currentScript];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registeNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Notification
-(void)registeNotifications
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayScriptNotification object:nil] subscribeNext:^(id x) {
        id obj = [x object];
        if ([obj isKindOfClass:[Script class]]) {
            Script *script = (Script *)obj;
            [self setCurrentScript:script];
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayOverAllScriptsNotification object:nil] subscribeNext:^(id x) {
        [self setCurrentScript:nil];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:PlayProgressSecondNotification object:nil] subscribeNext:^(id x) {
        id obj = [x object];
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *seconds = (NSNumber *)obj;
            float progress;
            if ([seconds integerValue] == 0) {
                progress = 0.0f;
            }else{
                progress = [seconds integerValue] * (1.0f / currentScript.scriptTime);
            }
            [_progressView setProgress:progress];
            [_lblPlayTime setText:[self switchSecondsToTime:[seconds integerValue]]];
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SendScriptCommandNotification object:nil] subscribeNext:^(id x) {
        
    }];
}

#pragma -mark Public Functions
-(void)setCurrentScript:(Script *)script
{
    currentScript = script;
    if (script) {
        [_lblScriptName setText:script.scriptName];
        [_lblAllTime setText:[self switchSecondsToTime:script.scriptTime]];
    }else{
        [_lblScriptName setText:nil];
        [_lblAllTime setText:nil];
        [_lblPlayTime setText:@"00:00:00"];
        [_progressView setProgress:0.0f];
        [_textView setText:nil];
    }
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

#pragma -mark ButtonClickEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
