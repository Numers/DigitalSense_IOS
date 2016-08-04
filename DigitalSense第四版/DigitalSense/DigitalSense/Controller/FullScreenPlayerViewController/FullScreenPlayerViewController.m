//
//  FullScreenPlayerViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/7/14.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FullScreenPlayerViewController.h"
#import "RelativeTimeScript.h"
#import "FullScreenPlayerCollectionCell.h"
#import "ScriptExecuteManager.h"

#define DefaultCellWidthPersecond 15.0f

@interface FullScreenPlayerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UIView *lineView;
    RelativeTimeScript *currentScript;
    BOOL isLoop;
    BOOL needLoop;
}
@property(nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property(nonatomic, strong) IBOutlet UIButton *btnLoop;
@property(nonatomic, strong) IBOutlet UILabel *lblPlayTime;
@property(nonatomic, strong) IBOutlet UIProgressView *progressView;
@property(nonatomic, strong) IBOutlet UIView *playView;

@property(nonatomic, strong) IBOutlet UITextField *txtDescription;
@end

@implementation FullScreenPlayerViewController
static NSString *const cellIdentify = @"FullScreenCollectionCellIdentify";

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *backgroundImage = [UIImage imageNamed:@"OperationBackgroundViewImage"];
    self.view.layer.contents = (id)backgroundImage.CGImage;
    
    UIImage *playViewBackgroundImage = [UIImage imageNamed:@"Player_BackgroundViewImage"];
    _playView.layer.contents = (id)playViewBackgroundImage.CGImage;
    // Do any additional setup after loading the view.
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.view.bounds = CGRectMake(0, 0, screenSize.height, screenSize.width);
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, 1, _collectionView.frame.size.height)];
    [lineView setBackgroundColor:[UIColor blackColor]];
    [self.view insertSubview:lineView aboveSubview:self.collectionView];
    
    [self.collectionView registerClass:[FullScreenPlayerCollectionCell class] forCellWithReuseIdentifier:cellIdentify];
    
    [self setIsLoop:isLoop];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self playScript];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate{
    return NO;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma -mark public function
-(void)setScript:(RelativeTimeScript *)script IsLoop:(BOOL)loop
{
    currentScript = script;
    [self setIsLoop:loop];
}

#pragma -mark private funcion
-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginPalyScript:) name:PlayScriptNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playOverScript:) name:PlayOverScriptNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendScriptCommandNotify:) name:SendScriptCommandNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressChangedNotify:) name:PlayProgressSecondNotification object:nil];
}

-(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger minite = (seconds - second) / 60;
    NSString *result;
    if (minite < 10) {
        result = [NSString stringWithFormat:@"%02ld:%02ld",minite,second];
    }else{
        result = [NSString stringWithFormat:@"%ld:%02ld",minite,second];
    }
    return result;
}

//-(void)showSize
//{
//    NSLog(@"%lf,%lf",_progressView.frame.size.width,_progressView.frame.size.height);
//    NSLog(@"%lf,%lf",_collectionView.frame.size.width,_collectionView.frame.size.height);
//}

-(void)inilizedUIView
{
    
    if (currentScript) {
        NSString *desc = [NSString stringWithFormat:@"00:00 / %@",[self switchSecondsToTime:currentScript.scriptTime]];
        [_lblPlayTime setText:desc];
    }else{
        [_lblPlayTime setText:@"00:00 / 00:00"];
    }
    [_progressView setProgress:0.0f];
    
    [lineView setFrame:CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, lineView.frame.size.width, _collectionView.frame.size.height)];
    
    needLoop = YES;
}

-(void)setIsLoop:(BOOL)loop
{
    isLoop = loop;
    if (_btnLoop) {
        if (loop) {
            [_btnLoop setBackgroundImage:[UIImage imageNamed:@"Player_Repeat"] forState:UIControlStateNormal];
        }else{
            [_btnLoop setBackgroundImage:[UIImage imageNamed:@"Player_Once"] forState:UIControlStateNormal];
        }
    }
}

