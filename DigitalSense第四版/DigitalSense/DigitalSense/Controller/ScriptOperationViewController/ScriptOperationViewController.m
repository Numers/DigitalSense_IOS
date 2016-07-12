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

@interface ScriptOperationViewController ()<ScriptSerialViewProtocol>
{
    ScriptSelectViewController *scriptSelectVC;
    ScriptSerialViewController *scriptSerialVC;
}
@end

@implementation ScriptOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    scriptSelectVC = [[ScriptSelectViewController alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 300)];
    [self.view addSubview:scriptSelectVC.view];
    
    scriptSerialVC = [[ScriptSerialViewController alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)];
    scriptSerialVC.delegate = self;
    [self.view addSubview:scriptSerialVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark ButtonEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark ScriptSerialViewProtocol
-(void)selectFruit:(Fruit *)fruit
{
    if (scriptSerialVC) {
        [scriptSelectVC addFruit:fruit];
    }
}
@end
