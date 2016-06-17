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
    if ([self.delagate respondsToSelector:@selector(playScript:)]) {
        [self.delagate playScript:script];
    }
}

-(void)setupCellWithScript:(Script *)st
{
    if (st) {
        script = st;
        [self.lblScriptName setText:script.scriptName];
        if (st.type == ScriptIsAbsoluteTime) {
            [self.btnPlayScript setHidden:YES];
        }
        
        if (st.type == ScriptIsRelativeTime) {
            [self.btnPlayScript setHidden:NO];
        }
        
        if (st.state == ScriptIsNormal) {
            [self.btnPlayScript setTitle:@"播放" forState:UIControlStateNormal];
            [self.btnPlayScript setEnabled:YES];
        }
        
        if (st.state == ScriptIsWaiting) {
            [self.btnPlayScript setTitle:@"排队中" forState:UIControlStateNormal];
            [self.btnPlayScript setEnabled:NO];
        }
        
        if (st.state == ScriptIsPlaying) {
            [self.btnPlayScript setTitle:@"播放中" forState:UIControlStateNormal];
            [self.btnPlayScript setEnabled:NO];
        }
    }
}
@end
