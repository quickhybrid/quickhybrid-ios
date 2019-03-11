//
//  QHJSBaseWebLoader.h
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSBaseViewController.h"
#import <MessageUI/MessageUI.h>

@class WKWebView;

@interface QHJSBaseWebLoader : QHJSBaseViewController <MFMessageComposeViewControllerDelegate>

#pragma mark --- 暴露属性

/**
 webView
 */
@property (nonatomic, weak) WKWebView *wv;

#pragma mark --- QHJSPageApi

/**
 重新加载WKWebview
 */
- (void)reloadWKWebview;

#pragma mark --- QHJSNavigatorApi

/**
 设置导航栏按钮的方法

 @param index 位置索引，1在右，2在左，只允许两个按钮，再多请作下拉
 @param title 按钮名称，默认使用文字
 @param imageUrl 图片地址，和按钮名称二选一
 */
- (void)setRightNaviItemAtIndex:(NSInteger)index andTitle:(NSString *)title OrImageUrl:(NSString *)imageUrl;

/**
 隐藏导航栏右上角按钮的方法

 @param index 位置索引，1在右，2在左
 */
- (void)hideRightNaviItemAtIndex:(NSInteger)index;

/**
 设置导航栏左侧按钮，只能设置一个

 @param title 按钮文字，默认使用文字
 @param imageUrl 图片地址，和文字二选一
 @param isShowArrow 是否显示下拉箭头
 */
- (void)setLeftNaviItemWithTitle:(NSString *)title OrImageUrl:(NSString *)imageUrl AndIsShowBackArrow:(NSInteger)isShowArrow;

/**
 隐藏导航栏左上角自定义按钮的方法
 */
- (void)hideLeftNaviItem;

#pragma mark --- QHJSAuthApi

/**
 通过容器中持有的bridge属性注册API的方法，
 */
- (BOOL)registerHandlersWithClassName:(NSString *)className moduleName:(NSString *)moduleName;

@end
