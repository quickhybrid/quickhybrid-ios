//
//  QHJSBaseViewController.h
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 回调block
 */
typedef void(^CallBack)(NSString *);

@interface QHJSBaseViewController : UIViewController

//传递参数
@property (nonatomic, strong) NSMutableDictionary *params;

/** 传值 */
@property (nonatomic, copy) CallBack pageCallback;

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
 
 @param hidden 显隐状态
 */
- (void)changeStatusBarHiddenState:(BOOL)hidden;

/**
 设置状态栏样式
 
 @param style 状态栏样式
 */
- (void)changeStatusBarStyle:(UIStatusBarStyle)style;

@end
