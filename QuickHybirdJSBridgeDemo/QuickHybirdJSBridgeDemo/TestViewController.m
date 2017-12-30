//
//  TestViewController.m
//  QuickHybirdJSBridgeDemo
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "TestViewController.h"
#import "QHBaseWebLoader.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)clickBtn:(id)sender {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    QHBaseWebLoader *vc = [[QHBaseWebLoader alloc] init];
    [paramDic setObject:@"http://192.168.0.100:8020/quickhybrid/examples/index.html?__hbt=1514625044921" forKey:@"pageUrl"];
    vc.params = paramDic;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
