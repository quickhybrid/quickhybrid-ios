//
//  BaseViewController.h
//  QuickHybirdJSBridgeDemo
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WKWebViewJavascriptBridge;
@class QHBaseWebLoader;

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface QHJSRegisterBaseClass : NSObject

@property (nonatomic, weak) QHBaseWebLoader *webloader;
/** 模块名称 */
@property (nonatomic, strong) NSString *moduleName;
// 子类使用该方法注册
- (void)registerHandlers;

- (WVJBHandler)handler:(NSString *)handlerName;

- (void)registerHandlerName:(NSString *)handlerName
                    handler:(WVJBHandler)handler;

// 持有长期回调
- (void)cacheCallback:(WVJBResponseCallback)callback
          handlerName:(NSString *)handlerName;

// 移除长期回调
- (void)removeCacheCallback:(NSString *)handlerName;


- (WVJBResponseCallback)cachedCallback:(NSString *)handerName;

- (NSDictionary *)responseDicWithCode:(NSInteger)code
                                  Msg:(NSString *)msg
                                 result:(id)data;
@end
