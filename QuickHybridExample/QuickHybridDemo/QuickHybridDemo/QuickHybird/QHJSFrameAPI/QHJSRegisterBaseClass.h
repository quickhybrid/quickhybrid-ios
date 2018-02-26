//
//  BaseViewController.h
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHJSBaseWebLoader.h"

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface QHJSRegisterBaseClass : NSObject

@property (nonatomic, weak) QHJSBaseWebLoader *webloader;

/**
 模块名
 */
@property (nonatomic, strong) NSString *moduleName;

/**
 子类使用该方法注册
 */
- (void)registerHandlers;

/**
 保存API内各方法回调的方法

 @param handlerName API中的方法名
 @param handler 获取的页面上的回调
 */
- (void)registerHandlerName:(NSString *)handlerName handler:(WVJBHandler)handler;

/**
 根据方法名获取保存的回调

 @param handlerName API中的方法名
 @return 回调
 */
- (WVJBHandler)handler:(NSString *)handlerName;


/**
 统一回调参数字典拼装

 @param code 1、0
 @param msg msg
 @param data result
 @return 封装好的字典
 */
- (NSDictionary *)responseDicWithCode:(NSInteger)code Msg:(NSString *)msg result:(id)data;

@end
