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

#pragma mark --- setter/getter方法

- (instancetype)init {
    self = [super init];
    if (self) {
        _statusBarStyle = UIStatusBarStyleDefault;
        _statusBarShouldHide = NO;
        _interactivePopGestureRecognizerEnabled = YES;
        _shouldPop = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //设置导航栏返回按钮，采用leftBarButtonItem设置，隐藏backBarButtonItem
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"qhjs_naviback.png" inBundleName:@"QuickHybridBundle"] style:(UIBarButtonItemStylePlain) target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    _backBarButton = backBarButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fullScreenPanGR:(UIPanGestureRecognizer *)sender {
    
}

//开启progress
- (void)showProgressWithMessage:(NSString *)message {
    WSProgressHUD *progressHUD = [[WSProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    [self.view bringSubviewToFront:progressHUD];
    _progressHUD = progressHUD;
    if (message || (message.length > 0)) {
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

//设置状态栏的显示与隐藏
- (void)changeStatusBarHiddenState:(BOOL)hidden {
    self.statusBarShouldHide = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

//设置状态栏样式
- (void)changeStatusBarStyle:(UIStatusBarStyle)style {
    self.statusBarStyle = style;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark --- 导航栏方法

//是否拦截系统侧滑返回方法
- (BOOL)hookInteractivePopGestureRecognizerEnabled {
    return self.interactivePopGestureRecognizerEnabled;
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
