//
//  WKWebViewJavascriptBridge.h
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebKit
#endif

#if defined(supportsWKWebKit )

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"
#import <WebKit/WebKit.h>

@interface WKWebViewJavascriptBridge : NSObject<WKNavigationDelegate, WebViewJavascriptBridgeBaseDelegate, WKScriptMessageHandler>

+ (instancetype)bridgeForWebView:(WKWebView*)webView;
+ (void)enableLogging;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;
- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate;
- (void)disableJavscriptAlertBoxSafetyTimeout;

/**
 新增执行方法

 @param message 所需执行的方法（JSON字符）
 */
- (void)excuteMessage:(NSString *)message;

/**
 自定义API注册方法

 @param className 自定义API所在类类名
 @param moduleName API所属模块
 */
- (BOOL)registerHandlersWithClassName:(NSString *)className
                           moduleName:(NSString *)moduleName;


/**
 定义注册Api权限
 
 @param className 自定义API所在类类名
 @param handlerName 功能方面名
 */
- (void)registerHandlersWithAccess:(NSString*)className
           handlerName:(NSString *)handlerName;


/**
 WKWebView批量注册框架API方法
 */
- (void)registerQHJSFrameAPI;

/**
 统一异常回调方法
 
 @param errorCode 错误码
 @param errorUrl 错误的Url
 @param errorDescription 错误描述
 */
- (void)handleErrorWithCode:(NSInteger)errorCode
                   errorUrl:(NSString *)errorUrl
           errorDescription:(NSString *)errorDescription;


- (WVJBResponseCallback)getCacheCallbackWithModuleName:(NSString *)moduleName
                                           handlerName:(NSString *)handlerName;
@end

#endif
