//
//  QHBaseWebLoader.h
//  QuickHybirdJSBridgeDemo
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHBaseViewController.h"

@class WKWebView;

@interface QHBaseWebLoader : QHBaseViewController

@property (weak, nonatomic) WKWebView *wv;

- (void)presentNewVC:(UIViewController *)vc animated:(BOOL)animated;

- (void)pushNewVC:(UIViewController *)vc;

- (BOOL)registerHandlersWithClassName:(NSString *)className
                           moduleName:(NSString *)moduleName;

// 注册Api方法的权限
- (BOOL)registerAccessWithClassName:(NSString *)className
                         methodName:(NSString *)methodName;

@end
