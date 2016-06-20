//
//  ScriptTableViewCell.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptTableViewCell.h"
#import "Script.h"

@implementation ScriptTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)clickPlayScriptBtn:(id)sender
{
    if (script.state == ScriptIsNormal) {
        if ([self.delagate respondsToSelector:@selector(playScript:)]) {
            [self.delagate playScript:script];
        }
    }else if (script.state == ScriptIsWaiting) {
        if ([self.delagate respondsToSelector:@selector(cancelInline:)]) {
            [self.delagate cancelInline:script];
        }
    }
}

-(void)setupCellWithScript:(Script *)st
{
    if (st) {
        script = st;
        [self.lblScriptName setText:script.scriptName];
        if (st.type == ScriptIsAbsoluteTime) {
            [self.btnPlayScript setHidden:YES];
            [self.lblAllTime setText:nil];
            [self.lblProgress setText:st.sceneName];
            [self.progressView setProgress:0.0f];
            return;
        }
        
        if (st.type == ScriptIsRelativeTime) {
            [self.btnPlayScript setHidden:NO];
        }
        
        if (st.state == ScriptIsNormal) {
            [self.btnPlayScript setTitle:@"播放" forState:UIControlStateNormal];
            [self.btnPlayScript setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.btnPlayScript setBackgroundImage:[UIImage imageNamed:@"ScriptNormalBtn_Normal"] forState:UIControlStateNormal];
            [self.btnPlayScript setEnabled:YES];
            [_progressView setProgress:0.0f];
        }
        
        if (st.state == ScriptIsWaiting) {
            [self.btnPlayScript setTitle:@"取消排队" forState:UIControlStateNormal];
            [self.btnPlayScript setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.btnPlayScript setBackgroundImage:[UIImage imageNamed:@"ScriptWaitingBtn_Normal"] forState:UIControlStateNormal];
            [self.btnPlayScript setEnabled:YES];
            [_progressView setProgress:0.0f];
        }
        
        if (st.state == ScriptIsPlaying) {
            [self.btnPlayScript setTitle:@"播放中" forState:UIControlStateNormal];
            [self.btnPlayScript setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.btnPlayScript setBackgroundImage:[UIImage imageNamed:@"ScriptPlayingBtn_Normal"] forState:UIControlStateNormal];
            [self.btnPlayScript setEnabled:NO];
        }
        
        [_lblProgress setText:@"进度 00:00:00"];
        [_lblAllTime setText:[NSString stringWithFormat:@"总时长 %@",[self switchSecondsToTime:st.scriptTime]]];
    }
}

-(void)setProgressSecond:(NSInteger)seconds
{
    float progress;
    if (seconds == 0) {
        progress = 0.0f;
    }else{
        progress = seconds * (1.0f / script.scriptTime);
    }
    [_progressView setProgress:progress];
    [_lblProgress setText:[NSString stringWithFormat:@"进度 %@",[self switchSecondsToTime:seconds]]];
}

-(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger tempMinite = (seconds - second) / 60;
    NSInteger minite = tempMinite % 60;
    NSInteger hour = tempMinite / 60;
    NSString *result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,minite,second];
    return result;
}
@end
