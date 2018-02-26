//
//  QHJSBaseModalViewController.h
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/12.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHJSBaseModalViewController : UIViewController

/**
 *  模态视图加载的方式
 *
 *  @param presentingVC 源控制器
 */
- (void)showByModalInController:(UIViewController *)presentingVC;

- (void)dismiss;

@end
