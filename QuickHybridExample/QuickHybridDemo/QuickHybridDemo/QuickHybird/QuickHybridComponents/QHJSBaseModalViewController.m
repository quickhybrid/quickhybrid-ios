//
//  QHJSBaseModalViewController.m
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/12.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import "QHJSBaseModalViewController.h"

@interface QHJSBaseModalViewController ()

@end

@implementation QHJSBaseModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    
    [self createDismissTapGesture];
}

//退出手势
- (void)createDismissTapGesture {
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    dismissTap.cancelsTouchesInView = YES;
    [self.view addGestureRecognizer:dismissTap];
}

//模态视图加载的方式
- (void)showByModalInController:(UIViewController *)presentingVC {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [presentingVC presentViewController:self animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
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
