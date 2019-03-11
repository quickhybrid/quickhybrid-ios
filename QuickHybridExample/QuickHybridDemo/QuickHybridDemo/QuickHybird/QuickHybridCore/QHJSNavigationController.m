//
//  QHJSNavigationController.m
//  QuickHybridDemo
//
//  Created by guanhao on 2019/2/21.
//  Copyright © 2019年 com.quickhybrid. All rights reserved.
//

#import "QHJSNavigationController.h"
#import "QHJSBaseViewController.h"

@interface QHJSNavigationController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController *aVC;

@end

@implementation QHJSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置系统侧滑手势的代理方法
    self.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark --- 状态栏设置

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

#pragma mark --- 屏幕旋转控制

//打开时当前页面朝向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

//是否支持旋转
- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

//支持的旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

#pragma mark --- UIGestureRecognizerDelegate

//手势冲突时，同时执行，保证系统侧滑的效果
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.topViewController isKindOfClass:[QHJSBaseViewController class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.topViewController respondsToSelector:@selector(hookInteractivePopGestureRecognizerEnabled)]) {
            return [self.topViewController performSelector:@selector(hookInteractivePopGestureRecognizerEnabled)];
#pragma clang diagnostic pop
        } else {
            return YES;
        }
    } else {
        return YES;
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
