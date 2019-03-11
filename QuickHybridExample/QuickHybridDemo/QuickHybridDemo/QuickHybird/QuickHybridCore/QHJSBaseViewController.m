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

/** 打开初始朝向 */
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
/** 是否自动旋转，默认NO */
@property (nonatomic, assign) BOOL autorotate;
/** 支持的旋转方向 */
@property (nonatomic, assign) UIInterfaceOrientationMask orientationsMask;
@end

@implementation QHJSBaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _statusBarStyle = UIStatusBarStyleDefault;
        _statusBarShouldHide = NO;
        
        //默认可以侧滑返回
        _interactivePopGestureRecognizerEnabled = YES;
        //默认可以pop代码返回
        _shouldPop = YES;
        
        //默认竖屏
        _interfaceOrientation = UIInterfaceOrientationPortrait;
        //默认可以旋转
        _autorotate = YES;
        //默人只能旋转到竖屏
        _orientationsMask = UIInterfaceOrientationMaskPortrait;
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
    
    //屏幕旋转
    NSNumber *orientation = self.params[@"orientation"];
    if (orientation) {
        if ([orientation integerValue] == 0) {
            //强制横屏
            [self setInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
            [self setAutorotate:YES];
            [self setOrientationsMask:UIInterfaceOrientationMaskLandscape];
            [self forceToOrientation:UIDeviceOrientationLandscapeLeft];
        } else if ([orientation integerValue] == 1) {
            //强制竖屏
            [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
            [self setAutorotate:YES];
            [self setOrientationsMask:UIInterfaceOrientationMaskPortrait];
            [self forceToOrientation:UIDeviceOrientationPortrait];
        } else if ([orientation integerValue] == 2) {
            //跟随系统
            [self setOrientationsMask:UIInterfaceOrientationMaskAll];
            [self setAutorotate:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)backAction {
    if (self.shouldPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

#pragma mark --- 屏幕旋转控制

//打开时当前页面朝向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.interfaceOrientation;
}

//是否支持旋转
- (BOOL)shouldAutorotate {
    return self.autorotate;
}

//支持的旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.orientationsMask;
}

//主动强制横竖屏方法
- (void)forceToOrientation:(UIDeviceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
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
