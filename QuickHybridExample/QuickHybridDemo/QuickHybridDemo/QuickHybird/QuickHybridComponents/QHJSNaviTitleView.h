//
//  QHJSNaviTitleView.h
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/15.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickAction)(BOOL click);

@interface QHJSNaviTitleView : UIView

/**
 初始化方法
 
 @param mainTitle 主标题
 @param subTitle 副标题
 @param clickable 是否可点击
 @param direction 箭头方向 (bottom/top)
 @return 页面实例对象
 */
- (instancetype)initWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle clickable:(NSInteger)clickable direction:(NSString *)direction;

@property (nonatomic, copy) clickAction clickAction;

@end
