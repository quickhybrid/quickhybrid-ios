//
//  QHToast.h
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHToast : UIView

/**
 设置toast
 
 @param message 提示信息
 @param duration 持续时间
 @return 返回toast
 */
+ (QHToast *)toastMessage:(NSString *)message duration:(NSTimeInterval)duration;

/**
 显示
 */
- (void)show;

@end
