//
//  QHJSNaviSegmentView.h
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/15.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^titleClickAction)(NSInteger which);

@interface QHJSNaviSegmentView : UIView

/**
 初始化方法
 
 @param titles 标题数组
 @return 页面实例对象
 */
- (instancetype)initWithTitleItems:(NSArray *)titles;

/**
 标题点击回调block
 */
@property (nonatomic, copy) titleClickAction titleClickAction;

///**
// 设置选中某个标题
//
// @param which 哪一个标题
// */
//- (void)setSelectTitleItem:(NSInteger)which;

@end
