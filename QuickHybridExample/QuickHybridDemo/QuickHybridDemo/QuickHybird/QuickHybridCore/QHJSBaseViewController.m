//
//  QHJSBaseViewController.m
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSBaseViewController.h"
#import "WSProgressHUD.h"

@interface QHJSBaseViewController ()
/** HUD */
@property (nonatomic, weak) WSProgressHUD *progressHUD;
/** 状态栏显隐状态 */
@property (nonatomic, assign) BOOL statusBarShouldHide;
/** 状态栏样式 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation QHJSBaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _statusBarStyle = UIStatusBarStyleDefault;
        _statusBarShouldHide = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //修改返回按钮
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"qhjs_naviback"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

//开启progress
- (void)showProgressWithMessage:(NSString *)message {
//    UIView *superView = self.navigationController.view ?  : self.view;
    UIView *superView = self.view;
    WSProgressHUD *progressHUD = [[WSProgressHUD alloc] initWithView:superView];
    [superView addSubview:progressHUD];
    self.progressHUD = progressHUD;
    if (message) {
        [progressHUD showWithString:message maskType:(WSProgressHUDMaskTypeClear)];
    } else {
        [progressHUD showWithMaskType:(WSProgressHUDMaskTypeClear)];
    }
}

//隐藏progress
- (void)hideProgress {
    [self.progressHUD dismiss];
}

#pragma mark --- 状态栏设置

- (BOOL)prefersStatusBarHidden {
    return self.statusBarShouldHide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)changeStatusBarHiddenState:(BOOL)hidden {
    self.statusBarShouldHide = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)changeStatusBarStyle:(UIStatusBarStyle)style {
    self.statusBarStyle = style;
    [self setNeedsStatusBarAppearanceUpdate];
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
