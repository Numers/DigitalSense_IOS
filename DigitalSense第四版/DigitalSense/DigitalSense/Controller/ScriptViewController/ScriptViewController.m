//
//  ScriptViewController.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptViewController.h"
#import "ScriptTableViewCell.h"
#import "Script.h"

#import "ScriptExecuteManager.h"

static NSString *cellIdentify = @"ScriptTableViewCellIdentify";
@interface ScriptViewController ()<ScriptTableViewCellProtocol,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *scriptList;
}
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ScriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scriptList = [NSMutableArray array];
    
    /**************************假数据***************************/
    Script *script = [[Script alloc] init];
    script.scriptId = @"1";
    script.scriptName = @"魔兽";
    script.scriptTime = 10;
    script.scriptContent = @"";
    script.state = ScriptIsNormal;
    script.type = ScriptIsRelativeTime;
    [scriptList addObject:script];
    
    Script *script1 = [[Script alloc] init];
    script1.scriptId = @"1";
    script1.scriptName = @"魔兽";
    script1.scriptTime = 10;
    script1.scriptContent = @"";
    script1.state = ScriptIsNormal;
    script1.type = ScriptIsRelativeTime;
    [scriptList addObject:script1];
    
    Script *script2 = [[Script alloc] init];
    script2.scriptId = @"1";
    script2.scriptName = @"魔兽";
    script2.scriptTime = 10;
    script2.scriptContent = @"";
    script2.state = ScriptIsNormal;
    script2.type = ScriptIsRelativeTime;
    [scriptList addObject:script2];
    
    Script *script3 = [[Script alloc] init];
    script3.scriptId = @"1";
    script3.scriptName = @"魔兽";
    script3.scriptTime = 10;
    script3.scriptContent = @"";
    script3.state = ScriptIsNormal;
    script3.type = ScriptIsRelativeTime;
    [scriptList addObject:script3];
    
    Script *script4 = [[Script alloc] init];
    script4.scriptId = @"1";
    script4.scriptName = @"魔兽";
    script4.scriptTime = 10;
    script4.scriptContent = @"";
    script4.state = ScriptIsNormal;
    script4.type = ScriptIsRelativeTime;
    [scriptList addObject:script4];
    /************************************************************/
    [self.tableView registerNib:[UINib nibWithNibName:@"ScriptTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentify];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scriptStateComfirmed:) name:ScriptStateComfirmed object:nil];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Notificaiton
-(void)scriptStateComfirmed:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma -mark ButtonEvent
-(IBAction)clickBackBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma -mark UITableViewDelegate And UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return scriptList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    cell.delagate = self;
    if (cell) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                Script *script = [scriptList objectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setupCellWithScript:script];
                });
            }
        });
    }else{
        return [UITableViewCell new];
    }
    return cell;
}
#pragma -mark ScriptTableViewCellProtocol
-(void)playScript:(Script *)script
{
    if (script) {
        if (script.type == ScriptIsRelativeTime) {
            [[ScriptExecuteManager defaultManager] executeRelativeTimeScript:script];
        }
    }
}
@end
