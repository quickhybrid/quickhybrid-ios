//
//  QHJSBaseViewController.h
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHJSInfo.h"
#import "UIImage+QHJSIamge.h"

/**
 回调block
 */
typedef void(^CallBack)(NSString *);

@interface QHJSBaseViewController : UIViewController

/**
 传递参数的字典
 */
@property (nonatomic, strong) NSMutableDictionary *params;

/**
 回调传值
 */
@property (nonatomic, copy) CallBack pageCallback;

/**
 左上角返回按钮
 */
@property (nonatomic, weak) UIBarButtonItem *backBarButton;

/**
 导航栏左侧返回按钮方法
 */
- (void)backAction;

/**
 开启progress
 */
- (void)showProgressWithMessage:(NSString *)message;

/**
 隐藏progress
 */
- (void)hideProgress;

/**
 设置状态栏的显示与隐藏
 */
- (void)changeStatusBarHiddenState:(BOOL)hidden;

/**
 设置状态栏样式
 
 @param style 状态栏样式
 */
- (void)changeStatusBarStyle:(UIStatusBarStyle)style;

/**
 系统侧滑返回的状态值
 */
@property (nonatomic, assign) BOOL interactivePopGestureRecognizerEnabled;

/**
 是否拦截系统侧滑返回方法
 */
- (BOOL)hookInteractivePopGestureRecognizerEnabled;

/**
 能否使用pop方法的值
 */
@property (nonatomic, assign) BOOL shouldPop;

@end
