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

@interface WKWebViewJavascriptBridge : NSObject <WebViewJavascriptBridgeBaseDelegate, WKScriptMessageHandler>

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
 注册API

 @param className API类名
 @param moduleName API所属模块
 */
- (BOOL)registerHandlersWithClassName:(NSString *)className moduleName:(NSString *)moduleName;


/**
 WKWebView批量注册框架API方法
 */
- (void)registerFrameAPI;

/**
 统一异常回调方法
 
 @param errorCode 错误码
 @param errorUrl 错误的Url
 @param errorDescription 错误描述
 */
- (void)handleErrorWithCode:(NSInteger)errorCode errorUrl:(NSString *)errorUrl errorDescription:(NSString *)errorDescription;

/**
 获取页面内临时缓存的数据或方法
 */
- (id)objectForKeyInCacheDicWithModuleName:(NSString *)moduleName KeyName:(NSString *)keyName;

/**
 删除页面内临时缓存的数据或方法
 */
- (void)removeObjectForKeyInCacheDicWithModuleName:(NSString *)moduleName KeyName:(NSString *)keyName;

/**
 是否包含指定的value值

 @param moduleName 框架API模块名称
 @param keyName key
 @return yes/no
 */
- (BOOL)containObjectForKeyInCacheDicWithModuleName:(NSString *)moduleName KeyName:(NSString *)keyName;

@end

#endif
