//
//  QHJSDatePickViewController.h
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/12.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import "QHJSBaseModalViewController.h"

typedef NS_ENUM(NSUInteger, QHJSDatePickerMode) {
    QHJSDatePickerModeTime = 0,
    QHJSDatePickerDate,
    QHJSDatePickerDateAndTime,
};

typedef void(^selectBlock)(NSString *dateTimeStr);

@interface QHJSDatePickViewController : QHJSBaseModalViewController

/** 标题 */
@property (nonatomic, strong) NSString *titleStr;
/** 时间选择类型 */
@property (nonatomic, assign) QHJSDatePickerMode datePickerMode;

/**
 默认展示的时间
 */
@property (nonatomic, strong) NSString *defaultDateTime;

@property (nonatomic, copy) selectBlock selectBlock;

@end
