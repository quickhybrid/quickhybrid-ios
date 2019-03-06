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

/**
 模块名
 */
@property (nonatomic, strong) NSString *moduleName;

/**
 容器
 */
@property (nonatomic, weak) QHJSBaseWebLoader *webloader;

/**
 子类使用该方法注册
 */
- (void)registerHandlers;

/**
 保存API到字典中

 @param handlerName API中的方法名
 @param handler 获取的页面上的回调
 */
- (void)registerHandlerName:(NSString *)handlerName handler:(WVJBHandler)handler;

/**
 根据API名称获取保存的API回调

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

#pragma mark --- cacheHandlerDic相关方法
/**
 保存方法
 */
- (void)saveObjectInCacheDic:(id)value forKey:(NSString *)keyName;

/**
 获取方法
 */
- (id)objectForKeyInCacheDic:(NSString *)keyName;

/**
 删除方法
 */
- (void)removeObjectForKeyInCacheDic:(NSString *)keyName;

/**
 是否包含指定的value值

 @param keyName key
 @return value
 */
- (BOOL)containObjectForKeyInCacheDic:(NSString *)keyName;

@end
