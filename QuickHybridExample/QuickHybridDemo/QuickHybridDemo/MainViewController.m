//
//  TestViewController.m
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "MainViewController.h"
#import "QHJSBaseWebLoader.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)clickBtn:(id)sender {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
    QHJSBaseWebLoader *vc = [[QHJSBaseWebLoader alloc] init];
//    [paramDic setObject:@"http://192.168.0.100:8020/quickhybrid/examples/index.html?__hbt=1514625044921" forKey:@"pageUrl"];
    NSURL *pathUrl = [[NSBundle mainBundle] URLForResource:@"quickhybrid/examples/index" withExtension:@"html"];
    [paramDic setObject:[pathUrl absoluteString] forKey:@"pageUrl"];
    vc.params = paramDic;
    
    //改变push动画
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [self.navigationController pushViewController:vc animated:NO];
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
