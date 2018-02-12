//
//  QHJSBaseWebLoader.h
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSBaseViewController.h"

@class WKWebView;

@interface QHJSBaseWebLoader : QHJSBaseViewController

@property (weak, nonatomic) WKWebView *wv;

@property (weak, nonatomic) UIViewController *superVC;

//页面跳转的方法
- (void)presentNewVC:(UIViewController *)vc animated:(BOOL)animated;
- (void)pushNewVC:(UIViewController *)vc;

/**
 导航栏返回按钮的方法
 */
- (void)backAction;

/**
 重新加载WKWebview
 */
- (void)reloadWKWebview;

//注册API的方法
- (BOOL)registerHandlersWithClassName:(NSString *)className moduleName:(NSString *)moduleName;

@end
