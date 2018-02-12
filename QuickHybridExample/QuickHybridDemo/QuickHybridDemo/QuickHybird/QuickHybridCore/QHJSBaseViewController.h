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

@end