-(void)playScript
{
    if (currentScript) {
        [[ScriptExecuteManager defaultManager] cancelAllScripts];
        [[ScriptExecuteManager defaultManager] executeRelativeTimeScript:currentScript];
    }
}

-(CGFloat)calculateCellWithPersecond
{
    CGFloat lineWidthForSecond = DefaultCellWidthPersecond;
    if (currentScript) {
        if (lineWidthForSecond * currentScript.scriptTime < _collectionView.frame.size.width) {
            lineWidthForSecond = _collectionView.frame.size.width / currentScript.scriptTime;
        }
    }
    return lineWidthForSecond;
}

#pragma -mark Notifications
-(void)beginPalyScript:(NSNotification *)notify
{
    RelativeTimeScript *script = [notify object];
    if (currentScript) {
        if ([currentScript isEqual:script]) {
            [self inilizedUIView];
        }
    }
}

-(void)playOverScript:(NSNotification *)notify
{
    RelativeTimeScript *script = [notify object];
    if (currentScript) {
        if ([currentScript isEqual:script]) {
            [_txtDescription setText:nil];
            if (isLoop) {
                if (needLoop) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[ScriptExecuteManager defaultManager] executeRelativeTimeScript:currentScript];
                    });
                }
            }else{
                if([[NSThread currentThread] isMainThread]){
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }
        }
    }
}

-(void)sendScriptCommandNotify:(NSNotification *)notify
{
    ScriptCommand *scriptCommand = [notify object];
    NSString *desc = [NSString stringWithFormat:@"正在播放%@",scriptCommand.smellName];
    [_txtDescription setText:desc];
}

-(void)progressChangedNotify:(NSNotification *)notify
{
    NSNumber *seconds = [notify object];
    if (currentScript) {
        CGFloat progress = 1.0f * [seconds integerValue] / currentScript.scriptTime;
        [_progressView setProgress:progress animated:NO];
        
        NSString *desc = [NSString stringWithFormat:@"%@ / %@",[self switchSecondsToTime:[seconds integerValue]],[self switchSecondsToTime:currentScript.scriptTime]];
        [_lblPlayTime setText:desc];
        
        CGFloat lineViewSpeed = _collectionView.frame.size.width / currentScript.scriptTime;
        CGFloat linewidth = [self calculateCellWithPersecond];
        CGFloat scrollSpeed = linewidth - lineViewSpeed;
        
        [lineView setFrame:CGRectMake([seconds integerValue] * lineViewSpeed + _collectionView.frame.origin.x, lineView.frame.origin.y, lineView.frame.size.width, lineView.frame.size.height)];
//        [UIView animateWithDuration:0.1 animations:^{
//            [lineView setFrame:CGRectMake([seconds integerValue] * lineViewSpeed + _collectionView.frame.origin.x, lineView.frame.origin.y, lineView.frame.size.width, lineView.frame.size.height)];
//        }];
        
        if (scrollSpeed > 0) {
            [_collectionView setContentOffset:CGPointMake([seconds integerValue] * scrollSpeed, 0) animated:YES];
        }
    }
}
#pragma -mark ButtonEvent
-(IBAction)clickStopPlayBtn:(id)sender
{
    needLoop = NO;
    if (currentScript) {
        [[ScriptExecuteManager defaultManager] cancelExecuteRelativeTimeScript:currentScript];
    }
}

#pragma -mark 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return currentScript.scriptCommandList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FullScreenPlayerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentify forIndexPath:indexPath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ScriptCommand *scriptCommand = [currentScript.scriptCommandList objectAtIndex:indexPath.item];
       dispatch_async(dispatch_get_main_queue(), ^{
           [cell setScriptCommand:scriptCommand];
       });
    });
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    ScriptCommand *command = [currentScript.scriptCommandList objectAtIndex:indexPath.item];
    CGFloat linewidth = [self calculateCellWithPersecond];
    CGFloat width = linewidth * command.duration;
    
    CGFloat height = collectionView.frame.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
@end
